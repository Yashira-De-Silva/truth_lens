import json
import google.generativeai as genai
genai.configure(api_key="AIzaSyBLj3XLZMQSqSDAi0gpb1tWu5avKFTYowk")
model = genai.GenerativeModel("gemma-3-27b-it")
prompt = """
You are a highly accurate fact-checker for the TruthLens app. 
The current date is April 2026.
Determine if the fundamental claim being made is factually TRUE (REAL) or FALSE/MISLEADING (FAKE).
Ignore minor typos (e.g. "trumph" instead of "Trump"). Look at the core fact.
Claim: "president of usa is Donald trumph"

Respond ONLY with a valid JSON object matching this exact schema:
{"label": "REAL", "confidence": 0.99}
"""
print(model.generate_content(prompt).text)
