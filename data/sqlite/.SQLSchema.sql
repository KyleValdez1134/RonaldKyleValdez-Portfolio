-- Deals (Steam + Nintendo)
CREATE TABLE IF NOT EXISTS deals (
    game_id TEXT,
    title TEXT,
    platform TEXT,
    price REAL,
    discount INTEGER,
    timestamp DATETIME,
    PRIMARY KEY (game_id, platform, timestamp)
);

-- Release Dates
CREATE TABLE IF NOT EXISTS release_dates (
    game_id TEXT PRIMARY KEY,
    title TEXT,
    platform TEXT,
    release_date DATE
);

-- Reviews (Steam + Nintendo via RAWG)
CREATE TABLE IF NOT EXISTS reviews (
    game_id TEXT PRIMARY KEY,
    title TEXT,
    platform TEXT,
    review_score INTEGER,
    review_count INTEGER,
    sentiment TEXT
);

-- Player Counts (Steam only)
CREATE TABLE IF NOT EXISTS player_counts (
    game_id TEXT,
    title TEXT,
    current_players INTEGER,
    peak_players INTEGER,
    timestamp DATETIME,
    PRIMARY KEY (game_id, timestamp)
);
