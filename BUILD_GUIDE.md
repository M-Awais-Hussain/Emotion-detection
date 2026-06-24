# Emotion Eye — Build & Distribution Guide

Complete instructions for building, distributing, and releasing the Emotion Eye application on Windows and Android.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Mode](#development-mode)
3. [Production Builds](#production-builds)
4. [Android Signing (for Play Store)](#android-signing-for-play-store)
5. [Version Management](#version-management)
6. [Automated Build Script](#automated-build-script)
7. [PWA / Web Installation](#pwa--web-installation)
8. [Troubleshooting](#troubleshooting)

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

### Windows Desktop (.exe)

```powershell
# Build release
flutter build windows --release --tree-shake-icons

# Output location:
# build\windows\x64\runner\Release\emotioneye.exe
```

The entire `Release` folder is your distributable — zip it and share. All required DLLs are included.

### Android APK

```bash
# Build release APK (debug-signed, for direct installation)
flutter build apk --release --tree-shake-icons

# Output location:
# build\app\outputs\flutter-apk\app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release

# Output location:
# build\app\outputs\bundle\release\app-release.aab
```

### Web (with PWA support)

```bash
flutter build web --release --tree-shake-icons

# Output location:
# build\web\
# Deploy this folder to any static hosting (Netlify, Vercel, GitHub Pages)
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

> **⚠️ Never commit `key.properties` to version control!**  
> Add it to `.gitignore`.

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
| `lib/config/app_info.dart` | `appVersion`, `buildNumber`, `releaseDate`, changelog |

### Version Format

- **`X.Y.Z`** — Semantic version (major.minor.patch)
- **`+N`** — Build number (always increment for each release)

### Release Checklist

1. Update version in `pubspec.yaml`
2. Update `AppInfo` constants in `lib/config/app_info.dart`
3. Add a new `ReleaseNote` entry to the changelog
4. Run the build script
5. Test the builds
6. Upload to GitHub Releases or your hosting

---

## Automated Build Script

A PowerShell build script is provided at `scripts/build.ps1`:

```powershell
# Build everything (Windows + Android)
.\scripts\build.ps1 -Target all

# Build only Windows
.\scripts\build.ps1 -Target windows

# Build only Android
.\scripts\build.ps1 -Target android
```

Output is placed in `build/releases/` with timestamped filenames:
- `EmotionEye_v1.1.0_Windows_20260612_120000.zip`
- `EmotionEye_v1.1.0_Android_20260612_120000.apk`

---

## PWA / Web Installation

The web build is configured as a Progressive Web App. Users can install it from:

- **Chrome**: Click the install icon in the address bar
- **Edge**: Click the "App available" icon
- **Mobile Chrome**: "Add to Home Screen" from the menu

The PWA works offline after initial load thanks to the Flutter service worker.

---

## Troubleshooting

### Windows build fails with "Visual Studio not found"

Install Visual Studio 2022 with the **Desktop development with C++** workload:
```
winget install Microsoft.VisualStudio.2022.Community
```
Then install the C++ workload from Visual Studio Installer.

### Android build fails with "SDK not found"

```bash
flutter doctor --android-licenses
```
Accept all licenses, then retry.

### APK is too large

Use the split APK approach:
```bash
flutter build apk --split-per-abi --release --tree-shake-icons
```
This generates separate APKs for each CPU architecture (~40% smaller).

### "Gradle build failed" on Android

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### Windows build missing DLLs

Always distribute the **entire** `Release` folder contents, not just the `.exe`. All required DLLs are co-located with the executable.
