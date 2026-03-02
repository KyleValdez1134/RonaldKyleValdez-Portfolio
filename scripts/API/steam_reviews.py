import requests
import sqlite3
import csv
import json
import time
from datetime import datetime
import os
import argparse

# --- CLI Arguments ---
parser = argparse.ArgumentParser()
parser.add_argument("--limit", type=int, default=20, help="Total appids to pull")
parser.add_argument("--batch", type=int, default=5, help="Process this many per run")
parser.add_argument("--mode", type=str, choices=["w", "a"], default="w", help="Write mode: overwrite (w) or append (a)")
args = parser.parse_args()

APPID_LIMIT = args.limit
BATCH_SIZE = args.batch
WRITE_MODE = args.mode

# Ensure folders exist
os.makedirs("./data/csv", exist_ok=True)
os.makedirs("./data/json", exist_ok=True)
os.makedirs("./data/sqlite/db", exist_ok=True)

# Connect to SQLite
conn = sqlite3.connect("./data/sqlite/db/deals.db")
cursor = conn.cursor()

# Ensure reviews table exists
cursor.execute("""
CREATE TABLE IF NOT EXISTS reviews (
    game_id INTEGER PRIMARY KEY,
    title TEXT,
    platform TEXT,
    review_score TEXT,
    review_count INTEGER,
    timestamp TEXT
)
""")

# Load appids
with open("./data/json/steam_appids.json", "r", encoding="utf-8") as f:
    appids_data = json.load(f)

records = []

for entry in appids_data[:APPID_LIMIT][:BATCH_SIZE]:
    appid = entry["appid"]
    name = entry["name"]

    url = f"https://store.steampowered.com/appreviews/{appid}?json=1&filter=recent&language=english"
    try:
        response = requests.get(url)
        if response.status_code == 200 and response.text.strip():
            data = response.json()
            review_info = data.get("query_summary", {})
            record = {
                "game_id": appid,
                "title": name,
                "platform": "Steam",
                "review_score": review_info.get("review_score_desc"),
                "review_count": review_info.get("total_reviews", 0),
                "timestamp": datetime.now().isoformat()
            }
            records.append(record)
        time.sleep(0.2)
    except Exception as e:
        print(f"Error fetching reviews for {appid}: {e}")

if records:
    # --- SQLite ---
    cursor.executemany("""
    INSERT OR REPLACE INTO reviews
    (game_id, title, platform, review_score, review_count, timestamp)
    VALUES (:game_id, :title, :platform, :review_score, :review_count, :timestamp)
    """, records)
    conn.commit()
    conn.close()

    # --- CSV ---
    csv_file = "./data/csv/reviews.csv"
    with open(csv_file, WRITE_MODE, newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=records[0].keys())
        if WRITE_MODE == "w":
            writer.writeheader()
        writer.writerows(records)

    # --- JSON ---
    json_file = "./data/json/reviews.json"
    if WRITE_MODE == "w":
        with open(json_file, "w", encoding="utf-8") as f:
            json.dump(records, f, indent=4)
    else:  # append mode
        existing = []
        if os.path.exists(json_file):
            with open(json_file, "r", encoding="utf-8") as f:
                existing = json.load(f)
        existing.extend(records)
        with open(json_file, "w", encoding="utf-8") as f:
            json.dump(existing, f, indent=4)

    print(f"{'Appended' if WRITE_MODE=='a' else 'Overwritten'} {len(records)} reviews into SQLite, CSV, and JSON.")
else:
    print("No reviews found.")
