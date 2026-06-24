<#
.SYNOPSIS
  Build script for Emotion Eye – generates optimised production builds.

.DESCRIPTION
  Creates release builds for Windows (exe) and/or Android (APK).
  Output is placed under build/releases/.

.PARAMETER Target
  Which platform to build: windows, android, or all. Default: all.

.EXAMPLE
  .\scripts\build.ps1 -Target windows
  .\scripts\build.ps1 -Target android
  .\scripts\build.ps1 -Target all
#>

param(
    [ValidateSet('windows', 'android', 'all')]
    [string]$Target = 'all'
)

$ErrorActionPreference = 'Stop'

# ── Constants ────────────────────────────────────────────────
$ProjectRoot   = Split-Path -Parent $PSScriptRoot
$ReleasesDir   = Join-Path $ProjectRoot 'build\releases'
$Timestamp     = Get-Date -Format 'yyyyMMdd_HHmmss'

# Read version from pubspec.yaml
$PubspecPath = Join-Path $ProjectRoot 'pubspec.yaml'
$VersionLine = Select-String -Path $PubspecPath -Pattern '^version:\s*(.+)$'
$AppVersion  = if ($VersionLine) { $VersionLine.Matches[0].Groups[1].Value.Trim() } else { 'unknown' }

Write-Host ''
Write-Host '╔══════════════════════════════════════════════════╗' -ForegroundColor Cyan
Write-Host '║        Emotion Eye — Build Script                ║' -ForegroundColor Cyan
Write-Host '╚══════════════════════════════════════════════════╝' -ForegroundColor Cyan
Write-Host "  Version  : $AppVersion"
Write-Host "  Target   : $Target"
Write-Host "  Output   : $ReleasesDir"
Write-Host ''

# Ensure output directory exists
if (!(Test-Path $ReleasesDir)) {
    New-Item -ItemType Directory -Path $ReleasesDir -Force | Out-Null
}

# ── Shared flags for size optimisation ───────────────────────
$SharedFlags = @(
    '--release'
    '--tree-shake-icons'
    '--split-debug-info=build/debug-info'
    '--obfuscate'
)

# ── Helper: Build Windows ────────────────────────────────────
function Build-Windows {
    Write-Host '─── Building Windows Release ───' -ForegroundColor Yellow

    Push-Location $ProjectRoot
    try {
        $cmd = "flutter build windows $($SharedFlags -join ' ')"
        Write-Host "  > $cmd" -ForegroundColor DarkGray
        Invoke-Expression $cmd

        if ($LASTEXITCODE -ne 0) { throw 'Windows build failed.' }

        $SourceDir = Join-Path $ProjectRoot 'build\windows\x64\runner\Release'
        $ZipName   = "EmotionEye_v${AppVersion}_Windows_$Timestamp.zip"
        $ZipPath   = Join-Path $ReleasesDir $ZipName

        Write-Host "  Compressing to $ZipName …" -ForegroundColor DarkGray
        Compress-Archive -Path "$SourceDir\*" -DestinationPath $ZipPath -Force

        Write-Host "  ✔ Windows build ready: $ZipPath" -ForegroundColor Green
    }
    finally { Pop-Location }
}

# ── Helper: Build Android APK ────────────────────────────────
function Build-Android {
    Write-Host '─── Building Android APK ───' -ForegroundColor Yellow

    Push-Location $ProjectRoot
    try {
        $cmd = "flutter build apk $($SharedFlags -join ' ')"
        Write-Host "  > $cmd" -ForegroundColor DarkGray
        Invoke-Expression $cmd

        if ($LASTEXITCODE -ne 0) { throw 'Android build failed.' }

        $ApkSource = Join-Path $ProjectRoot 'build\app\outputs\flutter-apk\app-release.apk'
        $ApkName   = "EmotionEye_v${AppVersion}_Android_$Timestamp.apk"
        $ApkDest   = Join-Path $ReleasesDir $ApkName

        Copy-Item $ApkSource $ApkDest -Force

        $SizeMB = [math]::Round((Get-Item $ApkDest).Length / 1MB, 2)
        Write-Host "  ✔ Android APK ready ($SizeMB MB): $ApkDest" -ForegroundColor Green
    }
    finally { Pop-Location }
}

# ── Run ──────────────────────────────────────────────────────
Write-Host 'Running flutter clean …' -ForegroundColor DarkGray
Push-Location $ProjectRoot
flutter clean | Out-Null
flutter pub get | Out-Null
Pop-Location

switch ($Target) {
    'windows' { Build-Windows }
    'android' { Build-Android }
    'all'     { Build-Windows; Build-Android }
}

Write-Host ''
Write-Host '════════════════════════════════════════════════════' -ForegroundColor Cyan
Write-Host '  Build complete! Check build\releases\ for output.' -ForegroundColor Cyan
Write-Host '════════════════════════════════════════════════════' -ForegroundColor Cyan
Write-Host ''
