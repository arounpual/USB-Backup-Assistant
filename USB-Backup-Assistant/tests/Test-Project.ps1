# Lightweight repository/source checks. Does not execute a backup or touch user files.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $root 'src\USB-Backup.ps1'
$launcherPath = Join-Path $root 'Run-Backup.cmd'
$readmePath = Join-Path $root 'README.md'
$prototypeDoc = Join-Path $root 'defense\original-prototype-review.md'
$detectionDoc = Join-Path $root 'defense\powershell-detection.md'
$defenseDoc = Join-Path $root 'defense\windows-defenses.md'
$responseDoc = Join-Path $root 'defense\incident-response.md'

foreach ($path in @($scriptPath, $launcherPath, $readmePath, $prototypeDoc, $detectionDoc, $defenseDoc, $responseDoc)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required project file missing: $path"
    }
}

$source = Get-Content -LiteralPath $scriptPath -Raw
$launcher = Get-Content -LiteralPath $launcherPath -Raw
$readme = Get-Content -LiteralPath $readmePath -Raw
$checks = [ordered]@{
    '20-photo limit is defined' = $source -match '\$PhotoLimit\s*=\s*20'
    '10-document limit is defined' = $source -match '\$DocumentLimit\s*=\s*10'
    '10-video limit is defined' = $source -match '\$VideoLimit\s*=\s*10'
    'explicit YES confirmation exists' = $source -match "-cne\s+'YES'"
    'network inventory is optional' = $source -match 'includeNetwork'
    'visible launcher does not request hidden window' = ($launcher -notmatch '-WindowStyle\s+Hidden')
    'no key-clear Wi-Fi export command' = ($source -notmatch 'key=clear')
    'no hidden folder attribute setting' = ($source -notmatch 'FileAttributes\]::Hidden')
    'README discloses original silent prototype' = $readme -match 'original personal prototype.*hidden window'
    'README explains public-edition changes' = $readme -match 'What changed from the original prototype'
}

$failed = 0
foreach ($entry in $checks.GetEnumerator()) {
    if ($entry.Value) {
        Write-Host "PASS: $($entry.Key)" -ForegroundColor Green
    } else {
        Write-Host "FAIL: $($entry.Key)" -ForegroundColor Red
        $failed++
    }
}

if ($failed -gt 0) { throw "$failed project check(s) failed." }
Write-Host "All $($checks.Count) project checks passed." -ForegroundColor Green
