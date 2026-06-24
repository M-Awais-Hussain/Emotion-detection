/// Centralized application metadata and version information.
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

  // ── Download URLs ────────────────────────────────────────
  // Update these when you host the builds (e.g. on GitHub Releases).
  static const String windowsDownloadUrl =
      'https://github.com/M-Awais-Hussain/Emotion-detection/releases/latest';
  static const String androidDownloadUrl =
      'https://github.com/M-Awais-Hussain/Emotion-detection/releases/latest';

  // ── Changelog ────────────────────────────────────────────
  static const List<ReleaseNote> changelog = [
    ReleaseNote(
      version: '1.1.0',
      date: '2026-06-12',
      highlights: [
        'Added downloadable builds for Windows & Android',
        'Dynamic productivity calculation based on mood & study hours',
        'PWA support for web installation',
        'Improved app metadata and branding',
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
      ],
    ),
  ];
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
