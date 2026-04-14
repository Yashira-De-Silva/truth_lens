"""
TruthLens — Python ML Service (Nuclear Mode - No Pandas)
======================================================
Hardened for 512MB RAM using native Python CSV streaming.

Endpoints:
  GET  /health              — Health check + RAM stats
  GET  /news                — Native CSV streaming articles
  GET  /news/live           — Guardian API live news + ML labeling
  GET  /news/digest         — Top articles
  GET  /news/search         — Keyword search (native)
  POST /predict             — Classify custom title/text
  POST /api/bot/ask         — AI Chatbot
"""

import os
import re
import csv
import gc
import signal
import joblib
import random
import logging
import subprocess
from itertools import islice
from typing import Optional, List, Dict, Any

import kagglehub
import requests as http_requests
from flask import Flask, jsonify, request
from flask_cors import CORS
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

# Memory Guard: Cap dataset at 10k real / 10k fake
MAX_ROWS_PER_TYPE = 10000 

GUARDIAN_SECTIONS = {
    "All": "news", "Politics": "politics", "Business": "business", "Technology": "technology",
    "Science": "science", "Health": "society", "Sports": "sport", "Entertainment": "film",
}

# ── Global State ──────────────────────────────────────────────────────────────
pipeline: Optional[Any] = None
dataset_meta = {
    "fake_csv": None, "true_csv": None,
    "fake_count": 0, "true_count": 0,
    "total_count": 0, "loaded": False
}

# ── Native CSV Streaming Logic ───────────────────────────────────────────────

def ensure_dataset_indexed():
    """Locate dataset without scanning. Fast and Memory-Efficient."""
    global dataset_meta
    if dataset_meta["loaded"]: return

    log.info("Indexing dataset natively (Skip scan) …")
    try:
        path = kagglehub.dataset_download("emineyetm/fake-news-detection-datasets")
        for root, _, files in os.walk(path):
            for f in files:
                if "fake" in f.lower() and f.endswith(".csv"):
                    dataset_meta["fake_csv"] = os.path.join(root, f)
                if "true" in f.lower() and f.endswith(".csv"):
                    dataset_meta["true_csv"] = os.path.join(root, f)

        if dataset_meta["fake_csv"] and dataset_meta["true_csv"]:
            dataset_meta.update({
                "fake_count": MAX_ROWS_PER_TYPE,
                "true_count": MAX_ROWS_PER_TYPE,
                "total_count": MAX_ROWS_PER_TYPE * 2,
                "loaded": True
            })
            log.info("Dataset indexed with Memory Guard ✅")
        gc.collect()
    except Exception as e:
        log.error(f"Dataset indexing failed: {e}")

def get_news_slice(offset: int, limit: int) -> List[Dict]:
    """Fetch rows using native Python CSV DictReader (Zero Pandas)."""
    ensure_dataset_indexed()
    articles = []
    
    f_total = dataset_meta["fake_count"]
    t_total = dataset_meta["true_count"]

    curr_off = offset
    curr_lim = limit

    # Part 1: Fake News
    if curr_off < f_total:
        take = min(curr_lim, f_total - curr_off)
        articles.extend(_read_csv_rows(dataset_meta["fake_csv"], curr_off, take, 0))
        curr_lim -= take
        curr_off = 0
    else:
        curr_off -= f_total

    # Part 2: True News
    if curr_lim > 0 and curr_off < t_total:
        take = min(curr_lim, t_total - curr_off)
        articles.extend(_read_csv_rows(dataset_meta["true_csv"], curr_off, take, 1))

    gc.collect()
    return articles

def _read_csv_rows(path: str, offset: int, limit: int, label_int: int) -> List[Dict]:
    """Iterate through CSV one row at a time. High memory efficiency."""
    res = []
    try:
        with open(path, mode='r', encoding='utf-8', errors='ignore') as f:
            reader = csv.DictReader(f)
            # Efficiently skip to offset and take limit
            rows = islice(reader, offset, offset + limit)
            for i, row in enumerate(rows):
                title = row.get("title", "No Title")
                text = row.get("text", "")
                res.append({
                    "id": f"{label_int}_{offset + i}",
                    "title": str(title)[:200],
                    "summary": str(text)[:300] + ("…" if len(text) > 300 else ""),
                    "full_text": text,
                    "label": "REAL" if label_int == 1 else "FAKE",
                    "confidence": 1.0,
                    "source": row.get("subject", "Dataset"),
                    "published": row.get("date", "")
                })
    except Exception as e:
        log.error(f"CSV Read error: {e}")
    return res

def get_pipeline():
    """Lazily load scikit-learn model."""
    global pipeline
    if pipeline is None and os.path.exists(MODEL_PATH):
        try:
            pipeline = joblib.load(MODEL_PATH)
            log.info("ML Pipeline loaded into RAM ✅")
            gc.collect()
        except Exception as e:
            log.error(f"Pipeline load failed: {e}")
    return pipeline

# ── Routes ────────────────────────────────────────────────────────────────────

@app.route("/")
def home():
    return jsonify({
        "status": "online", "service": "TruthLens ML Service",
        "mode": "Nuclear (Pandas-free)", "dataset_rows": dataset_meta["total_count"]
    })

@app.route("/health")
def health():
    import psutil
    process = psutil.Process(os.getpid())
    ram_usage = process.memory_info().rss / 1024 / 1024
    return jsonify({
        "status": "ok", "ram_mb": round(ram_usage, 2),
        "model": get_pipeline() is not None
    })

@app.route("/news")
def get_news():
    offset = int(request.args.get("offset", 0))
    limit = min(int(request.args.get("limit", 20)), 50)
    lang = request.args.get("lang", "en").lower()
    
    articles = get_news_slice(offset, limit)
    # Note: Translation library is still kept for feature parity
    if lang != "en":
        try:
            from deep_translator import GoogleTranslator
            translator = GoogleTranslator(source='auto', target=lang)
            for a in articles:
                a["title"] = translator.translate(a["title"][:4999])
                a["summary"] = translator.translate(a["summary"][:4999])
        except: pass
    return jsonify({"success": True, "data": articles, "total": dataset_meta["total_count"]})

@app.route("/news/digest")
def get_digest():
    limit = min(int(request.args.get("limit", 3)), 5)
    ensure_dataset_indexed()
    articles = get_news_slice(dataset_meta["fake_count"], limit)
    return jsonify({"success": True, "data": articles})

@app.route("/news/search")
def search_news():
    query = request.args.get("q", "").lower()
    limit = min(int(request.args.get("limit", 5)), 10)
    if not query: return jsonify({"success": True, "data": []})
    
    # Simple search in small fixed pool (1k rows)
    articles = get_news_slice(0, 500) + get_news_slice(dataset_meta["fake_count"], 500)
    res = [a for a in articles if query in a["title"].lower() or query in a["full_text"].lower()]
    return jsonify({"success": True, "data": res[:limit]})

@app.route("/predict", methods=["POST"])
def predict():
    pipe = get_pipeline()
    if not pipe: return jsonify({"success": False, "message": "Model Offline"}), 503
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
    limit = min(int(request.args.get("limit", 5)), 10)
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
            label, conf = "REAL", 1.0
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
    except:
        return jsonify({"success": False, "data": []}), 500

@app.route("/api/bot/ask", methods=["POST"])
def bot_ask():
    msg = request.json.get("message", "").strip()
    if not msg: return jsonify({"success": False}), 400
    try:
        model = genai.GenerativeModel("gemini-1.5-flash")
        response = model.generate_content(msg)
        return jsonify({"success": True, "reply": response.text})
    except:
        return jsonify({"success": False}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port)
