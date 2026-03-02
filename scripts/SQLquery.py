import sqlite3

# Connect to your database
conn = sqlite3.connect("./data/sqlite/db/deals.db")
cursor = conn.cursor()

# Check existing columns in the reviews table
cursor.execute("PRAGMA table_info(player_counts)")
columns = [col[1] for col in cursor.fetchall()]

# Add platform column if missing
if "platform" not in columns:
    cursor.execute("ALTER TABLE player_counts ADD COLUMN platform TEXT")
    print("Added 'platform' column to player_counts table.")
else:
    print("'platform' column already exists.")

conn.commit()
conn.close()
