# Screenshot Sync

Syncs local screenshots to a VPS so you can say *"Check the screenshots folder, there's a new image I want you to see"* and the assistant can read from the server.

**Repo:** [vps-win-screenshot-sync](https://github.com/jerryagenyi/vps-win-screenshot-sync)  
**Local path:** `C:\Users\Username\Documents\github\vps-win-screenshot-sync`

## 1. Config (already set)

- **LOCAL_SCREENSHOTS:** `C:\Users\Username\OneDrive\Pictures\Screenshots` (script uses WSL path: `/mnt/c/Users/Username/OneDrive/Pictures/Screenshots`)
- **VPS_HOST:** `100.123.6.36` (Tailscale)

To change anything, edit `screenshot-sync.sh` in this folder. If you use Git Bash instead of WSL, set `LOCAL_SCREENSHOTS` to `/c/Users/Username/OneDrive/Pictures/Screenshots`.

## 2. Install watcher (for continuous sync)

- **Mac:** `brew install fswatch`
- **Linux / WSL:** `sudo apt install inotify-tools`
- **Windows (native):** No built-in watcher; use one-time sync or run from WSL for `--watch`.

## 3. Run it

From this repo directory, in **WSL** or **Git Bash** (so `bash` and `rsync` are available):

- **One-time sync:**  
  `./screenshot-sync.sh` or `bash screenshot-sync.sh`

- **Continuous (sync on new screenshots):**  
  `./screenshot-sync.sh --watch` or `bash screenshot-sync.sh --watch`

From anywhere (use full path in WSL):

```bash
bash /mnt/c/Users/Username/Documents/github/vps-win-screenshot-sync/screenshot-sync.sh
```

If `rsync` is missing, install it (e.g. in WSL: `sudo apt install rsync`).

## 4. Where files end up

After sync, screenshots are on the VPS at **`/home/ja/screenshots/`**.

Tell your assistant: *"Check the screenshots folder, there's a new image I want you to see"* (and point to that path if needed).

## Quick test

1. `cd` to this repo, run `./screenshot-sync.sh --watch`.
2. Take a screenshot.
3. Wait for the script to sync.
4. Ask the assistant to check `/home/ja/screenshots/` on the VPS.

## Reinstall from VPS (optional)

If you need a fresh copy from the VPS:

```bash
scp ja@100.123.6.36:/home/ja/backups/screenshot-sync.sh ./
chmod +x screenshot-sync.sh
```
