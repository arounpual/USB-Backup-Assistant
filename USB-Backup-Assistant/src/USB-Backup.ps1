# USB Backup Assistant
# Windows PowerShell 5.1+ | User-consented personal backup and non-secret network inventory
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PhotoLimit = 20
$DocumentLimit = 10
$VideoLimit = 10
$BackupFolderName = 'USB-Backup-Assistant'

$PhotoExtensions = @('.jpg','.jpeg','.png','.gif','.bmp','.webp','.heic','.tif','.tiff')
$DocumentExtensions = @('.doc','.docx','.docm','.odt','.rtf','.txt','.pdf', '.xls','.xlsx','.xlsm','.csv','.ppt','.pptx','.pptm','.ods','.odp')
$VideoExtensions = @('.mp4','.m4v','.mov','.avi','.wmv','.mkv','.webm','.mpeg','.mpg','.3gp','.mts','.m2ts')

function Write-Section {
    param([Parameter(Mandatory)][string]$Text)
    Write-Host "`n=== $Text ===" -ForegroundColor Cyan
}

function Get-RemovableDrives {
    @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=2' |
        Where-Object { $_.DeviceID } |
        Sort-Object DeviceID)
}

function Select-BackupDrive {
    $drives = Get-RemovableDrives
    if ($drives.Count -eq 0) {
        throw 'No removable USB drive was detected. Connect a USB drive and try again.'
    }

    Write-Section 'Available removable drives'
    for ($i = 0; $i -lt $drives.Count; $i++) {
        $drive = $drives[$i]
        $sizeGB = if ($drive.Size) { [math]::Round($drive.Size / 1GB, 2) } else { 'Unknown' }
        Write-Host ("[{0}] {1}  {2}  {3} GB" -f ($i + 1), $drive.DeviceID, $drive.VolumeName, $sizeGB)
    }

    while ($true) {
        $choice = Read-Host 'Select the USB drive number (or Q to quit)'
        if ($choice -match '^(?i:q)$') { return $null }
        $number = 0
        if ([int]::TryParse($choice, [ref]$number) -and $number -ge 1 -and $number -le $drives.Count) {
            return $drives[$number - 1].DeviceID
        }
        Write-Warning 'Enter one of the listed numbers, or Q.'
    }
}

function Get-NewestMatchingFiles {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string[]]$Extensions,
        [Parameter(Mandatory)][int]$Limit
    )
    if (-not (Test-Path -LiteralPath $Source -PathType Container)) { return @() }
    @(Get-ChildItem -LiteralPath $Source -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $Extensions -contains $_.Extension.ToLowerInvariant() } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First $Limit)
}

function Copy-BackupCategory {
    param(
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination,
        [Parameter(Mandatory)][string[]]$Extensions,
        [Parameter(Mandatory)][int]$Limit,
        [Parameter(Mandatory)][System.Collections.Generic.List[string]]$Log
    )

    $copied = 0
    $failed = 0
    $files = Get-NewestMatchingFiles -Source $Source -Extensions $Extensions -Limit $Limit
    if ($files.Count -eq 0) {
        $Log.Add("${Category}: no matching files found (or source folder unavailable).")
        Write-Host "${Category}: no matching files found."
        return [pscustomobject]@{ Category = $Category; Found = 0; Copied = 0; Failed = 0 }
    }

    foreach ($file in $files) {
        # Preserve the source-relative path to avoid collisions between equal filenames.
        $relativePath = $file.FullName.Substring($Source.TrimEnd('\').Length).TrimStart('\')
        $target = Join-Path $Destination $relativePath
        $targetDirectory = Split-Path -Parent $target
        try {
            New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $target -Force -ErrorAction Stop
            $copied++
            $Log.Add("${Category}: copied '$($file.FullName)'")
        }
        catch {
            $failed++
            $Log.Add("${Category}: FAILED '$($file.FullName)' - $($_.Exception.Message)")
            Write-Warning "Could not copy $($file.Name): $($_.Exception.Message)"
        }
    }

    Write-Host ("{0}: copied {1} of {2}; failed {3}." -f $Category, $copied, $files.Count, $failed)
    [pscustomobject]@{ Category = $Category; Found = $files.Count; Copied = $copied; Failed = $failed }
}

function Save-NetworkInventory {
    param([Parameter(Mandatory)][string]$Destination)
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null

    # These commands intentionally collect configuration metadata only.
    # Never request or export saved wireless credentials.
    & netsh.exe wlan show profiles 2>&1 |
        Out-File -LiteralPath (Join-Path $Destination 'wifi-profile-names.txt') -Encoding utf8
    & netsh.exe wlan show interfaces 2>&1 |
        Out-File -LiteralPath (Join-Path $Destination 'wifi-interfaces.txt') -Encoding utf8
    & netsh.exe wlan show drivers 2>&1 |
        Out-File -LiteralPath (Join-Path $Destination 'wifi-drivers.txt') -Encoding utf8
    & ipconfig.exe /all 2>&1 |
        Out-File -LiteralPath (Join-Path $Destination 'ip-configuration.txt') -Encoding utf8
}

try {
    Clear-Host
    Write-Host 'USB BACKUP ASSISTANT' -ForegroundColor Green
    Write-Host 'A visible, user-approved backup utility for Windows.'
    Write-Host "Limits: $PhotoLimit photos, $DocumentLimit documents, $VideoLimit videos."
    Write-Host 'Network inventory is optional and contains configuration metadata, not passwords.'

    $usbRoot = Select-BackupDrive
    if (-not $usbRoot) {
        Write-Host 'Cancelled. No files were copied.' -ForegroundColor Yellow
        exit 0
    }

    $backupRoot = Join-Path $usbRoot $BackupFolderName
    Write-Host "`nDestination: $backupRoot"
    Write-Host 'Files selected are the newest matching files in the standard Pictures, Documents and Videos folders.'
    $confirm = Read-Host 'Continue with this backup? Type YES to proceed'
    if ($confirm -cne 'YES') {
        Write-Host 'Cancelled. No files were copied.' -ForegroundColor Yellow
        exit 0
    }

    $networkChoice = Read-Host 'Also save Wi-Fi names, adapter/driver details and IP configuration? (Y/N)'
    $includeNetwork = $networkChoice -match '^(?i:y|yes)$'

    $photosSource = [Environment]::GetFolderPath('MyPictures')
    $documentsSource = [Environment]::GetFolderPath('MyDocuments')
    $videosSource = [Environment]::GetFolderPath('MyVideos')

    $photosDestination = Join-Path $backupRoot 'Photos'
    $documentsDestination = Join-Path $backupRoot 'Documents'
    $videosDestination = Join-Path $backupRoot 'Videos'
    New-Item -ItemType Directory -Path $photosDestination, $documentsDestination, $videosDestination -Force | Out-Null

    $log = [System.Collections.Generic.List[string]]::new()
    $log.Add('USB Backup Assistant report')
    $log.Add("Started: $(Get-Date -Format o)")
    $log.Add("Computer: $env:COMPUTERNAME")
    $log.Add("Destination: $backupRoot")
    $log.Add('Credential collection: disabled; no Wi-Fi passwords or keys are exported.')

    Write-Section 'Backing up personal files'
    $results = @()
    $results += Copy-BackupCategory -Category 'Photos' -Source $photosSource -Destination $photosDestination -Extensions $PhotoExtensions -Limit $PhotoLimit -Log $log
    $results += Copy-BackupCategory -Category 'Documents' -Source $documentsSource -Destination $documentsDestination -Extensions $DocumentExtensions -Limit $DocumentLimit -Log $log
    $results += Copy-BackupCategory -Category 'Videos' -Source $videosSource -Destination $videosDestination -Extensions $VideoExtensions -Limit $VideoLimit -Log $log

    if ($includeNetwork) {
        Write-Section 'Saving optional network inventory'
        $networkDestination = Join-Path $backupRoot 'Network-Inventory'
        Save-NetworkInventory -Destination $networkDestination
        $log.Add('Network inventory: saved Wi-Fi profile names, interface/driver details and IP configuration.')
        Write-Host "Network inventory saved to $networkDestination"
    }
    else {
        $log.Add('Network inventory: skipped by user.')
        Write-Host 'Network inventory skipped.'
    }

    $log.Add('')
    $log.Add('Summary:')
    foreach ($result in $results) {
        $log.Add(("{0}: found={1}; copied={2}; failed={3}" -f $result.Category, $result.Found, $result.Copied, $result.Failed))
    }
    $log.Add("Finished: $(Get-Date -Format o)")
    $log | Set-Content -LiteralPath (Join-Path $backupRoot 'backup-report.txt') -Encoding utf8

    Write-Section 'Backup complete'
    $results | Format-Table -AutoSize | Out-Host
    Write-Host "Report: $(Join-Path $backupRoot 'backup-report.txt')" -ForegroundColor Green
}
catch {
    Write-Error "Backup stopped: $($_.Exception.Message)"
    Write-Host 'No credentials are collected by this tool. Check the USB drive and try again.' -ForegroundColor Yellow
    exit 1
}
