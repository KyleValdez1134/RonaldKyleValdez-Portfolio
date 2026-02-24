import sqlite3

# Connect to your SQLite database
conn = sqlite3.connect("./data/sqlite/db/deals.db")
cursor = conn.cursor()

# Show all tables
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
print("Tables:", cursor.fetchall())

# Show first 5 deals
cursor.execute("SELECT * FROM release_dates;")
rows = cursor.fetchall()

print("\nSample deals:")
for row in rows:
    print(row)

print("\nGames with discount > 50%:")
for row in rows:
    print(row)

conn.close()
