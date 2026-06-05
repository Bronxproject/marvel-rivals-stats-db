PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS imports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source TEXT NOT NULL,
    source_path TEXT,
    imported_at TEXT NOT NULL DEFAULT (datetime('now')),
    rows_seen INTEGER NOT NULL DEFAULT 0,
    rows_inserted INTEGER NOT NULL DEFAULT 0,
    rows_updated INTEGER NOT NULL DEFAULT 0,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS matches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source TEXT NOT NULL,
    source_match_id TEXT,
    match_key TEXT NOT NULL UNIQUE,
    match_date TEXT,
    match_timestamp INTEGER,
    relative_time TEXT,
    match_type TEXT,
    game_type TEXT,
    map TEXT,
    hero TEXT,
    result TEXT,
    award TEXT,
    score_for INTEGER,
    score_against INTEGER,
    rank TEXT,
    rating_score INTEGER,
    rank_delta INTEGER,
    kills INTEGER,
    deaths INTEGER,
    assists INTEGER,
    kda_reported REAL,
    kda_calc REAL GENERATED ALWAYS AS (
        CASE
            WHEN deaths IS NULL THEN NULL
            WHEN deaths = 0 THEN kills + assists
            ELSE ROUND((kills + assists) * 1.0 / deaths, 4)
        END
    ) VIRTUAL,
    win_flag INTEGER NOT NULL DEFAULT 0,
    loss_flag INTEGER NOT NULL DEFAULT 0,
    draw_flag INTEGER NOT NULL DEFAULT 0,
    raw_json TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_matches_date ON matches(match_date);
CREATE INDEX IF NOT EXISTS idx_matches_hero ON matches(hero);
CREATE INDEX IF NOT EXISTS idx_matches_map ON matches(map);
CREATE INDEX IF NOT EXISTS idx_matches_game_type ON matches(game_type);
CREATE INDEX IF NOT EXISTS idx_matches_result ON matches(result);

CREATE VIEW IF NOT EXISTS daily_summary AS
SELECT
    match_date,
    COUNT(*) AS matches,
    SUM(win_flag) AS wins,
    SUM(loss_flag) AS losses,
    SUM(draw_flag) AS draws,
    ROUND(SUM(win_flag) * 1.0 / NULLIF(COUNT(*), 0), 4) AS win_rate,
    ROUND(AVG(kills), 2) AS avg_kills,
    ROUND(AVG(deaths), 2) AS avg_deaths,
    ROUND(AVG(assists), 2) AS avg_assists,
    SUM(rank_delta) AS total_rank_delta
FROM matches
GROUP BY match_date;

CREATE VIEW IF NOT EXISTS hero_summary AS
SELECT
    hero,
    COUNT(*) AS matches,
    SUM(win_flag) AS wins,
    SUM(loss_flag) AS losses,
    SUM(draw_flag) AS draws,
    ROUND(SUM(win_flag) * 1.0 / NULLIF(COUNT(*), 0), 4) AS win_rate,
    ROUND(AVG(kills), 2) AS avg_kills,
    ROUND(AVG(deaths), 2) AS avg_deaths,
    ROUND(AVG(assists), 2) AS avg_assists,
    ROUND(AVG(kda_calc), 2) AS avg_kda,
    ROUND(AVG(rank_delta), 2) AS avg_rank_delta,
    SUM(rank_delta) AS total_rank_delta
FROM matches
GROUP BY hero;

CREATE VIEW IF NOT EXISTS map_summary AS
SELECT
    map,
    COUNT(*) AS matches,
    SUM(win_flag) AS wins,
    SUM(loss_flag) AS losses,
    SUM(draw_flag) AS draws,
    ROUND(SUM(win_flag) * 1.0 / NULLIF(COUNT(*), 0), 4) AS win_rate,
    ROUND(AVG(kda_calc), 2) AS avg_kda,
    ROUND(AVG(rank_delta), 2) AS avg_rank_delta,
    SUM(rank_delta) AS total_rank_delta
FROM matches
GROUP BY map;
