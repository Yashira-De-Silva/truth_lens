import os
import csv
import mysql.connector
import kagglehub
import time

# --- CONFIGURATION (UPDATE THESE) ---
DB_CONFIG = {
    "host": "gateway01.ap-southeast-1.prod.aws.tidbcloud.com",
    "port": 3306,
    "user": "root", # Should be from your TiDB Dashboard
    "password": "YOUR_TIDB_PASSWORD", # EXTREMELY IMPORTANT: Put your TiDB password here
    "database": "truth_lens",
    "ssl_ca": None # TiDB usually requires SSL. Update if needed.
}

def migrate():
    print("🚀 Starting TiDB Data Migration (45,000 Articles)...")
    
    # 1. Download Dataset
    print("📥 Downloading dataset via kagglehub...")
    path = kagglehub.dataset_download("emineyetm/fake-news-detection-datasets")
    
    csv_files = []
    for root, _, files in os.walk(path):
        for f in files:
            if f.lower().endswith(".csv"):
                csv_files.append(os.path.join(root, f))
    
    fake_csv = next((f for f in csv_files if "fake" in os.path.basename(f).lower()), None)
    true_csv = next((f for f in csv_files if "true" in os.path.basename(f).lower()), None)
    
    if not fake_csv or not true_csv:
        print("❌ Error: Could not find CSV files in the downloaded dataset.")
        return

    # 2. Connect to TiDB
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Connected to TiDB Cloud.")
    except Exception as e:
        print(f"❌ Connection Failed: {e}")
        print("👉 Make sure you put the correct password in migrate_to_tidb.py line 12.")
        return

    # 3. Process CSVs
    files_to_process = [
        (fake_csv, 1), # label: 1 (is_fake=true)
        (true_csv, 0)  # label: 0 (is_fake=false)
    ]
    
    total_inserted = 0
    query = "INSERT INTO news_articles (title, text, subject, date, is_fake, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, NOW(), NOW())"

    for csv_path, is_fake in files_to_process:
        print(f"📄 Processing {os.path.basename(csv_path)}...")
        with open(csv_path, mode='r', encoding='utf-8', errors='ignore') as f:
            reader = csv.DictReader(f)
            batch = []
            for row in reader:
                batch.append((
                    row.get("title", "")[:500],
                    row.get("text", ""),
                    row.get("subject", ""),
                    row.get("date", ""),
                    is_fake
                ))
                
                # Insert in batches of 1000 for performance
                if len(batch) >= 1000:
                    cursor.executemany(query, batch)
                    conn.commit()
                    total_inserted += len(batch)
                    print(f"   🆙 Uploaded {total_inserted} articles...")
                    batch = []
            
            # Final batch
            if batch:
                cursor.executemany(query, batch)
                conn.commit()
                total_inserted += len(batch)

    print(f"🎉 SUCCESS! Total articles migrated: {total_inserted}")
    cursor.close()
    conn.close()

if __name__ == "__main__":
    migrate()
