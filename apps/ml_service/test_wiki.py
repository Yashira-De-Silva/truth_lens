import requests
import urllib.parse
query = "Anura Kumara Dissanayake"
url = f"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(query)}&utf8=&format=json"
r = requests.get(url)
if r.status_code == 200:
    data = r.json()
    if data['query']['search']:
        title = data['query']['search'][0]['title']
        print(f"Top result: {title}")
        extract_url = f"https://en.wikipedia.org/w/api.php?action=query&prop=extracts&exintro&titles={urllib.parse.quote(title)}&format=json&explaintext=1"
        ext_r = requests.get(extract_url).json()
        pages = ext_r['query']['pages']
        for page_id in pages:
            print("Summary:", pages[page_id]['extract'][:300])
