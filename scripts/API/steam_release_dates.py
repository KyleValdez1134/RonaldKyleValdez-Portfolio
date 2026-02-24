import requests
import sqlite3
import csv
import json
import time
from datetime import datetime
import os

# Ensure folders exist
os.makedirs("./data/csv", exist_ok=True)
os.makedirs("./data/json", exist_ok=True)
os.makedirs("./data/sqlite/db", exist_ok=True)

# Connect to SQLite
conn = sqlite3.connect("./data/sqlite/db/deals.db")
cursor = conn.cursor()

# Ensure release_dates table exists
cursor.execute("""
CREATE TABLE IF NOT EXISTS release_dates (
    game_id INTEGER PRIMARY KEY,
    title TEXT,
    platform TEXT,
    release_date TEXT,
    timestamp TEXT
)
""")

# Fetch appids from steam_appids table
cursor.execute("SELECT appid, name FROM steam_appids Limit 30")
apps = cursor.fetchall()

records = []

for appid, name in apps[:100]:  # batch size for testing
    url = f"https://store.steampowered.com/api/appdetails?appids={appid}&l=english&cc=us"
    try:
        response = requests.get(url)
        if response.status_code == 200 and response.text.strip():
            data = response.json()
            app_data = data.get(str(appid), {}).get("data", {})
            if app_data:
                release_info = app_data.get("release_date", {})
                record = {
                    "game_id": appid,
                    "title": name,
                    "platform": "Steam",
                    "release_date": release_info.get("date"),
                    "timestamp": datetime.now().isoformat()
                }
                records.append(record)
        time.sleep(0.2)  # polite delay
    except Exception as e:
        print(f"Error fetching {appid}: {e}")

# Save results
if records:
    # --- SQLite ---
    cursor.executemany("""
    INSERT OR REPLACE INTO release_dates
    (game_id, title, platform, release_date, timestamp)
    VALUES (:game_id, :title, :platform, :release_date, :timestamp)
    """, records)
    conn.commit()
    conn.close()

    # --- CSV ---
    csv_file = "./data/csv/release_dates.csv"
    with open(csv_file, "a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=records[0].keys())
        if f.tell() == 0:  # write header if file is empty
            writer.writeheader()
        writer.writerows(records)

    # --- JSON ---
    json_file = "./data/json/release_dates.json"
    existing = []
    if os.path.exists(json_file):
        with open(json_file, "r", encoding="utf-8") as f:
            existing = json.load(f)
    existing.extend(records)
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(existing, f, indent=4)

    print(f"Appended {len(records)} release dates into SQLite, CSV, and JSON.")
else:
    print("No release dates found.")
