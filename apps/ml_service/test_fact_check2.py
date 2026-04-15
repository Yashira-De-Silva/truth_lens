import google.generativeai as genai
genai.configure(api_key="AIzaSyBLj3XLZMQSqSDAi0gpb1tWu5avKFTYowk")
model = genai.GenerativeModel("gemini-2.5-flash")
print(model.generate_content("Who is the president of the USA today in 2026?").text)
