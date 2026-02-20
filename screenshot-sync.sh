#!/usr/bin/env bash
#
# Screenshot Sync Script
# Syncs local screenshots to a VPS. Supports one-time sync or continuous watch.
#
# Usage:
#   ./screenshot-sync.sh          # One-time sync
#   ./screenshot-sync.sh --watch   # Watch for new screenshots and sync continuously
#

set -e

# --- Configuration (edit these) ---
LOCAL_SCREENSHOTS="/mnt/c/Users/Username/OneDrive/Pictures/Screenshots"  # WSL path; for Git Bash use /c/Users/Username/...
VPS_HOST="100.123.6.36"                    # Tailscale IP (use 72.61.19.90 for public IP)
VPS_USER="ja"                              # SSH user on VPS
VPS_PATH="/home/ja/screenshots"            # Destination folder on VPS
# ----------------------------------

REMOTE="${VPS_USER}@${VPS_HOST}:${VPS_PATH}"

die() {
  echo "Error: $1" >&2
  exit 1
}

do_sync() {
  if [[ ! -d "$LOCAL_SCREENSHOTS" ]]; then
    die "Local folder not found: $LOCAL_SCREENSHOTS"
  fi
  if [[ "$VPS_HOST" == "your-server-ip" ]]; then
    die "Edit the script and set VPS_HOST to your VPS IP address."
  fi
  echo "[$(date '+%H:%M:%S')] Syncing to $REMOTE ..."
  rsync -avz --progress "$LOCAL_SCREENSHOTS/" "$REMOTE/" || die "rsync failed"
  echo "[$(date '+%H:%M:%S')] Sync done."
}

# One-time sync
if [[ "${1:-}" != "--watch" ]]; then
  do_sync
  exit 0
fi

# Watch mode: sync on new files
echo "Watch mode: syncing when new screenshots appear. Ctrl+C to stop."
do_sync

if command -v fswatch &>/dev/null; then
  # macOS (brew install fswatch)
  fswatch -0 "$LOCAL_SCREENSHOTS" | while read -r -d "" _; do do_sync; done
elif command -v inotifywait &>/dev/null; then
  # Linux (apt install inotify-tools)
  while inotifywait -q -e close_write -e moved_to -e create "$LOCAL_SCREENSHOTS"; do
    do_sync
  done
else
  die "No watcher found. Install: Mac: brew install fswatch | Linux: sudo apt install inotify-tools"
fi
