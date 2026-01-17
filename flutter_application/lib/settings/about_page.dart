import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Icon & Version
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.radar,
                    size: 50,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AREA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Version 1.0.0+1',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(
              'AREA is an automation platform that connects your favorite services and creates powerful workflows.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Links
          _buildSectionTitle('Links', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildLinkTile(
                title: 'Website',
                subtitle: 'Visit our website',
                icon: Icons.language,
                iconColor: const Color(0xFF6366F1),
                onTap: () => _launchUrl('https://area.example.com'),
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildLinkTile(
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                icon: Icons.privacy_tip,
                iconColor: const Color(0xFF10B981),
                onTap: () => _launchUrl('https://area.example.com/privacy'),
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildLinkTile(
                title: 'Terms of Service',
                subtitle: 'Read our terms',
                icon: Icons.description,
                iconColor: const Color(0xFFF59E0B),
                onTap: () => _launchUrl('https://area.example.com/terms'),
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildLinkTile(
                title: 'Open Source Licenses',
                subtitle: 'View third-party licenses',
                icon: Icons.code,
                iconColor: const Color(0xFF8B5CF6),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'AREA',
                    applicationVersion: '1.0.0+1',
                    applicationIcon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.radar,
                        size: 30,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  );
                },
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Developer Info
          _buildSectionTitle('Developer', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildLinkTile(
                title: 'GitHub',
                subtitle: 'View source code',
                icon: Icons.code_rounded,
                iconColor: isDark ? Colors.white : const Color(0xFF1F2937),
                onTap: () => _launchUrl('https://github.com/EpitechPGE3-2025'),
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildLinkTile(
                title: 'Report a Bug',
                subtitle: 'Help us improve',
                icon: Icons.bug_report,
                iconColor: const Color(0xFFEF4444),
                onTap: () => _launchUrl('https://github.com/EpitechPGE3-2025/issues'),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Copyright
          Center(
            child: Text(
              '© 2025 AREA. All rights reserved.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Made with ❤️ by Epitech',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLinkTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.open_in_new,
        size: 18,
        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 76,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
