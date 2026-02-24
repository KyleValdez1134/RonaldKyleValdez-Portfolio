import requests
import sqlite3
import csv
import json
from datetime import datetime
import os

os.makedirs("./data/csv", exist_ok=True)
os.makedirs("./data/json", exist_ok=True)
os.makedirs("./data/sqlite/db", exist_ok=True)

url = "https://steamspy.com/api.php?request=all"
response = requests.get(url)

records = []
if response.status_code == 200:
    data = response.json()
    for appid, info in data.items():
        records.append({
            "appid": int(appid),
            "name": info.get("name", "Unknown"),
            "timestamp": datetime.now().isoformat()
        })

if records:
    # --- Append to CSV ---
    csv_file = "./data/csv/steam_appids.csv"
    with open(csv_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=records[0].keys())
        writer.writeheader()
        writer.writerows(records)

    # --- Append to JSON ---
    json_file = "./data/json/steam_appids.json"
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(records, f, indent=4)

    # --- Append to SQLite ---
    conn = sqlite3.connect("./data/sqlite/db/deals.db")
    cursor = conn.cursor()
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS steam_appids (
        appid INTEGER PRIMARY KEY,
        name TEXT,
        timestamp TEXT
    )
    """)
    cursor.executemany("""
    INSERT OR REPLACE INTO steam_appids (appid, name, timestamp)
    VALUES (:appid, :name, :timestamp)
    """, records)
    conn.commit()
    conn.close()

    print(f"Inserted {len(records)} Steam appids into CSV, JSON, and SQLite.")
else:
    print("No appids found or API returned empty results.")
