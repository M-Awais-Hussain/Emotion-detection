# Downloads Directory

This directory holds the latest release builds for self-hosted distribution.

Files placed here are served alongside the web app and are linked from the
in-app Download page.

## Expected files

| File | Description |
|------|-------------|
| `EmotionEye-Android-latest.apk` | Latest Android APK |
| `EmotionEye-Windows-latest.zip` | Latest Windows portable build |

## How to update

Run the build script to automatically generate and copy builds here:

```powershell
.\scripts\build.ps1 -Target all
```

Or manually copy your builds:

```powershell
copy build\app\outputs\flutter-apk\app-release.apk web\downloads\EmotionEye-Android-latest.apk
```

> **Note:** These files may be large. Consider using Git LFS or hosting on
> GitHub Releases instead, and updating the URLs in `lib/config/app_info.dart`.
