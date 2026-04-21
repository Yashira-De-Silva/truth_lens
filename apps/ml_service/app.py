"""
TruthLens — Python ML Service (RAM Stable Mode)
==============================================
Fully optimized for Render Free Tier (512MB RAM).
Uses Google Gemini (Gemma-3) for all classification tasks.
Removed scikit-learn to prevent OOM (Out of Memory) crashes.
"""

import os
import logging
from typing import Optional, Any

from flask import Flask, jsonify, request
from flask_cors import CORS
import requests as http_requests

# Setup logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# ── Config ────────────────────────────────────────────────────────────────────
GUARDIAN_API_KEY = os.environ.get("GUARDIAN_API_KEY", "c6d32650-a403-4157-8569-4e39624a022d")
GUARDIAN_BASE    = "https://content.guardianapis.com"
GEMINI_API_KEY   = os.environ.get("GEMINI_API_KEY", "AIzaSyBLj3XLZMQSqSDAi0gpb1tWu5avKFTYowk")

# ── Routes ────────────────────────────────────────────────────────────────────

@app.route("/")
@app.route("/api/")
def home():
    return jsonify({
        "status": "online", 
        "service": "TruthLens ML Service (Stable)",
        "description": "100% Gemini-powered news verification."
    })

@app.route("/health")
@app.route("/api/health")
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
        "engine": "Google Gemini"
    })

@app.route("/api/predict", methods=["POST"])
def predict():
    data = request.json or {}
    text = f"{data.get('title','')} {data.get('text','')}".strip()
    if not text: return jsonify({"success": False, "message": "No input"}), 400
    
    try:
        import google.generativeai as genai
        import json
        import requests, urllib.parse, re
        from datetime import datetime
        
        if GEMINI_API_KEY: genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel("gemma-3-27b-it")

        # Wikipedia search logic remains the same
        search_query = ""
        try:
            kw_prompt = f"Extract the single specific entity to search on Wikipedia to verify: '{text}'"
            kw_resp = model.generate_content(kw_prompt)
            search_query = kw_resp.text.strip().replace('"', '')
        except Exception:
            search_query = text[:30]

        wiki_context = ""
        sources = []
        try:
            if search_query:
                url = f"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(search_query)}&utf8=&format=json"
                req = requests.get(url, headers={'User-Agent': 'TruthLensBot/1.0'}, timeout=5)
                if req.status_code == 200:
                    results = req.json().get('query', {}).get('search', [])
                    snippets = [f"- {r.get('title')}: {re.sub('<[^<]+>', '', r.get('snippet', ''))}" for r in results[:3]]
                    sources = [f"Wikipedia: {r.get('title')}" for r in results[:3]]
                    if snippets: wiki_context = "Context:\n" + "\n".join(snippets)
        except: pass
            
        if not sources: sources = ["TruthLens Internal Knowledge Base"]

        now = datetime.now().strftime("%B %Y")
        prompt = f"""
        You are a fact-checker. Date: {now}.
        Claim: "{text}"
        Context: {wiki_context}
        Instructions: Verify the claim. Handle acronyms like 'AKD' = Anura Kumara Dissanayake. 
        Respond ONLY with JSON: {{"label": "REAL", "confidence": 0.99, "reason": "why..."}}
        """
        response = model.generate_content(prompt)
        res_txt = response.text.strip()
        if "```" in res_txt: res_txt = res_txt.split("```")[1].replace("json", "").strip()
        
        result = json.loads(res_txt)
        return jsonify({
            "label": result.get("label", "FAKE"),
            "confidence": result.get("confidence", 0.95),
            "reason": result.get("reason", "Verified via AI reasoning."),
            "sources": sources
        })
    except Exception as e:
        log.error(f"Predict error: {e}")
        return jsonify({"success": False, "message": f"ML Service Bus: {str(e)}"}), 503

@app.route("/api/news/live")
def get_live_news():
    section = request.args.get("section", "All")
    limit = min(int(request.args.get("limit", 5)), 20)

    try:
        params = {
            "api-key": GUARDIAN_API_KEY,
            "show-fields": "headline,trailText,bodyText",
            "page-size": limit,
            "order-by": "newest",
        }
        if section.lower() != "all": params["section"] = section.lower()

        r = http_requests.get(f"{GUARDIAN_BASE}/search", params=params, timeout=20)
        if r.status_code != 200:
            return jsonify({"success": True, "data": get_fallback_news()})

        items = r.json().get("response", {}).get("results", [])
        if not items: return jsonify({"success": True, "data": get_fallback_news()})

        articles = []
        for i, it in enumerate(items):
            f = it.get("fields", {})
            articles.append({
                "id": 90000 + i, "title": f.get("headline", ""), "summary": f.get("trailText", "")[:300],
                "full_text": f.get("bodyText", ""), "label": "VERIFYING", "confidence": 0.5, "source": "The Guardian",
                "published": it.get("webPublicationDate", ""), "is_live": True
            })
        return jsonify({"success": True, "data": articles})
    except Exception as e:
        log.error(f"Live news error: {e}")
        return jsonify({"success": True, "data": get_fallback_news()})

def get_fallback_news():
    return [
        {
            "id": 1, "title": "Global Climate Summit Reaches Landmark Agreement",
            "summary": "World leaders have agreed on a new framework to accelerate the transition to renewable energy by 2030...",
            "full_text": "Detailed reports indicate a shift towards mandatory carbon credits...",
            "label": "REAL", "confidence": 0.98, "source": "TruthLens Archive", "published": "2024-04-20T10:00:00Z", "is_live": True
        }
    ]

@app.route("/api/bot/ask", methods=["POST"])
def bot_ask():
    msg = request.json.get("message", "").strip()
    if not msg: return jsonify({"success": False}), 400
    try:
        import google.generativeai as genai
        if GEMINI_API_KEY: genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel("gemma-3-27b-it")
        response = model.generate_content(f"Concise TruthLens AI response for: {msg}")
        return jsonify({"success": True, "reply": response.text})
    except Exception as e:
        log.error(f"Bot error: {e}")
        return jsonify({"success": False, "message": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port, threaded=True)
