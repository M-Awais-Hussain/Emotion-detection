/// Centralized application metadata, version information, and download config.
///
/// Update this file when releasing new versions.
/// The build scripts and UI reference these constants.
class AppInfo {
  AppInfo._();

  // ── Version ──────────────────────────────────────────────
  static const String appVersion = '1.1.0';
  static const int buildNumber = 2;
  static const String fullVersion = '$appVersion+$buildNumber';
  static const String releaseDate = '2026-06-12';

  // ── Identity ─────────────────────────────────────────────
  static const String appName = 'Emotion Eye';
  static const String appId = 'com.emotioneye.app';
  static const String developerName = 'EmotionEye Team';
  static const String appDescription =
      'Detect, understand, and improve your emotional well-being';

  // ── Download Configuration ───────────────────────────────
  // Point these to where your builds are hosted.
  // Option A: GitHub Releases (recommended for public projects)
  // Option B: Self-hosted in web/downloads/ (deployed alongside the web app)
  // Android: self-hosted alongside the web app (web/downloads/).
  static const String androidDownloadUrl =
      'downloads/EmotionEye-Android-latest.apk';

  // Windows: self-hosted alongside the web app (web/downloads/).
  // Run: .\scripts\build.ps1 -Target windows  to generate this file.
  // Falls back to GitHub Releases via _downloadWindowsBuild if not bundled.
  static const String windowsDownloadUrl =
      'downloads/EmotionEye-Windows-latest.zip';

  // GitHub Releases fallback (update with your repo)
  static const String githubReleasesUrl =
      'https://github.com/M-Awais-Hussain/Emotion-detection/releases/latest';

  // ── Download Metadata ────────────────────────────────────
  static const DownloadInfo windowsInfo = DownloadInfo(
    platform: 'Windows',
    fileName: 'EmotionEye-Windows-latest.zip',
    fileSize: '~45 MB',
    format: 'ZIP',
    minVersion: 'Windows 10 (64-bit)',
  );

  static const DownloadInfo androidInfo = DownloadInfo(
    platform: 'Android',
    fileName: 'EmotionEye-Android-latest.apk',
    fileSize: '~27 MB',
    format: 'APK',
    minVersion: 'Android 5.0 (Lollipop)',
  );

  // ── System Requirements ──────────────────────────────────
  static const SystemRequirements windowsRequirements = SystemRequirements(
    os: 'Windows 10 or later (64-bit)',
    ram: '4 GB RAM minimum',
    storage: '200 MB available disk space',
    display: '1280 × 720 minimum resolution',
    other: [
      'Internet connection (for AI chat & emotion detection)',
      'Webcam (for emotion detection feature)',
    ],
  );

  static const SystemRequirements androidRequirements = SystemRequirements(
    os: 'Android 5.0 (API 21) or later',
    ram: '2 GB RAM minimum',
    storage: '100 MB available storage',
    display: '720 × 1280 minimum resolution',
    other: [
      'Internet connection (for AI chat & emotion detection)',
      'Camera permission (for emotion detection)',
      'Notification permission (for streak reminders)',
    ],
  );

  // ── Changelog ────────────────────────────────────────────
  static const List<ReleaseNote> changelog = [
    ReleaseNote(
      version: '1.1.0',
      date: '2026-06-12',
      highlights: [
        'Added downloadable builds for Windows & Android',
        'Dynamic productivity calculation based on mood & study hours',
        'PWA support for web installation',
        'Professional download page with version history',
        'Improved app metadata and branding',
        'Automated build scripts for release generation',
      ],
    ),
    ReleaseNote(
      version: '1.0.0',
      date: '2024-01-01',
      highlights: [
        'Initial release of Emotion Eye',
        'Real-time emotion detection from camera',
        'AI-powered mood chat assistant',
        'Study performance tracking',
        'Mood improvement dashboard',
        'Yoga & exercise recommendations',
        'Daily streak system with notifications',
        'Interactive mini-games for mood improvement',
      ],
    ),
  ];
}

/// Metadata about a downloadable build.
class DownloadInfo {
  final String platform;
  final String fileName;
  final String fileSize;
  final String format;
  final String minVersion;

  const DownloadInfo({
    required this.platform,
    required this.fileName,
    required this.fileSize,
    required this.format,
    required this.minVersion,
  });
}

/// System requirements for a platform.
class SystemRequirements {
  final String os;
  final String ram;
  final String storage;
  final String display;
  final List<String> other;

  const SystemRequirements({
    required this.os,
    required this.ram,
    required this.storage,
    required this.display,
    required this.other,
  });
}

/// A single release entry for the changelog.
class ReleaseNote {
  final String version;
  final String date;
  final List<String> highlights;

  const ReleaseNote({
    required this.version,
    required this.date,
    required this.highlights,
  });
}
