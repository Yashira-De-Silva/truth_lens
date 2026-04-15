import json
import google.generativeai as genai
genai.configure(api_key="AIzaSyBLj3XLZMQSqSDAi0gpb1tWu5avKFTYowk")
model = genai.GenerativeModel("gemma-3-27b-it")

text = "CEO of haylys is harindu"
wiki_context = ""

prompt = f"""
        You are a highly accurate fact-checker for the TruthLens app. 
        Determine if the fundamental claim being made is factually TRUE (REAL) or FALSE/MISLEADING (FAKE).
        Ignore minor typos. Look at the core fact.
        CRITICAL INSTRUCTION: If you cannot verify the claim using the provided Wikipedia context or your own highly certain internal knowledge, you MUST classify it as FAKE and state that there is no credible evidence to support the claim. Do NOT hallucinate or invent facts.
        
        {wiki_context}
        
        Claim: "{text}"
        
        Respond ONLY with a valid JSON object matching this exact schema:
        {{"label": "REAL", "confidence": 0.99, "reason": "A short, 1-2 sentence explanation of why this claim is true or false based on your knowledge and the Wikipedia context."}} 
        (use "REAL" if true, "FAKE" if false).
        """

print(model.generate_content(prompt).text)
