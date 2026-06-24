# Emotion Eye — Build & Distribution Guide

Complete instructions for building, distributing, and releasing the Emotion Eye application on Windows, Android, and Web.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Mode](#development-mode)
3. [Production Builds](#production-builds)
4. [Self-Hosted Distribution](#self-hosted-distribution)
5. [GitHub Releases Distribution](#github-releases-distribution)
6. [Android Signing (for Play Store)](#android-signing-for-play-store)
7. [Version Management](#version-management)
8. [Automated Build Script](#automated-build-script)
9. [PWA / Web Installation](#pwa--web-installation)
10. [Deployment Workflow](#deployment-workflow)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

| Tool | Minimum Version | Check Command |
|------|----------------|---------------|
| Flutter SDK | 3.5+ | `flutter --version` |
| Dart SDK | 3.5+ | `dart --version` |
| Android SDK | API 21+ | `flutter doctor` |
| Visual Studio 2022 | Desktop C++ workload | `flutter doctor` |
| Java JDK | 17 | `java -version` |

Run `flutter doctor -v` to verify everything is configured.

---

## Development Mode

```bash
# Run on Chrome (web)
flutter run -d chrome

# Run on connected Android device
flutter run -d <device-id>

# Run on Windows desktop
flutter run -d windows

# Hot reload is automatic; press 'r' in terminal for manual reload
```

---

## Production Builds

### Android APK

```bash
# Build release APK (debug-signed, for direct installation/sideloading)
flutter build apk --release --tree-shake-icons

# Output location:
#   build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Google Play Store)

```bash
flutter build appbundle --release

# Output location:
#   build/app/outputs/bundle/release/app-release.aab
```

### Split APKs (smaller, per-architecture)

```bash
flutter build apk --split-per-abi --release --tree-shake-icons

# Output:
#   build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk  (~25MB)
#   build/app/outputs/flutter-apk/app-arm64-v8a-release.apk    (~27MB)
#   build/app/outputs/flutter-apk/app-x86_64-release.apk       (~28MB)
```

### Windows Desktop (.exe)

```powershell
flutter build windows --release --tree-shake-icons

# Output location (entire folder is the distributable):
#   build\windows\x64\runner\Release\
```

Zip the entire `Release` folder and distribute. All required DLLs are bundled.

### Web (with PWA support)

```bash
flutter build web --release --tree-shake-icons

# Output location:
#   build/web/
# Deploy this folder to any static hosting
```

---

## Self-Hosted Distribution

The app has a built-in download page that links to `web/downloads/`. When you deploy the web build, these files are served directly alongside the web app.

### How it works

```
web/
├── downloads/
│   ├── EmotionEye-Android-latest.apk    ← Android download
│   └── EmotionEye-Windows-latest.zip    ← Windows download
├── index.html
├── manifest.json
└── ...
```

### Steps to set up

1. **Build the native apps:**
   ```powershell
   .\scripts\build.ps1 -Target android
   .\scripts\build.ps1 -Target windows
   ```
   This automatically copies builds into `web/downloads/`.

2. **Build the web app:**
   ```powershell
   .\scripts\build.ps1 -Target web
   ```

3. **Deploy `build/web/`** to your hosting (Netlify, Vercel, GitHub Pages, etc.).

4. Users can now click "Download for Android" or "Download for Windows" on the Downloads page and the files download directly.

### Updating releases

Simply re-run the build script — it overwrites `web/downloads/EmotionEye-*-latest.*` with the new builds.

---

## GitHub Releases Distribution

If you prefer hosting on GitHub Releases instead of self-hosting:

1. Build the APK and Windows zip using the build script.
2. Create a new release on GitHub at:
   `https://github.com/M-Awais-Hussain/Emotion-detection/releases/new`
3. Upload the APK and ZIP files.
4. Update the download URLs in `lib/config/app_info.dart`:

```dart
static const String windowsDownloadUrl =
    'https://github.com/M-Awais-Hussain/Emotion-detection/releases/download/v1.1.0/EmotionEye-Windows.zip';
static const String androidDownloadUrl =
    'https://github.com/M-Awais-Hussain/Emotion-detection/releases/download/v1.1.0/EmotionEye-Android.apk';
```

---

## Android Signing (for Play Store)

For debug/testing, the default debug keystore is used. For Play Store publishing:

### 1. Generate a Keystore

```bash
keytool -genkey -v -keystore ~/emotion-eye-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias emotion-eye
```

### 2. Create `android/key.properties`

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=emotion-eye
storeFile=<path-to-your-keystore>/emotion-eye-release.jks
```

> ⚠️ **Never commit `key.properties` to version control!** Add it to `.gitignore`.

### 3. Update `android/app/build.gradle`

Add before the `android {` block:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Replace the `release` build type:

```groovy
buildTypes {
    release {
        signingConfig signingConfigs.create("release") {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

---

## Version Management

Version is managed in **two places** — keep them in sync:

| File | What to Update |
|------|---------------|
| `pubspec.yaml` | `version: X.Y.Z+N` (Flutter version) |
| `lib/config/app_info.dart` | `appVersion`, `buildNumber`, `releaseDate`, file sizes, changelog |

### Version Format

- **`X.Y.Z`** — Semantic version (major.minor.patch)
- **`+N`** — Build number (always increment for each release)

### Release Checklist

1. ☐ Update version in `pubspec.yaml`
2. ☐ Update `AppInfo` constants in `lib/config/app_info.dart`
3. ☐ Add a new `ReleaseNote` entry to the changelog
4. ☐ Update file sizes in `DownloadInfo` if they changed significantly
5. ☐ Run `.\scripts\build.ps1 -Target all`
6. ☐ Test the APK on a real device
7. ☐ Test the Windows zip on a fresh machine
8. ☐ Deploy `build/web/` to hosting
9. ☐ (Optional) Upload to GitHub Releases

---

## Automated Build Script

A PowerShell build script is provided at `scripts/build.ps1`:

```powershell
# Build everything (Android + Windows + Web)
.\scripts\build.ps1 -Target all

# Build only Android
.\scripts\build.ps1 -Target android

# Build only Windows
.\scripts\build.ps1 -Target windows

# Build only Web
.\scripts\build.ps1 -Target web

# Skip flutter clean for faster iteration
.\scripts\build.ps1 -Target all -SkipClean
```

### Output locations

| Location | Purpose |
|----------|---------|
| `build/releases/` | Timestamped archives for release tracking |
| `web/downloads/` | Latest builds served by the web app |
| `build/web/` | Deployable web build |

### Filename conventions

- `build/releases/EmotionEye_v1.1.0_Windows_20260612_120000.zip`
- `build/releases/EmotionEye_v1.1.0_Android_20260612_120000.apk`
- `web/downloads/EmotionEye-Windows-latest.zip`
- `web/downloads/EmotionEye-Android-latest.apk`

---

## PWA / Web Installation

The web build is configured as a Progressive Web App (PWA). Users can install it from:

- **Chrome**: Click the install icon (⊕) in the address bar
- **Edge**: Click the "App available" icon
- **Mobile Chrome**: Menu → "Add to Home Screen"

The in-app Downloads page includes a PWA install prompt when running in a browser.

---

## Deployment Workflow

### Full release workflow

```
1. Code changes → commit & push
2. Update version numbers (pubspec.yaml + app_info.dart)
3. Run: .\scripts\build.ps1 -Target all
4. Test APK on Android device
5. Test Windows zip on desktop
6. Deploy build\web\ to hosting
7. (Optional) Create GitHub Release with APK + ZIP
```

### Quick update (code-only, same version)

```
1. Code changes → commit & push
2. Run: .\scripts\build.ps1 -Target web -SkipClean
3. Deploy build\web\ to hosting
```

---

## Troubleshooting

### Windows build fails with "Visual Studio not found"

Install Visual Studio 2022 with the **Desktop development with C++** workload:
```
winget install Microsoft.VisualStudio.2022.Community
```

### Android build fails with "SDK not found"

```bash
flutter doctor --android-licenses
```
Accept all licenses, then retry.

### APK is too large

Use split APKs:
```bash
flutter build apk --split-per-abi --release --tree-shake-icons
```

### "Gradle build failed"

```bash
cd android && ./gradlew clean && cd ..
flutter clean && flutter pub get
flutter build apk --release
```

### Windows build missing DLLs

Always distribute the **entire** `Release` folder, not just `emotioneye.exe`.

### Download links return 404

Make sure the build script placed files in `web/downloads/` before building the web app. The correct order is:
1. Build Android/Windows → copies to `web/downloads/`
2. Build Web → includes `web/downloads/` in the output

### Web app not installable as PWA

- Ensure you're serving over HTTPS
- Check Chrome DevTools → Application → Manifest for errors
- Clear service worker cache: DevTools → Application → Service Workers → Unregister
