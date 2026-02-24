CREATE TABLE IF NOT EXISTS Deals (
    game_id TEXT,
    title TEXT,
    platform TEXT,
    price REAL,
    discount INTEGER,
    timestamp TEXT
);

CREATE TABLE IF NOT EXISTS ReleaseDates (
    game_id TEXT,
    title TEXT,
    platform TEXT,
    release_date TEXT
);

CREATE TABLE IF NOT EXISTS Reviews (
    game_id TEXT,
    title TEXT,
    platform TEXT,
    review_score INTEGER,
    review_count INTEGER,
    sentiment TEXT
);

CREATE TABLE IF NOT EXISTS PlayerCounts (
    game_id TEXT,
    title TEXT,
    current_players INTEGER,
    peak_players INTEGER,
    timestamp TEXT
);
