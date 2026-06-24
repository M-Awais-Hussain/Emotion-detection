import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_info.dart';
import '../theme/app_theme.dart';

/// Screen that shows app version info, platform download links,
/// and release notes / changelog.
class DownloadAppScreen extends StatelessWidget {
  const DownloadAppScreen({super.key});

  // ── Helpers ────────────────────────────────────────────────

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppInfoHeader(),
            const SizedBox(height: AppTheme.spacingL),

            Text('Available Platforms', style: AppTheme.headingSmall),
            const SizedBox(height: AppTheme.spacingS),
            _buildPlatformCard(
              icon: Icons.desktop_windows_rounded,
              iconColor: const Color(0xFF0078D4),
              platform: 'Windows Desktop',
              description:
                  'Standalone Windows application (.exe).\nRuns on Windows 10 and later.',
              buttonLabel: 'Download for Windows',
              url: AppInfo.windowsDownloadUrl,
            ),
            const SizedBox(height: AppTheme.spacingS),
            _buildPlatformCard(
              icon: Icons.phone_android_rounded,
              iconColor: const Color(0xFF3DDC84),
              platform: 'Android Mobile',
              description:
                  'Android application (.apk).\nSupports Android 5.0 (Lollipop) and above.',
              buttonLabel: 'Download for Android',
              url: AppInfo.androidDownloadUrl,
            ),

            if (kIsWeb) ...[
              const SizedBox(height: AppTheme.spacingS),
              _buildPwaCard(context),
            ],

            const SizedBox(height: AppTheme.spacingL),

            Text('Version Information', style: AppTheme.headingSmall),
            const SizedBox(height: AppTheme.spacingS),
            _buildVersionCard(),

            const SizedBox(height: AppTheme.spacingL),

            Text('Release Notes', style: AppTheme.headingSmall),
            const SizedBox(height: AppTheme.spacingS),
            _buildChangelogCard(),
          ],
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────

  Widget _buildAppInfoHeader() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Icon(
                Icons.visibility_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppInfo.appName, style: AppTheme.headingSmall),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    AppInfo.appDescription,
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    'by ${AppInfo.developerName}',
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

  Widget _buildPlatformCard({
    required IconData icon,
    required Color iconColor,
    required String platform,
    required String description,
    required String buttonLabel,
    required String url,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(platform, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(description, style: AppTheme.bodySmall),
                  const SizedBox(height: AppTheme.spacingM),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(url),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(buttonLabel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryMedium,
                        side: const BorderSide(color: AppTheme.primaryMedium),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingS,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPwaCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(Icons.install_desktop_rounded,
                  color: Colors.orange, size: 32),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Install as Web App',
                      style: AppTheme.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    'You can install this app directly from your browser.\n'
                    'Look for the install icon in your browser\'s address bar.',
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

  Widget _buildVersionCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            _versionRow('Version', AppInfo.appVersion),
            const Divider(color: AppTheme.divider),
            _versionRow('Build Number', '${AppInfo.buildNumber}'),
            const Divider(color: AppTheme.divider),
            _versionRow('Release Date', AppInfo.releaseDate),
            const Divider(color: AppTheme.divider),
            _versionRow('Developer', AppInfo.developerName),
          ],
        ),
      ),
    );
  }

  Widget _versionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium),
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogCard() {
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
          children: AppInfo.changelog.map((release) {
            final isLatest = release == AppInfo.changelog.first;
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'v${release.version}',
                        style: AppTheme.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (isLatest) ...[
                        const SizedBox(width: AppTheme.spacingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Text(
                            'Latest',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(release.date, style: AppTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  ...release.highlights.map(
                    (h) => Padding(
                      padding: const EdgeInsets.only(
                        left: AppTheme.spacingS,
                        bottom: AppTheme.spacingXS,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: AppTheme.bodyMedium),
                          Expanded(
                            child: Text(h, style: AppTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLatest) ...[
                    const SizedBox(height: AppTheme.spacingXS),
                    const Divider(color: AppTheme.divider),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
