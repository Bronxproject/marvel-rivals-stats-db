# Marvel Rivals Stats Database

This folder gives you a local SQLite database for your competitive Marvel Rivals matches.

It imports your current Excel workbook and can update daily from an API-backed source you are allowed to use. Tracker.gg currently says it does not offer a Marvel Rivals API and that scraping can result in bans, so this tool does not scrape Tracker.gg.

## Where This Lives

You can use this in two ways:

- Locally on your Mac: easiest while you are learning. Save Tracker exports into `imports/`, then run `bash daily_update.sh`.
- In a GitHub repo: upload this whole folder as a repository. The included GitHub Actions workflow imports files in `imports/`, refreshes `marvel_rivals.sqlite3` and `matches_export.csv`, then commits the updates back to the repo.

For the GitHub version, new Tracker data only appears after you upload/commit a saved Tracker export into `imports/`. GitHub cannot read files that are only sitting on your computer.

## Files

- `rivals_stats_db.py`: command-line tool
- `schema.sql`: SQLite tables and summary views
- `marvel_rivals.sqlite3`: database created after import
- `daily_update.sh`: daily update runner
- `.github/workflows/import-saved-tracker-files.yml`: GitHub Actions workflow
- `imports/`: drop saved Tracker exports here
- `config.example.env`: copy to `.env` and fill in your player/API key
- `launchd.example.plist`: macOS daily schedule template

## Setup

```bash
cd "/Users/rafaelgonzalez/Documents/Codex/2026-06-04/files-mentioned-by-the-user-marvel/outputs/marvel_rivals_stats_db"
python3 -m pip install -r requirements.txt
```

## Put This on GitHub

1. Create a new GitHub repository, for example `marvel-rivals-stats-db`.
2. Upload all files from this folder into that repository.
3. In the repo, go to `Settings` -> `Actions` -> `General`.
4. Under `Workflow permissions`, choose `Read and write permissions`.
5. Save a Tracker export into the repo's `imports/` folder and commit it.
6. The workflow will run, import new matches, and commit updated database files.

You can also run it manually from GitHub:

1. Open the repo on GitHub.
2. Go to `Actions`.
3. Choose `Import Saved Tracker Files`.
4. Click `Run workflow`.

## Import Your Existing Workbook

```bash
python3 rivals_stats_db.py import-excel "/Users/rafaelgonzalez/Lehman College Dropbox/Rafael Gonzalez/Mac (3)/Downloads/marvel_rivals_competitive_match_analysis_competitive_only.xlsx"
python3 rivals_stats_db.py report --export-csv matches_export.csv
```

## Import Saved Tracker Files

Save your Tracker.gg match history page as MHTML, HTML, PDF, TXT, or another updated Excel export, then put the file in:

```bash
/Users/rafaelgonzalez/Documents/Codex/2026-06-04/files-mentioned-by-the-user-marvel/outputs/marvel_rivals_stats_db/imports
```

In Chrome, the easiest options are:

- MHTML/HTML: open your Tracker profile match history, press `Cmd+S`, and save the page into `imports/`.
- PDF: open your Tracker profile match history, press `Cmd+P`, choose `Save as PDF`, and save it into `imports/`.

Run:

```bash
python3 rivals_stats_db.py import-folder imports
python3 rivals_stats_db.py report --export-csv matches_export.csv
```

The importer dedupes against existing data using the match date, hero, map, result, score, rank/rating, and K/D/A stats. It does not use the workbook row number or Tracker's relative-time text, so re-importing the same saved page should not double count matches.

## Daily API Update

The default daily runner now imports saved files from `imports/` and refreshes the CSV:

```bash
bash daily_update.sh
```

If you later get an API key, you can still use the API updater. Create your local config:

```bash
cp config.example.env .env
```

Edit `.env` with your player name or UID and your API key, then test:

```bash
python3 rivals_stats_db.py update-api
```

## Schedule Daily on macOS

Edit `launchd.example.plist` if you want a different time, then install it:

```bash
cp launchd.example.plist "$HOME/Library/LaunchAgents/local.marvel-rivals-stats-db.plist"
launchctl unload "$HOME/Library/LaunchAgents/local.marvel-rivals-stats-db.plist" 2>/dev/null || true
launchctl load "$HOME/Library/LaunchAgents/local.marvel-rivals-stats-db.plist"
```

The example runs every day at 8:00 AM.

## Useful Queries

```bash
sqlite3 marvel_rivals.sqlite3 "SELECT * FROM hero_summary ORDER BY matches DESC LIMIT 10;"
sqlite3 marvel_rivals.sqlite3 "SELECT * FROM daily_summary ORDER BY match_date DESC LIMIT 14;"
sqlite3 marvel_rivals.sqlite3 "SELECT hero, win_rate, avg_kda FROM hero_summary WHERE matches >= 10 ORDER BY win_rate DESC;"
```
