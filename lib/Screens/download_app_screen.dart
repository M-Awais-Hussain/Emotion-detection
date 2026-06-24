import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_info.dart';
import '../theme/app_theme.dart';

// Web-only: resolve a relative path to an absolute URL for file downloads.
String _resolveWebDownloadUrl(String relativePath) {
  if (kIsWeb) {
    // On web, Uri.base gives us the app's base URL (e.g. https://example.com/).
    // We join the relative path to make a full download URL.
    return Uri.base.resolve(relativePath).toString();
  }
  return relativePath;
}

/// Professional download & distribution page — NetMirror-style.
///
/// Sections:
///   1. Hero / App Header
///   2. Latest Version — platform download cards
///   3. System Requirements
///   4. Release Notes (latest)
///   5. Version History
///   6. PWA install hint (web only)
class DownloadAppScreen extends StatelessWidget {
  const DownloadAppScreen({super.key});

  // ── Helpers ────────────────────────────────────────────────

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Copies the bundled `assets/releases/android.apk` asset out to a real
  /// location on disk so the user can install it.
  ///
  /// Notes:
  /// - Flutter assets are NOT files on disk at runtime — they're packed into
  ///   the app bundle. You can't `File('assets/...')` them directly. They
  ///   must be read through `rootBundle.load()` and written out manually.
  /// - On web (`kIsWeb`) there's no real filesystem to write to — APK
  ///   installs don't apply there anyway, so we just no-op / inform.
  /// - On Android 10 (API 29) and below, writing to public storage requires
  ///   the `WRITE_EXTERNAL_STORAGE` permission. On Android 11+ scoped
  ///   storage applies, so we write into the app's own external files dir
  ///   (no special permission needed) and let the share/install intent
  ///   handle the rest.
  /// Handles the Android APK download.
  ///
  /// - On **web**: triggers a browser file-download by navigating to the
  ///   hosted APK URL (served from `web/downloads/`).
  /// - On **Android**: extracts the bundled asset APK to the Downloads folder
  ///   and offers an INSTALL action.
  /// - On other native platforms: opens the APK URL in the browser.
  Future<String?> _saveApkToDownloads(BuildContext context) async {
    // ── Web: just navigate to the hosted download URL ──────────────────────
    if (kIsWeb) {
      final url = _resolveWebDownloadUrl(AppInfo.androidDownloadUrl);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Could not open the download URL. Please check your connection.'),
              action: SnackBarAction(
                label: 'COPY URL',
                onPressed: () {},
              ),
            ),
          );
        }
      }
      return null;
    }

    // ── Non-Android native: open in browser ────────────────────────────────
    if (!Platform.isAndroid) {
      await _launchUrl(AppInfo.androidDownloadUrl);
      return null;
    }

    // ── Android native: extract bundled APK asset to disk ──────────────────
    try {
      // Request storage permission (needed on Android <= 10 / API <= 29).
      if (await Permission.storage.isDenied) {
        final status = await Permission.storage.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Storage permission is required to save the APK.'),
              ),
            );
          }
          return null;
        }
      }

      // Read the bundled asset's raw bytes.
      final byteData = await rootBundle.load('assets/releases/android.apk');
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      // Pick a real, writable directory.
      // Prefer the public Downloads folder; fall back to the app's
      // external storage directory if Downloads isn't accessible.
      Directory? targetDir;
      try {
        targetDir = Directory('/storage/emulated/0/Download');
        if (!await targetDir.exists()) {
          targetDir = await getExternalStorageDirectory();
        }
      } catch (_) {
        targetDir = await getExternalStorageDirectory();
      }

      targetDir ??= await getApplicationDocumentsDirectory();
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final fileName = '${AppInfo.appName.replaceAll(' ', '_')}_v${AppInfo.appVersion}.apk';
      final destinationFile = File('${targetDir.path}/$fileName');
      await destinationFile.writeAsBytes(bytes, flush: true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to ${destinationFile.path}'),
            action: SnackBarAction(
              label: 'INSTALL',
              onPressed: () => _openApk(destinationFile.path),
            ),
          ),
        );
      }

      return destinationFile.path;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save APK: $e')),
        );
      }
      return null;
    }
  }

  /// Opens the saved APK with the system installer.
  Future<void> _openApk(String path) async {
    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Handles the Windows build download.
  ///
  /// - On **web**: triggers a browser file-download by navigating to the
  ///   hosted ZIP URL (served from `web/downloads/`).
  /// - On **Windows native**: extracts the bundled asset ZIP to the user's
  ///   Downloads folder and opens File Explorer there.
  /// - On other native platforms: opens GitHub Releases in the browser.
  // Future<void> _downloadWindowsBuild(BuildContext context) async {
  //   // ── Web: navigate to the hosted ZIP download URL ────────────────────────
  //   if (kIsWeb) {
  //     final url = _resolveWebDownloadUrl(AppInfo.windowsDownloadUrl);
  //     final uri = Uri.parse(url);
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     } else {
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: const Text(
  //                 'Could not open the download URL. Please check your connection.'),
  //             action: SnackBarAction(
  //               label: 'OPEN URL',
  //               onPressed: () => _launchUrl(AppInfo.windowsDownloadUrl),
  //             ),
  //           ),
  //         );
  //       }
  //     }
  //     return;
  //   }

  //   // ── Windows native: extract bundled ZIP asset to Downloads folder ───────
  //   if (!kIsWeb && Platform.isWindows) {
  //     try {
  //       // Read the bundled asset's raw bytes.
  //       final byteData =
  //           await rootBundle.load('assets/releases/windows.zip');
  //       final bytes = byteData.buffer.asUint8List(
  //         byteData.offsetInBytes,
  //         byteData.lengthInBytes,
  //       );

  //       // Write to the user's Downloads folder.
  //       final homeDir = Platform.environment['USERPROFILE'] ??
  //           Platform.environment['HOME'] ??
  //           '';
  //       Directory targetDir;
  //       if (homeDir.isNotEmpty) {
  //         targetDir = Directory('$homeDir\\Downloads');
  //         if (!await targetDir.exists()) {
  //           targetDir = await getApplicationDocumentsDirectory();
  //         }
  //       } else {
  //         targetDir = await getApplicationDocumentsDirectory();
  //       }

  //       if (!await targetDir.exists()) {
  //         await targetDir.create(recursive: true);
  //       }

  //       final fileName =
  //           '${AppInfo.appName.replaceAll(' ', '_')}_v${AppInfo.appVersion}_Windows.zip';
  //       final destinationFile =
  //           File('${targetDir.path}\\$fileName');
  //       await destinationFile.writeAsBytes(bytes, flush: true);

  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Saved to ${destinationFile.path}'),
  //             action: SnackBarAction(
  //               label: 'OPEN FOLDER',
  //               onPressed: () =>
  //                   _launchUrl('file:///${targetDir.path.replaceAll('\\', '/')}'),
  //             ),
  //           ),
  //         );
  //       }
  //       return;
  //     } catch (e) {
  //       // Asset not bundled — fall through to GitHub Releases.
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: const Text(
  //                 'Bundled build not found. Opening GitHub Releases…'),
  //             action: SnackBarAction(
  //               label: 'OPEN',
  //               onPressed: () => _launchUrl(AppInfo.windowsDownloadUrl),
  //             ),
  //           ),
  //         );
  //         await _launchUrl(AppInfo.windowsDownloadUrl);
  //       }
  //       return;
  //     }
  //   }

  //   // ── All other native platforms: open GitHub Releases ───────────────────
  //   await _launchUrl(AppInfo.windowsDownloadUrl);
  // }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download App'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spacingL),

                  // ── Section 1: Latest Version Downloads ──
                  _sectionTitle(Icons.cloud_download_rounded, 'Latest Version'),
                  const SizedBox(height: AppTheme.spacingS),
                  _buildDownloadCard(
                    onTap: () => _saveApkToDownloads(context),
                    icon: Icons.phone_android_rounded,
                    iconGradient: const LinearGradient(
                      colors: [Color(0xFF3DDC84), Color(0xFF00C853)],
                    ),
                    platform: 'Android',
                    info: AppInfo.androidInfo,
                    url: AppInfo.androidDownloadUrl,
                  ),


                  if (kIsWeb) ...[
                    const SizedBox(height: AppTheme.spacingS),
                    _buildPwaCard(),
                  ],

                  const SizedBox(height: AppTheme.spacingXL),

                  // ── Section 2: System Requirements ──
                  _sectionTitle(Icons.settings_suggest_rounded, 'System Requirements'),
                  const SizedBox(height: AppTheme.spacingS),
                  _buildRequirementsCard(
                    platform: 'Android',
                    icon: Icons.phone_android_rounded,
                    reqs: AppInfo.androidRequirements,
                  ),


                  const SizedBox(height: AppTheme.spacingXL),

                  // ── Section 3: Release Notes (latest) ──
                  _sectionTitle(Icons.new_releases_rounded, 'Release Notes'),
                  const SizedBox(height: AppTheme.spacingS),
                  if (AppInfo.changelog.isNotEmpty)
                    _buildLatestReleaseCard(AppInfo.changelog.first),

                  const SizedBox(height: AppTheme.spacingXL),

                  // ── Section 4: Version History ──
                  _sectionTitle(Icons.history_rounded, 'Version History'),
                  const SizedBox(height: AppTheme.spacingS),
                  _buildVersionHistoryCard(),

                  const SizedBox(height: AppTheme.spacingXL),

                  // ── Section 5: GitHub link ──
                  _buildGithubCard(),

                  const SizedBox(height: AppTheme.spacingXL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero Section ───────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF001F54),
            Color(0xFF2E5BAE),
            Color(0xFF4A90E2),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingXL,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.visibility_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            AppInfo.appName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            AppInfo.appDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            ),
            child: Text(
              'v${AppInfo.appVersion}  •  Released ${AppInfo.releaseDate}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section title ──────────────────────────────────────────

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppTheme.primaryMedium),
        const SizedBox(width: AppTheme.spacingS),
        Text(title, style: AppTheme.headingSmall),
      ],
    );
  }

  // ── Download Card ──────────────────────────────────────────

  Widget _buildDownloadCard({
    required IconData icon,
    required Gradient iconGradient,
    required String platform,
    required DownloadInfo info,
    required String url,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: AppTheme.borderLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Platform icon with gradient background
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: iconGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Download for $platform',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'v${AppInfo.appVersion}  •  ${info.fileSize}  •  ${info.format}',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Metadata row
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  children: [
                    _metaChip(Icons.calendar_today, AppInfo.releaseDate),
                    const SizedBox(width: AppTheme.spacingM),
                    _metaChip(Icons.storage_rounded, info.fileSize),
                    const SizedBox(width: AppTheme.spacingM),
                    _metaChip(Icons.verified, 'v${AppInfo.appVersion}'),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingM),

              // Download button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    'Download $platform ${info.format}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMedium,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingS),

              // Min version note
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppTheme.textLight),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    'Requires ${info.minVersion} or later',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.bodySmall.copyWith(fontSize: 11)),
      ],
    );
  }

  // ── PWA Card ───────────────────────────────────────────────

  Widget _buildPwaCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      color: Colors.orange.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(Icons.install_desktop_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Install as Progressive Web App',
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Click the install icon in your browser\'s address bar to '
                    'add this app to your device — no download required.',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── System Requirements ────────────────────────────────────

  Widget _buildRequirementsCard({
    required String platform,
    required IconData icon,
    required SystemRequirements reqs,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryMedium),
        title: Text(
          '$platform Requirements',
          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppTheme.spacingM,
          0,
          AppTheme.spacingM,
          AppTheme.spacingM,
        ),
        children: [
          _requirementRow(Icons.computer, 'Operating System', reqs.os),
          _requirementRow(Icons.memory, 'RAM', reqs.ram),
          _requirementRow(Icons.sd_storage, 'Storage', reqs.storage),
          _requirementRow(Icons.aspect_ratio, 'Display', reqs.display),
          ...reqs.other.map(
            (item) => _requirementRow(Icons.check_circle_outline, 'Required', item),
          ),
        ],
      ),
    );
  }

  Widget _requirementRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Latest Release Card ────────────────────────────────────

  Widget _buildLatestReleaseCard(ReleaseNote release) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.new_releases_rounded,
                        size: 16,
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'v${release.version}',
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(release.date, style: AppTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'What\'s New',
              style: AppTheme.labelLarge,
            ),
            const SizedBox(height: AppTheme.spacingS),
            ...release.highlights.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingXS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.add_circle, size: 16, color: AppTheme.success),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: Text(h, style: AppTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Version History ────────────────────────────────────────

  Widget _buildVersionHistoryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingS,
                horizontal: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text('Version', style: AppTheme.labelMedium),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text('Date', style: AppTheme.labelMedium),
                  ),
                  Expanded(
                    child: Text('Changes', style: AppTheme.labelMedium),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.divider),

            // Rows
            ...AppInfo.changelog.asMap().entries.map((entry) {
              final release = entry.value;
              final isLatest = entry.key == 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 70,
                      child: Row(
                        children: [
                          Text(
                            'v${release.version}',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isLatest) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(release.date, style: AppTheme.bodySmall),
                    ),
                    Expanded(
                      child: Text(
                        release.highlights.join(', '),
                        style: AppTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── GitHub Card ────────────────────────────────────────────

  Widget _buildGithubCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: InkWell(
        onTap: () => _launchUrl(AppInfo.githubReleasesUrl),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF24292E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(Icons.code, color: Color(0xFF24292E)),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View on GitHub',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Source code, issues, and all release archives',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new,
                size: 18,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}