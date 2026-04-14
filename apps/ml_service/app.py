"""
TruthLens — Python ML Service (Streaming Mode)
==============================================
Optimized for high-memory datasets (45k+ rows) on limited RAM (512MB).
Reads from disk on-demand instead of loading full DataFrame into RAM.

Endpoints:
  GET  /health              — Health check + basic stats
  GET  /news                — Streaming paginated dataset articles
  GET  /news/live           — Guardian API live news + ML labeling
  GET  /news/digest         — Top articles from the dataset
  GET  /news/search         — Keyword search within dataset samples
  POST /predict             — Classify custom title/text
  POST /api/bot/ask         — AI Chatbot with ML context
"""

import gc
import os
import re
import signal
import joblib
import random
import logging
import subprocess
from typing import Optional, List, Dict, Any, Tuple

import kagglehub
import pandas as pd
import requests as http_requests
from flask import Flask, jsonify, request
from flask_cors import CORS
from sklearn.pipeline import Pipeline
import google.generativeai as genai

# Setup logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# ── Paths ─────────────────────────────────────────────────────────────────────
BASE_DIR   = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "model.pkl")

# ── Config ────────────────────────────────────────────────────────────────────
GUARDIAN_API_KEY = os.environ.get("GUARDIAN_API_KEY", "c6d32650-a403-4157-8569-4e39624a022d")
GUARDIAN_BASE    = "https://content.guardianapis.com"
GEMINI_API_KEY   = os.environ.get("GEMINI_API_KEY", "AIzaSyAYZMNNVcB6BLIgVIQYTOhJ-xqT5qXVimc")

if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

# Memory Guard: Limit the dataset size to keep RAM under 400MB
MAX_ROWS_PER_TYPE = 10000 

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

# ── Global State ──────────────────────────────────────────────────────────────
pipeline: Optional[Pipeline] = None
dataset_meta = {
    "fake_csv": None,
    "true_csv": None,
    "fake_count": 0,
    "true_count": 0,
    "total_count": 0,
    "loaded": False
}

# ── Database/Streaming Logic ──────────────────────────────────────────────────

def ensure_dataset_indexed():
    """Locate dataset and count rows once without loading into RAM."""
    global dataset_meta
    if dataset_meta["loaded"]:
        return

    log.info("Indexing dataset via kagglehub …")
    try:
        path = kagglehub.dataset_download("emineyetm/fake-news-detection-datasets")
        csv_files = []
        for root, _, files in os.walk(path):
            for f in files:
                if f.lower().endswith(".csv"):
                    csv_files.append(os.path.join(root, f))

        fake = next((f for f in csv_files if "fake" in os.path.basename(f).lower()), None)
        true = next((f for f in csv_files if "true" in os.path.basename(f).lower()), None)

        if fake and true:
            # Emergency Speed Fix: Skip line counting (which spikes RAM)
            # Just assume we take MAX_ROWS_PER_TYPE for each
            f_count = MAX_ROWS_PER_TYPE
            t_count = MAX_ROWS_PER_TYPE
            
            dataset_meta.update({
                "fake_csv": fake, "true_csv": true,
                "fake_count": f_count, "true_count": t_count,
                "total_count": f_count + t_count, "loaded": True
            })
            log.info(f"Speed Fix Active: Assume {f_count} FAKE, {t_count} TRUE")
            gc.collect() # Immediate cleanup
        else:
            log.error("Could not find dataset files.")
    except Exception as e:
        log.error(f"Dataset indexing failed: {e}")

def get_news_slice(offset: int, limit: int) -> List[Dict]:
    """Fetch a slice of news from disk."""
    ensure_dataset_indexed()
    articles = []
    
    curr_offset = offset
    curr_limit = limit
    f_count = dataset_meta["fake_count"]
    t_count = dataset_meta["true_count"]

    # Read from Fake.csv with optimization
    if curr_offset < f_count:
        fetch_f = min(curr_limit, f_count - curr_offset)
        # Usecols and engine='c' for speed and memory efficiency
        df_f = pd.read_csv(dataset_meta["fake_csv"], skiprows=range(1, curr_offset + 1), nrows=fetch_f, usecols=["title", "text", "date"])
        df_f["label"] = 0
        articles.extend(_df_to_articles(df_f, curr_offset))
        curr_limit -= fetch_f
        curr_offset = 0
    else:
        curr_offset -= f_count

    # Read from True.csv with optimization
    if curr_limit > 0 and curr_offset < t_count:
        fetch_t = min(curr_limit, t_count - curr_offset)
        df_t = pd.read_csv(dataset_meta["true_csv"], skiprows=range(1, curr_offset + 1), nrows=fetch_t, usecols=["title", "text", "date"])
        df_t["label"] = 1
        articles.extend(_df_to_articles(df_t, f_count + curr_offset))
    
    gc.collect() # Cleanup after data fetch
    return articles

def _df_to_articles(df: pd.DataFrame, start_id: int) -> List[Dict]:
    df.columns = [c.strip().lower() for c in df.columns]
    res = []
    for i, row in df.iterrows():
        text = str(row.get("text", "")).strip()
        label = "REAL" if int(row.get("label", 0)) == 1 else "FAKE"
        res.append({
            "id": start_id + i,
            "title": str(row.get("title", "No Title"))[:200],
            "summary": text[:300] + ("…" if len(text) > 300 else ""),
            "full_text": text,
            "label": label,
            "confidence": 1.0,
            "source": str(row.get("source", "Dataset")),
            "published": str(row.get("date", ""))
        })
    return res

def get_pipeline():
    global pipeline
    if pipeline is None and os.path.exists(MODEL_PATH):
        try:
            pipeline = joblib.load(MODEL_PATH)
            log.info("ML Pipeline loaded ✅")
            gc.collect() # Heavy object loaded, perform cleanup
        except Exception as e:
            log.error(f"Pipeline load failed: {e}")
    return pipeline

# ── Helpers ───────────────────────────────────────────────────────────────────

def translate_articles(articles: List[Dict], target_lang: str) -> List[Dict]:
    if not target_lang or target_lang == "en":
        return articles
    try:
        from deep_translator import GoogleTranslator
        translator = GoogleTranslator(source='auto', target=target_lang)
        for art in articles:
            art["title"] = translator.translate(art["title"][:4999])
            art["summary"] = translator.translate(art["summary"][:4999])
    except Exception as e:
        log.warning(f"Translation failed: {e}")
    return articles

# ── Routes ────────────────────────────────────────────────────────────────────

@app.route("/")
def home():
    return jsonify({"status": "online", "service": "TruthLens ML Service", "dataset_rows": dataset_meta["total_count"]})

@app.route("/health")
def health():
    return jsonify({"status": "ok", "indexed": dataset_meta["loaded"], "model": get_pipeline() is not None})

@app.route("/news")
def get_news():
    offset = int(request.args.get("offset", 0))
    limit = min(int(request.args.get("limit", 20)), 100)
    lang = request.args.get("lang", "en").lower()
    articles = translate_articles(get_news_slice(offset, limit), lang)
    return jsonify({"success": True, "data": articles, "total": dataset_meta["total_count"]})

@app.route("/news/digest")
def get_digest():
    limit = min(int(request.args.get("limit", 3)), 10)
    # Return a few articles from the REAL section (starts at fake_count)
    ensure_dataset_indexed()
    articles = get_news_slice(dataset_meta["fake_count"], limit)
    return jsonify({"success": True, "data": articles})

@app.route("/news/search")
def search_news():
    query = request.args.get("q", "").lower()
    limit = min(int(request.args.get("limit", 10)), 50)
    # Partial search in the first 1000 rows
    pool = get_news_slice(0, 500) + get_news_slice(dataset_meta["fake_count"], 500)
    results = [a for a in pool if query in a["title"].lower() or query in a["full_text"].lower()]
    return jsonify({"success": True, "data": results[:limit]})

@app.route("/predict", methods=["POST"])
def predict():
    pipe = get_pipeline()
    if not pipe: return jsonify({"success": False, "message": "Model offline"}), 503
    data = request.json or {}
    text = f"{data.get('title','')} {data.get('text','')}".strip()
    if not text: return jsonify({"success": False, "message": "No input"}), 400
    proba = pipe.predict_proba([text])[0]
    is_real = proba[1] >= 0.5
    return jsonify({
        "label": "REAL" if is_real else "FAKE",
        "confidence": round(float(proba[1] if is_real else proba[0]), 4)
    })

@app.route("/news/live")
def get_live_news():
    pipe = get_pipeline()
    section = request.args.get("section", "All")
    limit = min(int(request.args.get("limit", 10)), 20)
    g_section = GUARDIAN_SECTIONS.get(section, "news")
    
    try:
        r = http_requests.get(f"{GUARDIAN_BASE}/search", params={
            "api-key": GUARDIAN_API_KEY, "section": g_section,
            "show-fields": "headline,trailText,bodyText", "page-size": limit
        }, timeout=10)
        items = r.json().get("response", {}).get("results", [])
        articles = []
        for i, it in enumerate(items):
            f = it.get("fields", {})
            title, body = f.get("headline", ""), f.get("bodyText", "")
            label = "REAL"
            conf = 1.0
            if pipe:
                p = pipe.predict_proba([f"{title} {body}"])[0]
                label = "REAL" if p[1] >= 0.5 else "FAKE"
                conf = round(float(p[1] if label=="REAL" else p[0]), 4)
            
            articles.append({
                "id": 90000 + i, "title": title, "summary": f.get("trailText", "")[:300],
                "full_text": body, "label": label, "confidence": conf, "source": "The Guardian",
                "published": it.get("webPublicationDate", ""), "is_live": True
            })
        return jsonify({"success": True, "data": articles})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

@app.route("/api/bot/ask", methods=["POST"])
def bot_ask():
    msg = request.json.get("message", "").strip()
    if not msg: return jsonify({"success": False}), 400
    try:
        model = genai.GenerativeModel("gemini-1.5-flash")
        response = model.generate_content(msg)
        return jsonify({"success": True, "reply": response.text})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port)
