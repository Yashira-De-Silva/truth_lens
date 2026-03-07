"""
TruthLens — Python ML Service
==============================
Downloads the Kaggle fake-news dataset, trains a TF-IDF + LR classifier,
and exposes a REST API for the Flutter app.

Endpoints:
  GET  /health                              — health check
  GET  /news?limit=20&offset=0             — paginated dataset articles
  GET  /news/live?limit=10&section=...     — live Guardian API news + ML label
  GET  /news/digest?limit=3                — top REAL-confidence articles
  GET  /news/search?q=...&category=...     — keyword + category filter
  POST /predict  {title, text}             — classify a custom article

Run:
  cd apps/ml_service
  pip3 install -r requirements.txt
  python3 app.py
"""

import os
import pickle
import random
import logging
from typing import Optional, Tuple

import kagglehub
import pandas as pd
import requests as http_requests
from flask import Flask, jsonify, request
from flask_cors import CORS
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Allow Flutter app to call from any origin

# ── Paths ─────────────────────────────────────────────────────────────────────
BASE_DIR   = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "model.pkl")

# ── Guardian API config ───────────────────────────────────────────────────────
# Get a free key at: https://open-platform.theguardian.com/access
# Then set it here OR export GUARDIAN_API_KEY=your_key before running.
GUARDIAN_API_KEY = os.environ.get("GUARDIAN_API_KEY", "c6d32650-a403-4157-8569-4e39624a022d")
GUARDIAN_BASE    = "https://content.guardianapis.com"

# ── Guardian section → category mapping ──────────────────────────────────────
GUARDIAN_SECTIONS = {
    "All":           "news",
    "Politics":      "politics",
    "Business":      "business",
    "Technology":    "technology",
    "Science":       "science",
    "Health":        "society",
    "Sports":        "sport",
    "Entertainment": "film",
}

# ── Global state ──────────────────────────────────────────────────────────────
pipeline: Optional[Pipeline] = None
articles_df: Optional[pd.DataFrame] = None  # full dataset kept in memory


# ── Dataset loading ───────────────────────────────────────────────────────────

def load_dataset() -> pd.DataFrame:
    """
    Download (or use cached) the Kaggle dataset and return a clean DataFrame.
    Handles two dataset formats:
      1. Two-file format: Fake.csv + True.csv (no label column, add 0 and 1)
      2. Single-file format: with a 'label' column already present
    """
    log.info("Downloading / loading dataset via kagglehub …")
    dataset_path = kagglehub.dataset_download(
        "emineyetm/fake-news-detection-datasets"
    )
    log.info(f"Dataset path: {dataset_path}")

    # Collect all CSV files in the download directory
    csv_files = []
    for root, _dirs, files in os.walk(dataset_path):
        for fname in files:
            if fname.lower().endswith(".csv"):
                csv_files.append(os.path.join(root, fname))

    if not csv_files:
        raise FileNotFoundError(f"No CSV files found in {dataset_path}")

    log.info(f"CSV files found: {csv_files}")

    # ── Detect Two-file Format (Fake.csv + True.csv) ──────────────────────────
    fake_csv = next((f for f in csv_files if "fake" in os.path.basename(f).lower()), None)
    true_csv = next((f for f in csv_files if "true" in os.path.basename(f).lower()), None)

    if fake_csv and true_csv:
        log.info(f"Using two-file format: Fake={fake_csv} | True={true_csv}")

        df_fake = pd.read_csv(fake_csv)
        df_fake.columns = [c.strip().lower() for c in df_fake.columns]
        df_fake["label"] = 0  # 0 = FAKE

        df_true = pd.read_csv(true_csv)
        df_true.columns = [c.strip().lower() for c in df_true.columns]
        df_true["label"] = 1  # 1 = REAL

        df = pd.concat([df_fake, df_true], ignore_index=True)
    else:
        # ── Single-file Format ─────────────────────────────────────────────────
        csv_path = max(csv_files, key=os.path.getsize)
        log.info(f"Using single-file format: {csv_path}")
        df = pd.read_csv(csv_path)
        df.columns = [c.strip().lower() for c in df.columns]

        if "label" not in df.columns:
            raise ValueError(f"Expected a 'label' column; found: {list(df.columns)}")

        # Coerce label to int (0 = FAKE, 1 = REAL)
        if df["label"].dtype == object:
            df["label"] = df["label"].str.strip().str.upper().map(
                {"FAKE": 0, "REAL": 1, "0": 0, "1": 1}
            )
        df["label"] = pd.to_numeric(df["label"], errors="coerce")

    df = df.dropna(subset=["label"])
    df["label"] = df["label"].astype(int)

    # ── Handle title/text columns ────────────────────────────────────────────
    if "title" not in df.columns:
        df["title"] = ""
    if "text" not in df.columns:
        if "body" in df.columns:
            df["text"] = df["body"]
        else:
            df["text"] = ""

    # ── Combine text for classification ──────────────────────────────────────
    df["combined"] = (
        df["title"].fillna("").astype(str)
        + " "
        + df["text"].fillna("").astype(str)
    ).str.strip()

    # Keep only rows with meaningful text
    df = df[df["combined"].str.len() > 20].copy()
    df = df.reset_index(drop=True)

    # Add a 'source' column if not present
    if "source" not in df.columns:
        sources = [
            "Reuters", "BBC", "CNN", "AP News", "The Guardian",
            "NPR", "Al Jazeera", "Bloomberg", "Associated Press", "Fox News",
        ]
        df["source"] = [sources[i % len(sources)] for i in range(len(df))]

    log.info(
        f"Dataset ready: {len(df)} rows | "
        f"FAKE={(df['label']==0).sum()} | REAL={(df['label']==1).sum()}"
    )
    return df


# ── Model training ────────────────────────────────────────────────────────────

def train_model(df: pd.DataFrame) -> Pipeline:
    log.info("Training TF-IDF + Logistic Regression model …")
    X = df["combined"]
    y = df["label"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    pipe = Pipeline([
        ("tfidf", TfidfVectorizer(
            max_features=50_000,
            ngram_range=(1, 2),
            min_df=2,
            sublinear_tf=True,
        )),
        ("clf", LogisticRegression(
            C=5.0,
            max_iter=1000,
            solver="lbfgs",
            n_jobs=-1,
        )),
    ])

    pipe.fit(X_train, y_train)
    accuracy = pipe.score(X_test, y_test)
    log.info(f"Test accuracy: {accuracy:.4f}")
    return pipe


def get_pipeline_and_data() -> Tuple[Pipeline, pd.DataFrame]:
    """Load from disk if available; otherwise download + train."""
    global pipeline, articles_df

    if pipeline is not None and articles_df is not None:
        return pipeline, articles_df

    # Always load the dataset (we need articles to serve)
    df = load_dataset()
    articles_df = df

    if os.path.exists(MODEL_PATH):
        log.info(f"Loading saved model from {MODEL_PATH}")
        with open(MODEL_PATH, "rb") as f:
            pipeline = pickle.load(f)
    else:
        pipeline = train_model(df)
        with open(MODEL_PATH, "wb") as f:
            pickle.dump(pipeline, f)
        log.info(f"Model saved to {MODEL_PATH}")

    return pipeline, articles_df


# ── Article serialisation ─────────────────────────────────────────────────────

def row_to_article(pipe: Pipeline, idx: int, row: pd.Series) -> dict:
    """Convert a DataFrame row to the API article format."""
    combined = str(row.get("combined", ""))
    proba = pipe.predict_proba([combined])[0]  # [P(FAKE), P(REAL)]
    real_prob = float(proba[1])
    fake_prob = float(proba[0])

    label = "REAL" if real_prob >= 0.5 else "FAKE"

    # Trim text for summary (first 250 chars)
    raw_text = str(row.get("text", "")).strip()
    summary  = raw_text[:250].rstrip() + ("…" if len(raw_text) > 250 else "")

    title = str(row.get("title", "No title")).strip()
    if not title or title.lower() in ("nan", ""):
        title = summary[:80].rstrip() + "…"

    source = str(row.get("source", "Unknown")).strip()

    return {
        "id":         int(idx),
        "title":      title,
        "summary":    summary,
        "source":     source,
        "label":      label,
        "confidence": round(real_prob if label == "REAL" else fake_prob, 4),
    }


# ── API Startup ───────────────────────────────────────────────────────────────

# Pre-load on startup (avoids slow first request)
try:
    _pipe, _df = get_pipeline_and_data()
    log.info("ML service ready ✅")
except Exception as exc:
    log.error(f"Failed to initialise ML service: {exc}")
    _pipe, _df = None, None


# ── Routes ────────────────────────────────────────────────────────────────────

@app.route("/health")
def health():
    return jsonify({"status": "ok", "model_loaded": pipeline is not None})


@app.route("/news")
def get_news():
    pipe, df = get_pipeline_and_data()

    limit  = min(int(request.args.get("limit",  20)), 100)
    offset = int(request.args.get("offset", 0))

    # Shuffle a reproducible sample based on offset so pages are stable
    rng = random.Random(offset // limit)
    indices = list(df.index)
    rng.shuffle(indices)
    page_indices = indices[offset: offset + limit]

    articles = []
    for idx in page_indices:
        try:
            articles.append(row_to_article(pipe, idx, df.loc[idx]))
        except Exception:
            continue

    return jsonify({"success": True, "data": articles, "total": len(df)})


@app.route("/news/digest")
def get_digest():
    """Return top N verified (REAL, high-confidence) articles."""
    pipe, df = get_pipeline_and_data()
    limit = min(int(request.args.get("limit", 3)), 10)

    # Evaluate a sample of articles and pick the most confidently REAL ones
    sample_size = min(500, len(df))
    sample_df   = df.sample(n=sample_size, random_state=7)

    scored = []
    for idx, row in sample_df.iterrows():
        try:
            art = row_to_article(pipe, idx, row)
            if art["label"] == "REAL":
                scored.append(art)
        except Exception:
            continue

    # Sort by confidence descending, take top N
    scored.sort(key=lambda a: a["confidence"], reverse=True)
    return jsonify({"success": True, "data": scored[:limit]})


@app.route("/news/search")
def search_news():
    pipe, df = get_pipeline_and_data()

    query    = request.args.get("q", "").strip().lower()
    category = request.args.get("category", "All").strip()
    limit    = min(int(request.args.get("limit", 20)), 100)

    # Category → keyword mapping for simple filtering
    category_keywords = {
        "Politics":      ["politic", "government", "senate", "congress", "president", "election"],
        "Business":      ["business", "economy", "market", "stock", "finance", "trade"],
        "Technology":    ["tech", "ai", "software", "internet", "digital", "cyber"],
        "Science":       ["science", "research", "study", "climate", "space", "nasa"],
        "Health":        ["health", "medical", "vaccine", "hospital", "disease", "virus"],
        "Sports":        ["sport", "game", "football", "basketball", "olympic", "athlete"],
        "Entertainment": ["entertain", "movie", "music", "celebrity", "film", "actor"],
    }

    mask = pd.Series([True] * len(df), index=df.index)

    if query:
        mask &= (
            df["title"].str.lower().str.contains(query, na=False)
            | df["text"].str.lower().str.contains(query, na=False)
        )

    cat_kws = category_keywords.get(category)
    if cat_kws:
        cat_mask = df["title"].str.lower().apply(
            lambda t: any(k in t for k in cat_kws)
        ) | df["text"].str.lower().apply(
            lambda t: any(k in t for k in cat_kws)
        )
        mask &= cat_mask

    filtered = df[mask].head(limit * 5)  # over-fetch, then score

    articles = []
    for idx, row in filtered.iterrows():
        try:
            articles.append(row_to_article(pipe, idx, row))
        except Exception:
            continue
        if len(articles) >= limit:
            break

    return jsonify({"success": True, "data": articles})


@app.route("/predict", methods=["POST"])
def predict():
    """Classify a custom article title+text submitted by the app."""
    pipe, _ = get_pipeline_and_data()
    body     = request.get_json(force=True, silent=True) or {}
    title    = str(body.get("title", ""))
    text     = str(body.get("text",  ""))
    combined = f"{title} {text}".strip()

    if not combined:
        return jsonify({"success": False, "message": "Provide title or text"}), 400

    proba     = pipe.predict_proba([combined])[0]
    real_prob = float(proba[1])
    label     = "REAL" if real_prob >= 0.5 else "FAKE"

    return jsonify({
        "success":    True,
        "label":      label,
        "confidence": round(real_prob if label == "REAL" else float(proba[0]), 4),
        "real_prob":  round(real_prob, 4),
        "fake_prob":  round(float(proba[0]), 4),
    })


@app.route("/news/live")
def get_live_news():
    """
    Fetch real-time articles from The Guardian API and classify each one
    using the trained ML model.

    Query params:
      limit    — number of articles (default 10, max 50)
      section  — category name matching the Flutter categories (default 'All')
    """
    pipe, _ = get_pipeline_and_data()

    limit   = min(int(request.args.get("limit", 10)), 50)
    section = request.args.get("section", "All")

    if not GUARDIAN_API_KEY:
        return jsonify({
            "success": False,
            "message": (
                "Guardian API key not configured. "
                "Set GUARDIAN_API_KEY env variable or edit GUARDIAN_API_KEY in app.py. "
                "Get a free key at https://open-platform.theguardian.com/access"
            ),
            "data": []
        }), 503

    guardian_section = GUARDIAN_SECTIONS.get(section, "news")

    try:
        resp = http_requests.get(
            f"{GUARDIAN_BASE}/search",
            params={
                "api-key":       GUARDIAN_API_KEY,
                "section":       guardian_section,
                "show-fields":   "trailText,bodyText,headline",
                "page-size":     limit,
                "order-by":      "newest",
            },
            timeout=10,
        )
        resp.raise_for_status()
    except Exception as e:
        log.error(f"Guardian API error: {e}")
        return jsonify({"success": False, "message": str(e), "data": []}), 502

    raw      = resp.json()
    results  = raw.get("response", {}).get("results", [])
    articles = []

    for i, item in enumerate(results):
        fields   = item.get("fields", {})
        title    = fields.get("headline") or item.get("webTitle", "")
        body     = fields.get("bodyText", "") or fields.get("trailText", "")
        trail    = fields.get("trailText", body[:250])
        section_name = item.get("sectionName", "The Guardian")

        combined = f"{title} {body}".strip()
        if not combined:
            continue

        proba     = pipe.predict_proba([combined])[0]
        real_prob = float(proba[1])
        fake_prob = float(proba[0])
        label     = "REAL" if real_prob >= 0.5 else "FAKE"

        summary = trail[:250].rstrip() + ("…" if len(trail) > 250 else "")

        articles.append({
            "id":         90000 + i,   # offset to avoid collisions with dataset IDs
            "title":      title,
            "summary":    summary,
            "source":     f"The Guardian – {section_name}",
            "label":      label,
            "confidence": round(real_prob if label == "REAL" else fake_prob, 4),
            "url":        item.get("webUrl", ""),
            "published":  item.get("webPublicationDate", ""),
            "is_live":    True,
        })

    return jsonify({"success": True, "data": articles, "source": "guardian"})


# ── Entry point ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=False)
