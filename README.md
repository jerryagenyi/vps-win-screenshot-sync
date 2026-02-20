# Screenshot Sync

Syncs local screenshots to a VPS so you can say *"Check the screenshots folder, there's a new image I want you to see"* and the assistant can read from the server.

**Repo:** [vps-win-screenshot-sync](https://github.com/jerryagenyi/vps-win-screenshot-sync)  
**Local path:** `C:\Users\Username\Documents\github\vps-win-screenshot-sync`

## 1. Config (already set)

- **Local folder:** `C:\Users\Username\OneDrive\Pictures\Screenshots`
- **VPS:** `100.123.6.36` (Tailscale), user `ja`, path `/home/ja/screenshots`

To change anything, edit `screenshot-sync.ps1` (PowerShell) or `screenshot-sync.sh` (bash) in this folder.

## 2. Run it (PowerShell)

From this repo folder in **PowerShell**:

- **One-time sync:**  
  `.\screenshot-sync.ps1`

- **Watch mode (sync when new screenshots appear):**  
  `.\screenshot-sync.ps1 -Watch`

You need **OpenSSH** (usually already on Windows 10/11). If `scp` isn’t found, add OpenSSH Client in Settings → Apps → Optional features.

## 3. Where files end up

After sync, screenshots are on the VPS at **`/home/ja/screenshots/`**.

## How to verify sync

1. **One-time sync** — in PowerShell from this repo:
   ```powershell
   .\screenshot-sync.ps1
   ```
   You should see `Syncing to ja@100.123.6.36:...` then `Sync done.` Any connection/SSH errors need to be fixed first.

2. **Check the VPS** — in PowerShell:
   ```powershell
   ssh ja@100.123.6.36 "ls -la /home/ja/screenshots/"
   ```
   The list should match the files in `C:\Users\Username\OneDrive\Pictures\Screenshots`.

3. **End-to-end:** Take a new screenshot, run `.\screenshot-sync.ps1` again, then the `ssh ... ls` command — the new file should appear on the VPS.

## Bash script (optional)

If you use Git Bash or another bash shell, you can use `screenshot-sync.sh` instead (same config, uses `rsync`). From that shell: `bash screenshot-sync.sh` or `bash screenshot-sync.sh --watch`.

## Reinstall from VPS (optional)

If you need a fresh copy of the bash script from the VPS:

```powershell
scp ja@100.123.6.36:/home/ja/backups/screenshot-sync.sh ./
```
