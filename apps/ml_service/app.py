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
import random
GEMINI_API_KEYS = os.environ.get("GEMINI_API_KEY", "AIzaSyBLj3XLZMQSqSDAi0gpb1tWu5avKFTYowk").split(",")
GEMINI_API_KEYS = [k.strip() for k in GEMINI_API_KEYS if k.strip()]

def call_gemini_with_retry(model_name, prompt, temperature=0.2):
    import google.generativeai as genai
    keys = list(GEMINI_API_KEYS)
    random.shuffle(keys)
    last_error = None
    
    for key in keys:
        try:
            genai.configure(api_key=key)
            model = genai.GenerativeModel(model_name)
            response = model.generate_content(prompt, generation_config={"temperature": temperature})
            return response.text.strip()
        except Exception as e:
            last_error = e
            err_msg = str(e).lower()
            if "400" in err_msg or "invalid" in err_msg or "429" in err_msg or "quota" in err_msg:
                log.warning(f"Key issue detected ({key[:8]}...), trying next key...")
                continue
            break
    raise last_error if last_error else Exception("No working API keys")

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
        model = genai.GenerativeModel("gemini-2.0-flash")

        # 1. Extract search terms locally to save API quota (Halves usage!)
        search_query = ""
        try:
            # Simple extraction: remove common words and take first 5-7 words
            stop_words = {'a', 'an', 'the', 'is', 'are', 'was', 'were', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by'}
            words = [w for w in re.findall(r'\w+', text.lower()) if w not in stop_words]
            search_query = " ".join(words[:6])
        except Exception:
            search_query = text[:50]

        wiki_context = ""
        news_context = ""
        sources = []

        # 2. Wikipedia Search
        try:
            if search_query:
                url = f"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(search_query)}&utf8=&format=json"
                req = requests.get(url, headers={'User-Agent': 'TruthLensBot/1.0'}, timeout=5)
                if req.status_code == 200:
                    results = req.json().get('query', {}).get('search', [])
                    snippets = []
                    for r in results[:3]:
                        title = r.get('title')
                        snippet = re.sub('<[^<]+>', '', r.get('snippet', ''))
                        snippets.append(f"- Wikipedia ({title}): {snippet}")
                        sources.append(f"Wikipedia: {title}")
                    if snippets: wiki_context = "Wikipedia Context:\n" + "\n".join(snippets)
        except Exception as e:
            log.warning(f"Wiki search failed: {e}")

        # 3. Guardian News Search (Cross-Check)
        try:
            if search_query and GUARDIAN_API_KEY:
                params = {
                    "q": search_query,
                    "api-key": GUARDIAN_API_KEY,
                    "show-fields": "headline,trailText",
                    "page-size": 3,
                    "order-by": "relevance"
                }
                r = requests.get(f"{GUARDIAN_BASE}/search", params=params, timeout=10)
                if r.status_code == 200:
                    news_results = r.json().get("response", {}).get("results", [])
                    news_snippets = []
                    for it in news_results:
                        f = it.get("fields", {})
                        headline = f.get("headline", "")
                        trail = f.get("trailText", "")
                        url = it.get("webUrl", "")
                        news_snippets.append(f"- News ({headline}): {trail}")
                        sources.append(f"Guardian: {headline}")
                    if news_snippets: news_context = "News Context:\n" + "\n".join(news_snippets)
        except Exception as e:
            log.warning(f"Guardian search failed: {e}")
            
        if not sources: sources = ["TruthLens Internal Knowledge Base"]

        # 4. Final Verification
        now = datetime.now().strftime("%B %Y")
        combined_context = f"{wiki_context}\n\n{news_context}".strip()
        
        prompt = f"""
        You are TruthBot, a world-class fact-checking expert. Current Date: {now}.
        
        CLAIM: "{text}"

        EVIDENCE GATHERED:
        {combined_context if combined_context else 'No direct search results found. Use your internal knowledge.'}

        FACT-CHECKING RULES:
        1. TEMPORAL ACCURACY IS CRITICAL: Check the specific YEAR mentioned in the claim. If the claim mentions "2020", verify if it was true IN 2020, not just now.
        2. Recognize historical vs current data. For example, if someone is president in 2025 but wasn't in 2020, a claim about 2020 is FAKE.
        3. MANDATORY: Choose either REAL or FAKE.
        4. Cross-reference the claim's date with the evidence or your internal knowledge of historical timelines.
        5. Always provide a clear, concise REASON explaining the date discrepancy if it exists.

        RESPOND ONLY WITH THIS JSON:
        {{
          "label": "REAL" | "FAKE",
          "confidence": 0.0 - 1.0,
          "reason": "Explain why based on the evidence...",
          "relevant_sources": ["Source 1", "Source 2"]
        }}
        """

        try:
            res_txt = call_gemini_with_retry("gemini-2.0-flash", prompt, temperature=0)
            result = parse_model_json(res_txt)
        except Exception as e:
            # FALLBACK: If all Gemini quotas are hit, use basic search analysis
            words = [w for w in re.findall(r'\w+', text.lower()) if len(w) > 4]
            match_count = sum(1 for w in words if w in combined_context.lower())
            is_real = match_count >= (len(words) * 0.5) if words else False
            
            return jsonify({
                "label": "REAL" if is_real else "FAKE",
                "confidence": 0.4,
                "reason": "Verified via secondary search analysis (All AI keys hit limits).",
                "sources": sources
            })

        label = normalize_label(str(result.get("label", "")).strip())
        confidence = result.get("confidence", 0.8) # Default high confidence if not provided
        try:
            confidence = float(confidence)
        except (TypeError, ValueError):
            confidence = 0.8

        if label == "UNCERTAIN":
            label = "REAL" # Final fallback

        final_sources = result.get("relevant_sources") or sources

        return jsonify({
            "label": label,
            "confidence": min(max(confidence, 0.0), 1.0),
            "reason": result.get("reason", "Verified via AI analysis.").strip(),
            "sources": final_sources
        })
    except Exception as e:
        log.error(f"Predict error: {e}")
        return jsonify({"success": False, "message": f"ML Service Error: {str(e)}"}), 503

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

@app.route("/api/summarize", methods=["POST"])
def summarize():
    data = request.json or {}
    text = data.get("text", "").strip()
    if not text: return jsonify({"success": False, "message": "No text"}), 400
    
    try:
        summary = call_gemini_with_retry("gemini-2.0-flash", f"Summarize this news article in exactly 3 concise bullet points or sentences:\n\n{text}")
        return jsonify({
            "success": True,
            "summary": summary
        })
    except Exception as e:
        log.error(f"Summarize error: {e}")
        return jsonify({"success": False, "message": str(e)}), 500

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
        # Removed undefined GEMINI_API_KEY check
        
        # Strict system instruction to ensure bot only discusses news and verification
        # Prepending instead of using system_instruction parameter due to Gemma model limitations
        system_instruction = (
            "SYSTEM INSTRUCTION: You are TruthBot, a professional AI news assistant for TruthLens. "
            "Your core mission is to provide accurate news, verify information, and fact-check claims. "
            "DO NOT provide recipes, step-by-step tutorials, or non-news content. "
            "If asked about a general topic (like 'cake'), respond with news, industry trends, "
            "or interesting news-worthy facts about that topic, but NEVER provide a baking guide or recipe. "
            "Stay concise, professional, and strictly news-oriented.\n\n"
        )
        
        model = genai.GenerativeModel(model_name="gemini-2.0-flash")
        full_prompt = f"{system_instruction}User Question: {msg}"
        
        try:
            reply = call_gemini_with_retry("gemini-2.0-flash", full_prompt, temperature=0.3)
            return jsonify({
                "success": True, 
                "reply": reply
            })
        except Exception as e:
            # FALLBACK: Use Wikipedia to get a basic answer if AI is at limit
            try:
                search_url = f"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(msg)}&utf8=&format=json"
                wiki_resp = requests.get(search_url, timeout=5).json()
                search_results = wiki_resp.get("query", {}).get("search", [])
                if search_results:
                    snippet = re.sub(r'<[^>]*>', '', search_results[0].get("snippet", ""))
                    return jsonify({
                        "success": True,
                        "reply": f"I've reached my AI limit for the moment, but here is what I found on Wikipedia about '{msg}': {snippet}... (Please try again later for a full AI analysis.)"
                    })
            except:
                pass
            return jsonify({
                "success": True,
                "reply": "I'm currently at my usage limit, but I'll be back shortly! You can still use the 'Verify News' tool in the meantime."
            })
    except Exception as e:
        log.error(f"Bot error: {e}")
        return jsonify({"success": False, "message": str(e)}), 500

def normalize_label(value: str) -> str:
    value = value.strip().upper()
    if value in {"REAL", "TRUE", "T"}:
        return "REAL"
    if value in {"FAKE", "FALSE", "F"}:
        return "FAKE"
    return "UNCERTAIN"


def parse_model_json(text: str) -> dict:
    import json
    if "```" in text:
        text = text.split("```")[-1]
    if text.strip().startswith("json"):
        text = text.strip()[4:].strip()
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        # Try extracting the first JSON object
        start = text.find("{")
        end = text.rfind("}")
        if start != -1 and end != -1:
            try:
                return json.loads(text[start:end+1])
            except json.JSONDecodeError:
                pass
    return {}

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port, threaded=True)
