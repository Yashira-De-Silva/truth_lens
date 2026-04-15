import json
import google.generativeai as genai
import os

genai.configure(api_key="AIzaSyBLj3XLZMQSqSDAi0gpb1tWu5avKFTYowk")
model = genai.GenerativeModel("gemini-2.5-flash")
text = "president is Donald trumph"
prompt = f"""
You are a highly accurate fact-checker. 
Determine if the following news/claim is REAL or FAKE. (If it's true as of today, label it REAL).
Claim: "{text}"

Respond ONLY with a JSON object exactly like this:
{{"label": "REAL", "confidence": 0.99}}
"""
response = model.generate_content(prompt)
print(response.text)
