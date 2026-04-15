"""
TruthLens — Python ML Service (Logic-Only Mode)
==============================================
Offloads all data-handling to TiDB for 100% stability on 512MB RAM.
This service now only handles ML Predictions and AI Chat.

Endpoints:
  GET  /health              — Health check + RAM stats
  POST /predict             — Lazy-loaded ML classification
  POST /api/bot/ask         — AI Chatbot
  GET  /news/live           — Guardian API live news + ML labeling
"""

import os
import gc
import logging
import signal
from typing import Optional, Any

from flask import Flask, jsonify, request
from flask_cors import CORS
import requests as http_requests

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
GEMINI_API_KEY   = os.environ.get("GEMINI_API_KEY", "AIzaSyBLj3XLZMQSqSDAi0gpb1tWu5avKFTYowk")

# ── Global State ──────────────────────────────────────────────────────────────
pipeline: Optional[Any] = None

def get_pipeline():
    """Hyper-Lazy model loading. Only loads when someone hits /predict."""
    global pipeline
    if pipeline is None and os.path.exists(MODEL_PATH):
        try:
            log.info("Importing ML libraries and loading model…")
            import joblib
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
        "status": "online", 
        "service": "TruthLens ML Logic Service",
        "description": "ML Predictions & AI Chat (Data-Free Mode)"
    })

@app.route("/health")
def health():
    try:
        import psutil
        process = psutil.Process(os.getpid())
        ram_usage = process.memory_info().rss / 1024 / 1024
    except:
        ram_usage = 0
    return jsonify({
        "status": "ok", 
        "ram_mb": round(ram_usage, 2),
        "model_in_ram": pipeline is not None
    })

@app.route("/predict", methods=["POST"])
def predict():
    data = request.json or {}
    text = f"{data.get('title','')} {data.get('text','')}".strip()
    if not text: return jsonify({"success": False, "message": "No input"}), 400
    
    try:
        import google.generativeai as genai
        import json
        from datetime import datetime
        if GEMINI_API_KEY: genai.configure(api_key=GEMINI_API_KEY)
        now = datetime.now()
        date_str = now.strftime("%B %Y")
        
        prompt = f"""
        You are a highly accurate fact-checker for the TruthLens app. 
        The current date is {date_str}.
        Determine if the fundamental claim being made is factually TRUE (REAL) or FALSE/MISLEADING (FAKE).
        Ignore minor typos (e.g. "trumph" instead of "Trump"). Look at the core fact.
        Claim: "{text}"
        
        Respond ONLY with a valid JSON object matching this exact schema:
        {{"label": "REAL", "confidence": 0.99, "reason": "A short, 1-2 sentence explanation of why this claim is true or false based on your knowledge."}} 
        (use "REAL" if true, "FAKE" if false).
        """
        model = genai.GenerativeModel("gemma-3-27b-it")
        response = model.generate_content(prompt)
        
        resp_text = response.text.strip()
        if resp_text.startswith("```json"): resp_text = resp_text[7:-3].strip()
        elif resp_text.startswith("```"): resp_text = resp_text[3:-3].strip()
        
        result = json.loads(resp_text)
        return jsonify({
            "label": result.get("label", "FAKE"),
            "confidence": result.get("confidence", 0.95),
            "reason": result.get("reason", "No detailed reasoning was provided.")
        })
    except Exception as e:
        log.error(f"Predict error via Gemini (Falling back to offline model): {e}")
        pipe = get_pipeline()
        if not pipe: return jsonify({"success": False, "message": "ML Model Offline"}), 503
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
    limit = min(int(request.args.get("limit", 5)), 20)

    try:
        # Build params — omit 'section' when "All" because Guardian returns
        # 0 results for the non-existent section "all".
        params = {
            "api-key": GUARDIAN_API_KEY,
            "show-fields": "headline,trailText,bodyText",
            "page-size": limit,
            "order-by": "newest",
        }
        if section.lower() != "all":
            params["section"] = section.lower()

        log.info(f"Guardian request: section={section}, limit={limit}")
        r = http_requests.get(f"{GUARDIAN_BASE}/search", params=params, timeout=20)
        log.info(f"Guardian response status: {r.status_code}")

        if r.status_code != 200:
            log.error(f"Guardian API error: {r.status_code} — {r.text[:200]}")
            return jsonify({"success": False, "data": [], "error": f"Guardian API returned {r.status_code}"}), 502

        guardian_body = r.json()
        resp = guardian_body.get("response", {})
        if resp.get("status") != "ok":
            log.error(f"Guardian API status not ok: {resp.get('status')} — {resp.get('message', '')}")
            return jsonify({"success": False, "data": [], "error": f"Guardian: {resp.get('message', 'unknown error')}"}), 502

        items = resp.get("results", [])
        log.info(f"Guardian returned {len(items)} articles")

        articles = []
        for i, it in enumerate(items):
            f = it.get("fields", {})
            title = f.get("headline", "")
            body  = f.get("bodyText", "")

            # Default to UNKNOWN if ML fails so news still loads
            label, conf = "UNKNOWN", 0.0

            try:
                if pipe:
                    # Truncate body to first 1000 chars for faster prediction
                    ml_text = f"{title} {body[:1000]}"
                    p = pipe.predict_proba([ml_text])[0]
                    label = "REAL" if p[1] >= 0.5 else "FAKE"
                    conf = round(float(p[1] if label=="REAL" else p[0]), 4)
            except Exception as ml_err:
                log.warning(f"ML prediction failed for article {i}: {ml_err}")

            articles.append({
                "id": 90000 + i, "title": title, "summary": f.get("trailText", "")[:300],
                "full_text": body, "label": label, "confidence": conf, "source": "The Guardian",
                "published": it.get("webPublicationDate", ""), "is_live": True
            })
        return jsonify({"success": True, "data": articles})
    except http_requests.exceptions.Timeout:
        log.error("Guardian API request timed out")
        return jsonify({"success": False, "data": [], "error": "Guardian API timed out"}), 504
    except http_requests.exceptions.ConnectionError as ce:
        log.error(f"Guardian API connection error: {ce}")
        return jsonify({"success": False, "data": [], "error": "Cannot reach Guardian API"}), 502
    except Exception as e:
        log.error(f"Live news error: {e}", exc_info=True)
        return jsonify({"success": False, "data": [], "error": str(e)}), 500

@app.route("/api/bot/ask", methods=["POST"])
def bot_ask():
    msg = request.json.get("message", "").strip()
    if not msg: return jsonify({"success": False}), 400
    try:
        import google.generativeai as genai
        from datetime import datetime
        if GEMINI_API_KEY: genai.configure(api_key=GEMINI_API_KEY)
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S %Z")
        system_prompt = (
            f"You are TruthBot, an AI assistant inside the TruthLens app — a news verification platform. "
            f"The current date and time is: {now}. "
            f"You help users verify news, fact-check claims, and provide accurate, up-to-date information. "
            f"Keep responses concise and helpful."
        )
        model = genai.GenerativeModel("gemma-3-27b-it")
        full_msg = system_prompt + "\n\nUser Message: " + msg
        response = model.generate_content(full_msg)
        return jsonify({"success": True, "reply": response.text})
    except Exception as e:
        log.error(f"Bot ask error: {e}", exc_info=True)
        return jsonify({"success": False, "message": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port)
