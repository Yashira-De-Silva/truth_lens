import urllib.request, json, os

key = "AIzaSyAYZMNNVcB6BLIgVIQYTOhJ-xqT5qXVimc"
url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={key}"

data = {
    "systemInstruction": {
        "parts": [{"text": "You are Truthbot. Answer briefly."}]
    },
    "contents": [
        {"parts": [{"text": "What is the latest score in the 2026 ipl?"}]}
    ],
    "tools": [{"googleSearch": {}}]
}

req = urllib.request.Request(url, json.dumps(data).encode(), {"Content-Type": "application/json"})
try:
    with urllib.request.urlopen(req) as resp:
        resp_data = json.loads(resp.read().decode())
        print(resp_data["candidates"][0]["content"]["parts"][0]["text"])
except Exception as e:
    print(e)
    if hasattr(e, 'read'):
        print(e.read().decode())
