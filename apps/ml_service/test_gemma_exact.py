import json
import google.generativeai as genai
from datetime import datetime
genai.configure(api_key="AIzaSyBLj3XLZMQSqSDAi0gpb1tWu5avKFTYowk")
model = genai.GenerativeModel("gemma-3-27b-it")
now = datetime.now().strftime("%Y-%m-%d")
text = "president of usa is Donald trumph"

prompt = f"""
        You are a highly accurate fact-checker for the TruthLens app. 
        The current date is {now}.
        Determine if the following claim is factually TRUE (REAL) or FALSE/MISLEADING (FAKE).
        Claim: "{text}"
        
        Respond ONLY with a valid JSON object matching this exact schema:
        {{"label": "REAL", "confidence": 0.99}} 
        (use "REAL" if true, "FAKE" if false).
        """
print(model.generate_content(prompt).text)
