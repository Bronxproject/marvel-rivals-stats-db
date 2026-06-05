#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi

python3 rivals_stats_db.py import-folder imports
python3 rivals_stats_db.py report --export-csv matches_export.csv
