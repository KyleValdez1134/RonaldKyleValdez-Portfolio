import requests
import csv
import json
import sqlite3
from datetime import datetime
import os
import argparse

# --- CLI Arguments ---
parser = argparse.ArgumentParser()
parser.add_argument("--limit", type=int, default=20, help="Total appids to pull")
parser.add_argument("--batch", type=int, default=5, help="Process this many per run")
parser.add_argument("--mode", type=str, choices=["w", "a"], default="w", help="Write mode: overwrite (w) or append (a)")
args = parser.parse_args()

COUNT = args.count
WRITE_MODE = args.mode

# Ensure folders exist
os.makedirs("./data/csv", exist_ok=True)
os.makedirs("./data/json", exist_ok=True)
os.makedirs("./data/sqlite/db", exist_ok=True)

# Steam store specials API
url = f"https://store.steampowered.com/api/storesearch/?specials=1&cc=us&l=english&count={COUNT}"
response = requests.get(url).json()

records = []
for game in response.get("items", []):
    price_info = game.get("price", {})
    record = {
        "game_id": str(game["id"]),
        "title": game["name"],
        "platform": "Steam",
        "price": price_info.get("final", None) / 100 if "final" in price_info else None,
        "discount": price_info.get("discount_percent", None),
        "timestamp": datetime.now().isoformat()
    }
    records.append(record)

if records:
    # --- CSV ---
    csv_file = "./data/csv/deals.csv"
    with open(csv_file, WRITE_MODE, newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=records[0].keys())
        if WRITE_MODE == "w" or f.tell() == 0:
            writer.writeheader()
        writer.writerows(records)

    # --- JSON ---
    json_file = "./data/json/deals.json"
    if WRITE_MODE == "w":
        with open(json_file, "w", encoding="utf-8") as f:
            json.dump(records, f, indent=4)
    else:
        existing = []
        if os.path.exists(json_file):
            with open(json_file, "r", encoding="utf-8") as f:
                existing = json.load(f)
        existing.extend(records)
        with open(json_file, "w", encoding="utf-8") as f:
            json.dump(existing, f, indent=4)

    # --- SQLite ---
    conn = sqlite3.connect("./data/sqlite/db/deals.db")
    cursor = conn.cursor()
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS deals (
        game_id TEXT PRIMARY KEY,
        title TEXT,
        platform TEXT,
        price REAL,
        discount INTEGER,
        timestamp TEXT
    )
    """)
    cursor.executemany("""
    INSERT OR REPLACE INTO deals
    (game_id, title, platform, price, discount, timestamp)
    VALUES (:game_id, :title, :platform, :price, :discount, :timestamp)
    """, records)
    conn.commit()
    conn.close()

    print(f"{'Appended' if WRITE_MODE=='a' else 'Overwritten'} {len(records)} Steam deals into CSV, JSON, and SQLite.")
else:
    print("No Steam deals found.")
