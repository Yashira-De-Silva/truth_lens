import json
import google.generativeai as genai
genai.configure(api_key="AIzaSyBLj3XLZMQSqSDAi0gpb1tWu5avKFTYowk")
model = genai.GenerativeModel("gemma-3-27b-it")
prompt = """
You are a highly accurate fact-checker. 
The current date is April 2026. 
Determine if the following claim is true (REAL) or false/misleading (FAKE).
Claim: "president of usa is Donald trumph"

Respond ONLY with a valid JSON object matching this exact schema and nothing else:
{"label": "REAL", "confidence": 0.99} 
"""
print(model.generate_content(prompt).text)
