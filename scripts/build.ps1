<#
.SYNOPSIS
  Build script for Emotion Eye – generates optimised production builds and
  prepares them for self-hosted distribution.

.DESCRIPTION
  Creates release builds for Windows (zip) and/or Android (APK).
  Copies final artefacts into both build/releases/ and web/downloads/ so they
  are available for direct download from the deployed web app.

.PARAMETER Target
  Which platform to build: windows, android, web, or all. Default: all.

.PARAMETER SkipClean
  If set, skips flutter clean (faster for iterative builds).

.EXAMPLE
  .\scripts\build.ps1 -Target windows
  .\scripts\build.ps1 -Target android
  .\scripts\build.ps1 -Target web
  .\scripts\build.ps1 -Target all
  .\scripts\build.ps1 -Target all -SkipClean
#>

param(
    [ValidateSet('windows', 'android', 'web', 'all')]
    [string]$Target = 'all',

    [switch]$SkipClean
)

$ErrorActionPreference = 'Stop'

# ── Constants ────────────────────────────────────────────────
$ProjectRoot   = Split-Path -Parent $PSScriptRoot
$ReleasesDir   = Join-Path $ProjectRoot 'build\releases'
$WebDownloads  = Join-Path $ProjectRoot 'web\downloads'
$Timestamp     = Get-Date -Format 'yyyyMMdd_HHmmss'

# Read version from pubspec.yaml
$PubspecPath = Join-Path $ProjectRoot 'pubspec.yaml'
$VersionLine = Select-String -Path $PubspecPath -Pattern '^version:\s*(.+)$'
$AppVersion  = if ($VersionLine) { $VersionLine.Matches[0].Groups[1].Value.Trim() } else { 'unknown' }

Write-Host ''
Write-Host '╔══════════════════════════════════════════════════╗' -ForegroundColor Cyan
Write-Host '║       Emotion Eye — Release Build Script         ║' -ForegroundColor Cyan
Write-Host '╚══════════════════════════════════════════════════╝' -ForegroundColor Cyan
Write-Host "  Version  : $AppVersion"
Write-Host "  Target   : $Target"
Write-Host "  Releases : $ReleasesDir"
Write-Host "  Web DL   : $WebDownloads"
Write-Host ''

# Ensure output directories exist
foreach ($dir in @($ReleasesDir, $WebDownloads)) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# ── Shared flags for size optimisation ───────────────────────
$SharedFlags = @(
    '--release',
    '--tree-shake-icons',
    '--split-debug-info=build/debug-info',
    '--obfuscate'
)

# ── Helper: Clean ────────────────────────────────────────────
function Invoke-Clean {
    if ($SkipClean) {
        Write-Host '  (Skipping clean — -SkipClean set)' -ForegroundColor DarkGray
    } else {
        Write-Host 'Running flutter clean & pub get …' -ForegroundColor DarkGray
        Push-Location $ProjectRoot
        flutter clean 2>&1 | Out-Null
        flutter pub get 2>&1 | Out-Null
        Pop-Location
    }
}

# ── Helper: Build Windows ────────────────────────────────────
function Build-Windows {
    Write-Host ''
    Write-Host '──────────────────────────────────────────────────' -ForegroundColor Yellow
    Write-Host '  Building Windows Release' -ForegroundColor Yellow
    Write-Host '──────────────────────────────────────────────────' -ForegroundColor Yellow

    Push-Location $ProjectRoot
    try {
        $flags = $SharedFlags -join ' '
        Write-Host "  > flutter build windows $flags" -ForegroundColor DarkGray
        Invoke-Expression "flutter build windows $flags"

        if ($LASTEXITCODE -ne 0) { throw 'Windows build failed.' }

        $SourceDir = Join-Path $ProjectRoot 'build\windows\x64\runner\Release'

        # ── Timestamped archive → build/releases/
        $ZipName = "EmotionEye_v${AppVersion}_Windows_$Timestamp.zip"
        $ZipPath = Join-Path $ReleasesDir $ZipName
        Write-Host "  Compressing → $ZipName" -ForegroundColor DarkGray
        Compress-Archive -Path "$SourceDir\*" -DestinationPath $ZipPath -Force

        # ── Latest archive → web/downloads/ (for self-hosted distribution)
        $LatestZip = Join-Path $WebDownloads 'EmotionEye-Windows-latest.zip'
        Copy-Item $ZipPath $LatestZip -Force

        # ── Bundle into Flutter assets (for native in-app download)
        $AssetsReleases = Join-Path $ProjectRoot 'assets\releases'
        if (!(Test-Path $AssetsReleases)) {
            New-Item -ItemType Directory -Path $AssetsReleases -Force | Out-Null
        }
        $AssetZip = Join-Path $AssetsReleases 'windows.zip'
        Copy-Item $ZipPath $AssetZip -Force
        Write-Host "  ✔ Asset bundle copy: $AssetZip" -ForegroundColor Green


        $SizeMB = [math]::Round((Get-Item $ZipPath).Length / 1MB, 2)
        Write-Host "  ✔ Windows build ($SizeMB MB): $ZipPath" -ForegroundColor Green
        Write-Host "  ✔ Latest copy: $LatestZip" -ForegroundColor Green
    }
    finally { Pop-Location }
}

# ── Helper: Build Android APK ────────────────────────────────
function Build-Android {
    Write-Host ''
    Write-Host '──────────────────────────────────────────────────' -ForegroundColor Yellow
    Write-Host '  Building Android APK Release' -ForegroundColor Yellow
    Write-Host '──────────────────────────────────────────────────' -ForegroundColor Yellow

    Push-Location $ProjectRoot
    try {
        $flags = $SharedFlags -join ' '
        Write-Host "  > flutter build apk $flags" -ForegroundColor DarkGray
        Invoke-Expression "flutter build apk $flags"

        if ($LASTEXITCODE -ne 0) { throw 'Android APK build failed.' }

        $ApkSource = Join-Path $ProjectRoot 'build\app\outputs\flutter-apk\app-release.apk'

        # ── Timestamped copy → build/releases/
        $ApkName = "EmotionEye_v${AppVersion}_Android_$Timestamp.apk"
        $ApkDest = Join-Path $ReleasesDir $ApkName
        Copy-Item $ApkSource $ApkDest -Force

        # ── Latest copy → web/downloads/ (for self-hosted distribution)
        $LatestApk = Join-Path $WebDownloads 'EmotionEye-Android-latest.apk'
        Copy-Item $ApkSource $LatestApk -Force

        $SizeMB = [math]::Round((Get-Item $ApkDest).Length / 1MB, 2)
        Write-Host "  ✔ Android APK ($SizeMB MB): $ApkDest" -ForegroundColor Green
        Write-Host "  ✔ Latest copy: $LatestApk" -ForegroundColor Green
    }
    finally { Pop-Location }
}

# ── Helper: Build Web ────────────────────────────────────────
function Build-Web {
    Write-Host ''
    Write-Host '──────────────────────────────────────────────────' -ForegroundColor Yellow
    Write-Host '  Building Web Release' -ForegroundColor Yellow
    Write-Host '──────────────────────────────────────────────────' -ForegroundColor Yellow

    Push-Location $ProjectRoot
    try {
        Write-Host "  > flutter build web --release --tree-shake-icons" -ForegroundColor DarkGray
        flutter build web --release --tree-shake-icons

        if ($LASTEXITCODE -ne 0) { throw 'Web build failed.' }

        Write-Host "  ✔ Web build ready: build\web\" -ForegroundColor Green
        Write-Host "    Deploy this folder to your static hosting provider." -ForegroundColor DarkGray
    }
    finally { Pop-Location }
}

# ── Run ──────────────────────────────────────────────────────
Invoke-Clean

switch ($Target) {
    'windows' { Build-Windows }
    'android' { Build-Android }
    'web'     { Build-Web }
    'all'     {
        Build-Android
        Build-Windows
        Build-Web
    }
}

Write-Host ''
Write-Host '═══════════════════════════════════════════════════════' -ForegroundColor Cyan
Write-Host '  Build complete!' -ForegroundColor Cyan
Write-Host ''
Write-Host "  Releases      : $ReleasesDir" -ForegroundColor White
Write-Host "  Web downloads : $WebDownloads" -ForegroundColor White
Write-Host ''
Write-Host '  Next steps:' -ForegroundColor White
Write-Host '    1. Deploy build\web\ to your static host' -ForegroundColor DarkGray
Write-Host '    2. Or upload releases to GitHub Releases' -ForegroundColor DarkGray
Write-Host '═══════════════════════════════════════════════════════' -ForegroundColor Cyan
Write-Host ''
