import requests
import json

def test_verify(title, text):
    url = "http://localhost:10000/api/predict"
    payload = {"title": title, "text": text}
    headers = {"Content-Type": "application/json"}
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        print(f"--- Testing: {title} ---")
        print(f"Status Code: {response.status_code}")
        print(json.dumps(response.json(), indent=2))
        print("\n")
    except Exception as e:
        print(f"Error testing: {e}")

if __name__ == "__main__":
    # Test 1: Real news with potential typos
    test_verify("Presifent of Sri Inka", "ranil is the presifent of sri lnka")
    
    # Test 2: Fake news with potential typos
    test_verify("Presifent of Sri Inka", "donuld trumph is the presifent of sri lnka")
    
    # Test 3: Recent political event (if known)
    test_verify("AKD Wins Election", "Anura Kumara Dissanayake is the new president of Sri Lanka")
