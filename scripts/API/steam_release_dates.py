import requests, sqlite3, csv, json, os, time
from datetime import datetime
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--limit", type=int, default=20, help="Total appids to pull")
parser.add_argument("--batch", type=int, default=5, help="Process this many per run")
parser.add_argument("--mode", type=str, choices=["w", "a"], default="w", help="Write mode: overwrite (w) or append (a)")
args = parser.parse_args()

APPID_LIMIT, BATCH_SIZE, WRITE_MODE = args.limit, args.batch, args.mode

os.makedirs("./data/csv", exist_ok=True)
os.makedirs("./data/json", exist_ok=True)
os.makedirs("./data/sqlite/db", exist_ok=True)

conn = sqlite3.connect("./data/sqlite/db/deals.db")
cursor = conn.cursor()
cursor.execute("""CREATE TABLE IF NOT EXISTS release_dates (
    game_id INTEGER PRIMARY KEY, title TEXT, platform TEXT, release_date TEXT, timestamp TEXT)""")

with open("./data/json/steam_appids.json","r",encoding="utf-8") as f: appids_data=json.load(f)
records=[]

for entry in appids_data[:APPID_LIMIT][:BATCH_SIZE]:
    appid, name = entry["appid"], entry["name"]
    url=f"https://store.steampowered.com/api/appdetails?appids={appid}&l=english&cc=us"
    try:
        r=requests.get(url); 
        if r.status_code==200 and r.text.strip():
            app_data=r.json().get(str(appid),{}).get("data",{})
            if app_data:
                release_info=app_data.get("release_date",{})
                records.append({"game_id":appid,"title":name,"platform":"Steam",
                                "release_date":release_info.get("date"),
                                "timestamp":datetime.now().isoformat()})
        time.sleep(0.2)
    except Exception as e: print(f"Error {appid}: {e}")

if records:
    cursor.executemany("""INSERT OR REPLACE INTO release_dates VALUES (:game_id,:title,:platform,:release_date,:timestamp)""",records)
    conn.commit(); conn.close()

    # CSV
    csv_file="./data/csv/release_dates.csv"
    with open(csv_file,WRITE_MODE,newline="",encoding="utf-8") as f:
        writer=csv.DictWriter(f,fieldnames=records[0].keys())
        if WRITE_MODE=="w": writer.writeheader()
        writer.writerows(records)

    # JSON
    json_file="./data/json/release_dates.json"
    if WRITE_MODE=="w":
        with open(json_file,"w",encoding="utf-8") as f: json.dump(records,f,indent=4)
    else:
        existing=[]
        if os.path.exists(json_file):
            with open(json_file,"r",encoding="utf-8") as f: existing=json.load(f)
        existing.extend(records)
        with open(json_file,"w",encoding="utf-8") as f: json.dump(existing,f,indent=4)

    print(f"Processed {len(records)} release dates.")
