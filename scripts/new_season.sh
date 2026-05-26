#!/usr/bin/env bash
set -euo pipefail

# new_season.sh
# Helper to create a new Storygame season from template files.
#
# Usage: ./scripts/new_season.sh 3 "Season Title Here"
# This will create seasons/season03/ with overview + turn log files
# based on the templates, with placeholders filled in.

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <season-number> <season-title>" >&2
  exit 1
fi

raw_num="$1"
shift
season_title="$*"

# Zero-pad season number to two digits (01, 02, 03, ...)
if ! [[ "$raw_num" =~ ^[0-9]+$ ]]; then
  echo "Error: season-number must be an integer (e.g., 3 or 12)." >&2
  exit 1
fi

printf -v season_num "%02d" "$raw_num"
season_dir="seasons/season${season_num}"

if [[ -e "$season_dir" ]]; then
  echo "Error: $season_dir already exists. Pick a different number." >&2
  exit 1
fi

mkdir -p "$season_dir"

overview_template="templates/season_overview_template.md"
turnlog_template="templates/season_turn_log_template.md"

if [[ ! -f "$overview_template" || ! -f "$turnlog_template" ]]; then
  echo "Error: template files not found in templates/." >&2
  exit 1
fi

overview_target="${season_dir}/season${season_num}_overview.md"
turnlog_target="${season_dir}/season${season_num}_turn_log.md"

sed \
  -e "s/{{SEASON_NUMBER}}/${season_num}/g" \
  -e "s/{{SEASON_TITLE}}/${season_title//\//\/}/g" \
  "$overview_template" > "$overview_target"

sed \
  -e "s/{{SEASON_NUMBER}}/${season_num}/g" \
  -e "s/{{SEASON_TITLE}}/${season_title//\//\/}/g" \
  "$turnlog_template" > "$turnlog_target"

cat <<EOF2
Created new season skeleton:
  - $overview_target
  - $turnlog_target

Next steps:
  1. Edit the overview to define the setting, cast, tone, and closure.
  2. Replace the placeholder Turn 1 with an actual opening scene.
  3. Commit your changes with a message like:
       git add $season_dir
       git commit -m "Add Season $season_num – $season_title"
EOF2
