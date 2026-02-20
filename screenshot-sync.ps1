# Screenshot Sync (PowerShell)
# Syncs local screenshots to VPS. Run from PowerShell.
# Usage:
#   .\screenshot-sync.ps1           # One-time sync
#   .\screenshot-sync.ps1 -Watch     # Watch for new screenshots and sync

param(
    [switch]$Watch
)

$LocalScreenshots = "C:\Users\Username\OneDrive\Pictures\Screenshots"
$VpsHost = "100.123.6.36"
$VpsUser = "ja"
$VpsPath = "/home/ja/screenshots"

if (-not (Test-Path $LocalScreenshots)) {
    Write-Error "Local folder not found: $LocalScreenshots"
    exit 1
}

function Sync-Now {
    $time = Get-Date -Format "HH:mm:ss"
    Write-Host "[$time] Syncing to ${VpsUser}@${VpsHost}:${VpsPath} ..."
    $files = Get-ChildItem -Path $LocalScreenshots -File -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        scp $f.FullName "${VpsUser}@${VpsHost}:${VpsPath}/"
        if ($LASTEXITCODE -ne 0) { Write-Error "scp failed for $($f.Name)"; exit 1 }
    }
    Write-Host "[$time] Sync done."
}

Sync-Now

if (-not $Watch) { exit 0 }

Write-Host "Watch mode: syncing when new screenshots appear. Ctrl+C to stop."
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $LocalScreenshots
$watcher.Filter = "*.*"
$watcher.EnableRaisingEvents = $true
$onChange = Register-ObjectEvent $watcher "Created" -Action { Sync-Now }
$onChange2 = Register-ObjectEvent $watcher "Changed" -Action { Sync-Now }
try {
    while ($true) { Start-Sleep -Seconds 5 }
} finally {
    Unregister-Event -SourceIdentifier $onChange.Name
    Unregister-Event -SourceIdentifier $onChange2.Name
    $watcher.Dispose()
}
