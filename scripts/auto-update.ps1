$ErrorActionPreference = 'SilentlyContinue'

$dir = Join-Path $env:USERPROFILE '.claude\skills\nicochat-prompt'
if (-not (Test-Path $dir)) { exit 0 }

Set-Location $dir

$status = git status --porcelain 2>$null
if ($status) { exit 0 }

git fetch --quiet 2>$null
$behind = git rev-list --count 'HEAD..@{u}' 2>$null
if ($behind -and [int]$behind -gt 0) {
    git pull --quiet --ff-only 2>$null
}

exit 0
