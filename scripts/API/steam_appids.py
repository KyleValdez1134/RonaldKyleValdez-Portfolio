import requests, sqlite3, csv, json, os
from datetime import datetime
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--limit", type=int, default=500, help="Number of appids to pull")
parser.add_argument("--mode", type=str, choices=["w","a"], default="w", help="Write mode")
args = parser.parse_args()

APPID_LIMIT = args.limit
WRITE_MODE = args.mode

os.makedirs("./data/csv", exist_ok=True)
os.makedirs("./data/json", exist_ok=True)
os.makedirs("./data/sqlite/db", exist_ok=True)

url = "https://steamspy.com/api.php?request=all"
records = []

try:
    response = requests.get(url, timeout=15)
    response.raise_for_status()
    data = response.json()
    for appid, info in list(data.items())[:APPID_LIMIT]:
        records.append({
            "appid": int(appid),
            "name": info.get("name", "Unknown"),
            "timestamp": datetime.now().isoformat()
        })
except Exception as e:
    print(f"Failed to fetch app list: {e}")

if records:
    # CSV
    csv_file = "./data/csv/steam_appids.csv"
    with open(csv_file, WRITE_MODE, newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=records[0].keys())
        if WRITE_MODE == "w": writer.writeheader()
        writer.writerows(records)

    # JSON
    json_file = "./data/json/steam_appids.json"
    if WRITE_MODE == "w":
        with open(json_file, "w", encoding="utf-8") as f: json.dump(records, f, indent=4)
    else:
        existing = []
        if os.path.exists(json_file):
            with open(json_file, "r", encoding="utf-8") as f: existing = json.load(f)
        existing.extend(records)
        with open(json_file, "w", encoding="utf-8") as f: json.dump(existing, f, indent=4)

    # SQLite
    conn = sqlite3.connect("./data/sqlite/db/deals.db")
    cursor = conn.cursor()
    cursor.execute("""CREATE TABLE IF NOT EXISTS steam_appids (
        appid INTEGER PRIMARY KEY, name TEXT, timestamp TEXT)""")
    cursor.executemany("""INSERT OR REPLACE INTO steam_appids VALUES (:appid,:name,:timestamp)""", records)
    conn.commit(); conn.close()

    print(f"Inserted {len(records)} appids.")
else:
    print("No appids found.")
