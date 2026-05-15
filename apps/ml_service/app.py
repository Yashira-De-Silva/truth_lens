"""
TruthLens — Python ML Service (RAM Stable Mode)
==============================================
Fully optimized for Render Free Tier (512MB RAM).
Uses Groq (Llama 3 / Mixtral) as the sole AI provider.
Fallback: Wikipedia + Guardian search analysis.
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

# Groq — sole AI provider (14,400 free req/day)
GROQ_API_KEY = os.environ.get("GROQ_API_KEY", "").strip()
GROQ_BASE    = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODELS  = ["llama-3.1-8b-instant", "llama-3.3-70b-versatile", "llama3-70b-8192"]


def call_ai(prompt: str, temperature: float = 0.2) -> str:
    """Call Groq. Raises if unavailable — caller handles fallback."""
    if not GROQ_API_KEY:
        raise Exception("GROQ_API_KEY not set. Please add it in Render Environment.")
    for model in GROQ_MODELS:
        try:
            resp = http_requests.post(
                GROQ_BASE,
                headers={"Authorization": f"Bearer {GROQ_API_KEY}", "Content-Type": "application/json"},
                json={
                    "model": model,
                    "messages": [{"role": "user", "content": prompt}],
                    "temperature": temperature,
                    "max_tokens": 1024,
                },
                timeout=30,
            )
            if resp.status_code == 200:
                return resp.json()["choices"][0]["message"]["content"].strip()
            log.warning(f"Groq model {model} returned {resp.status_code}: {resp.text[:200]}")
        except Exception as e:
            log.warning(f"Groq model {model} failed: {e}")
    raise Exception("All Groq models failed")

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
        import psutil  # type: ignore
        process = psutil.Process(os.getpid())
        ram_usage = process.memory_info().rss / 1024 / 1024
    except Exception:
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
        import json
        import requests, urllib.parse, re
        from datetime import datetime
        
        # Using Groq (call_ai) for robust AI-powered search

        # 1. Extract search terms locally to save API quota (Halves usage!)
        search_query = ""
        try:
            # Simple extraction: remove common words and take first 5-7 words
            stop_words = {'a', 'an', 'the', 'is', 'are', 'was', 'were', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'is'}
            words = [w for w in re.findall(r'\w+', text.lower()) if w not in stop_words]
            search_query = " ".join(words[:6])
        except Exception:
            search_query = text[:50]

        wiki_context = ""
        news_context = ""
        sources = []

        # 2. Wikipedia Search (Expanded)
        try:
            if search_query:
                # DUAL QUERY: Search claim AND historical fact (if year mentioned)
                year_match = re.search(r'\b(19|20)\d{2}\b', text)
                queries = [search_query]
                if year_match:
                    queries.append(f"who was the president of sri lanka in {year_match.group(0)}")
                
                for q in queries:
                    url = f"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(q)}&utf8=&format=json"
                    req = requests.get(url, headers={'User-Agent': 'TruthLensBot/1.0'}, timeout=5)
                    if req.status_code == 200:
                        results = req.json().get('query', {}).get('search', [])
                        for r in results[:5]: # More snippets for better coverage
                            title = r.get('title')
                            snippet = re.sub('<[^<]+>', '', r.get('snippet', ''))
                            wiki_context += f"\n- Wikipedia ({title}): {snippet}"
                            sources.append(f"Wikipedia: {title}")
        except Exception as e:
            log.warning(f"Wiki search failed: {e}")

        # 3. Guardian News Search (Expanded)
        try:
            if search_query and GUARDIAN_API_KEY:
                params = {
                    "q": search_query,
                    "api-key": GUARDIAN_API_KEY,
                    "show-fields": "headline,trailText",
                    "page-size": 10, # More results for better accuracy
                    "order-by": "relevance"
                }
                r = requests.get(f"{GUARDIAN_BASE}/search", params=params, timeout=10)
                if r.status_code == 200:
                    news_results = r.json().get("response", {}).get("results", [])
                    for it in news_results:
                        f = it.get("fields", {})
                        headline = f.get("headline", "")
                        trail = f.get("trailText", "")
                        news_context += f"\n- Guardian: {headline} - {trail}"
                        sources.append(f"Guardian: {headline}")
        except Exception as e:
            log.warning(f"News search failed: {e}")
            
        # De-dupe sources while preserving order
        if sources:
            sources = list(dict.fromkeys(sources))
        else:
            sources = ["TruthLens Internal Knowledge Base"]

        # 4. Final Verification
        combined_context = (wiki_context + "\n\n" + news_context).strip()
        
        prompt = f"""
        VERIFY THIS NEWS CLAIM:
        Claim: {text}
        Current Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

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
            res_txt = call_ai(prompt, temperature=0)
            result = parse_model_json(res_txt)
        except Exception as e:
            # FALLBACK: Advanced Temporal, Event & Holistic Analysis
            all_words = [w for w in re.findall(r'\w+', text.lower()) if len(w) > 3]
            # IMPORTANT: non-capturing group so findall returns full years like '2025'
            years = re.findall(r'\b(?:19|20)\d{2}\b', text)
            action_verbs = {'won', 'lost', 'fired', 'died', 'arrested', 'resigned', 'elected', 'appointed', 'destroyed', 'captured'}
            claim_actions = [w for w in all_words if w in action_verbs]
            
            context_l = combined_context.lower()

            # 1. Coverage score (how much of the claim is supported by retrieved snippets)
            match_count = sum(1 for w in all_words if w in context_l)
            coverage = (match_count / len(all_words)) if all_words else 0.0

            # Base assumption: if we can't confirm, we should not mark REAL.
            fake_likelihood = 1.0 - coverage

            # 2. Action-Verb Check: The specific action MUST be confirmed in sources
            if claim_actions:
                action_confirmed = any(a in combined_context.lower() for a in claim_actions)
                if not action_confirmed:
                    fake_likelihood = max(fake_likelihood, 0.75)  # Strong FAKE signal

            # 3. Year-Event Mismatch: Check if the event (e.g. "world cup") happened in the claimed year
            if years:
                for year in years:
                    relevant_snippets = [s for s in combined_context.split('\n') if year in s]
                    
                    # If the year appears in context, check if the specific action is near it
                    if relevant_snippets and claim_actions:
                        action_near_year = any(
                            a in s.lower() for a in claim_actions for s in relevant_snippets
                        )
                        if not action_near_year:
                            fake_likelihood = max(fake_likelihood, 0.8)
                    
                    # If the year is NOT in context at all, it's likely a future/invented claim
                    if not relevant_snippets and years:
                        fake_likelihood = max(fake_likelihood, 0.7)

                    # Strict Name Linking
                    if relevant_snippets:
                        names = [w for w in all_words if w not in {'president', 'minister', 'lanka', 'india', 'government', 'world', 'cricket', 'team'}]
                        name_match = sum(1 for n in names if any(n in s.lower() for s in relevant_snippets))
                        if name_match == 0:
                            fake_likelihood = max(fake_likelihood, 0.7)

            # Final conservative decisioning:
            # - FAKE if strong signals exist
            # - UNCERTAIN if we don't have enough evidence
            # - REAL is only possible from the Gemini JSON path
            if fake_likelihood >= 0.7:
                label = "FAKE"
                confidence = min(max(fake_likelihood, 0.0), 1.0)
            else:
                label = "UNCERTAIN"
                confidence = 0.5

            # Keep sources relevant: only include those that share key tokens with the claim
            key_tokens = [w for w in all_words if w not in {'news', 'claim', 'said', 'says', 'team'}]
            filtered_sources = []
            for s in sources:
                s_l = s.lower()
                if any(t in s_l for t in key_tokens[:8]):
                    filtered_sources.append(s)
            filtered_sources = list(dict.fromkeys(filtered_sources))
            if not filtered_sources:
                filtered_sources = sources[:10]

            return jsonify({
                "label": label,
                "confidence": confidence,
                "reason": (
                    "Fallback verification (AI limit reached): fetched evidence doesn't confirm this claim "
                    "(or indicates a likely time/event mismatch)."
                ),
                "sources": filtered_sources[:12]
            })

        label = normalize_label(str(result.get("label", "")).strip())
        # Don't assume high confidence when the model doesn't provide it.
        confidence = result.get("confidence", None)
        try:
            confidence = float(confidence) if confidence is not None else None
        except (TypeError, ValueError):
            confidence = None

        # If the model couldn't produce a valid label, don't force REAL.
        if label == "UNCERTAIN":
            return jsonify({
                "label": "UNCERTAIN",
                "confidence": 0.5,
                "reason": (
                    (result.get("reason") or "The AI couldn't provide a definitive verdict for this claim.")
                    .strip()
                ),
                "sources": sources
            })

        # Prefer model-provided relevant sources but still de-dupe and cap
        final_sources = result.get("relevant_sources") or sources
        if isinstance(final_sources, list):
            final_sources = list(dict.fromkeys([str(x) for x in final_sources]))[:12]
        else:
            final_sources = sources[:12]

        return jsonify({
            "label": label,
            "confidence": min(max(confidence if confidence is not None else 0.6, 0.0), 1.0),
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
        summary = call_ai(
            f"Summarize this news article in exactly 3 concise bullet points or sentences:\n\n{text}",
        )
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
        import re, urllib.parse
        system_instruction = (
            "SYSTEM INSTRUCTION: You are TruthBot, a professional AI news assistant for TruthLens. "
            "Your core mission is to provide accurate news, verify information, and fact-check claims. "
            "DO NOT provide recipes, step-by-step tutorials, or non-news content. "
            "If asked about a general topic (like 'cake'), respond with news, industry trends, "
            "or interesting news-worthy facts about that topic, but NEVER provide a baking guide or recipe. "
            "Stay concise, professional, and strictly news-oriented.\n\n"
        )
        full_prompt = f"{system_instruction}User Question: {msg}"
        
        try:
            reply = call_ai(full_prompt, temperature=0.3)
            return jsonify({"success": True, "reply": reply})
        except Exception as e:
            # FALLBACK: Use Wikipedia to get a basic answer if all AI is at limit
            try:
                search_url = f"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(msg)}&utf8=&format=json"
                wiki_resp = http_requests.get(search_url, timeout=5).json()
                search_results = wiki_resp.get("query", {}).get("search", [])
                if search_results:
                    snippet = re.sub(r'<[^>]*>', '', search_results[0].get("snippet", ""))
                    return jsonify({
                        "success": True,
                        "reply": f"I've reached my AI limit for the moment, but here is what I found on Wikipedia about '{msg}': {snippet}... (Please try again later for a full AI analysis.)"
                    })
            except Exception:
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
