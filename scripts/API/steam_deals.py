import requests
import csv
import json
import sqlite3
from datetime import datetime
import os

# Ensure folders exist
os.makedirs("./data/csv", exist_ok=True)
os.makedirs("./data/json", exist_ok=True)
os.makedirs("./data/sqlite/db", exist_ok=True)

url = "https://store.steampowered.com/api/storesearch/?specials=1&cc=us&l=english&count=50"
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
    # Append to CSV
    csv_file = "./data/csv/deals.csv"
    with open(csv_file, "a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=records[0].keys())
        if f.tell() == 0:
            writer.writeheader()
        writer.writerows(records)

    # Append to JSON
    json_file = "./data/json/deals.json"
    existing = []
    if os.path.exists(json_file):
        with open(json_file, "r", encoding="utf-8") as f:
            existing = json.load(f)
    existing.extend(records)
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(existing, f, indent=4)

    # Append to SQLite
    conn = sqlite3.connect("./data/sqlite/db/deals.db")
    cursor = conn.cursor()
    cursor.executemany("""
    INSERT OR REPLACE INTO deals
    (game_id, title, platform, price, discount, timestamp)
    VALUES (:game_id, :title, :platform, :price, :discount, :timestamp)
    """, records)
    conn.commit()
    conn.close()

    print(f"Appended {len(records)} Steam deals to CSV, JSON, and SQLite.")
else:
    print("No Steam deals found.")
