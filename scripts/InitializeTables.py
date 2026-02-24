import sqlite3
import os

os.makedirs("./data/sqlite/db", exist_ok=True)

conn = sqlite3.connect("./data/sqlite/db/deals.db")
cursor = conn.cursor()

# Deals
cursor.execute("""
CREATE TABLE IF NOT EXISTS deals (
    game_id TEXT,
    title TEXT,
    platform TEXT,
    price REAL,
    discount INTEGER,
    timestamp DATETIME,
    PRIMARY KEY (game_id, platform, timestamp)
)
""")

# Release Dates
cursor.execute("""
CREATE TABLE IF NOT EXISTS release_dates (
    game_id TEXT PRIMARY KEY,
    title TEXT,
    platform TEXT,
    release_date DATE
)
""")

# Reviews
cursor.execute("""
CREATE TABLE IF NOT EXISTS reviews (
    game_id TEXT PRIMARY KEY,
    title TEXT,
    platform TEXT,
    review_score INTEGER,
    review_count INTEGER,
    sentiment TEXT
)
""")

# Player Counts
cursor.execute("""
CREATE TABLE IF NOT EXISTS player_counts (
    game_id TEXT,
    title TEXT,
    current_players INTEGER,
    peak_players INTEGER,
    timestamp DATETIME,
    PRIMARY KEY (game_id, timestamp)
)
""")

conn.commit()
conn.close()

print("All tables initialized successfully.")
