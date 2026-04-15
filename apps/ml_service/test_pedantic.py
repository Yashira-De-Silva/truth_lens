import json
import google.generativeai as genai
genai.configure(api_key="AIzaSyBLj3XLZMQSqSDAi0gpb1tWu5avKFTYowk")
model = genai.GenerativeModel("gemma-3-27b-it")

text = "cheif excecutivve of haylys is mohan pandithage"
wiki_context = "- Hayleys: Mohan Pandithage is the Chairman and Chief Executive of Hayleys."

prompt = f"""
You are a highly accurate fact-checker. Determine if the fundamental claim is factually TRUE (REAL) or FALSE/MISLEADING (FAKE).
CRITICAL INSTRUCTIONS: 
1. Ignore minor typos. Look at the core fact.
2. Do NOT overthink or be pedantic. If the claim correctly identifies ONE of a person's titles or roles according to the context, you MUST classify it as TRUE (REAL), even if the context mentions they hold *other* titles as well (e.g. Chairman). An omission of secondary titles does not make the core fact false.
3. If the context explicitly confirms the pairing (e.g. Mohan Pandithage -> Chief Executive of Hayleys), it is REAL.

Context: {wiki_context}
Claim: "{text}"

Respond ONLY with a valid JSON object matching this exact schema:
{{"label": "REAL", "confidence": 0.99, "reason": "Short explanation"}} 
(use "REAL" if true, "FAKE" if false).
"""

print(model.generate_content(prompt).text)
