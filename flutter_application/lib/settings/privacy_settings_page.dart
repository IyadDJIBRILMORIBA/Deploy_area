import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _analyticsEnabled = true;
  bool _crashReporting = true;
  bool _personalizedAds = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Data Collection', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildSwitchTile(
                title: 'Analytics',
                subtitle: 'Help us improve the app',
                value: _analyticsEnabled,
                onChanged: (value) => setState(() => _analyticsEnabled = value),
                icon: Icons.analytics,
                iconColor: const Color(0xFF6366F1),
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildSwitchTile(
                title: 'Crash Reporting',
                subtitle: 'Send crash reports automatically',
                value: _crashReporting,
                onChanged: (value) => setState(() => _crashReporting = value),
                icon: Icons.bug_report,
                iconColor: const Color(0xFFEF4444),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Advertising', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildSwitchTile(
                title: 'Personalized Ads',
                subtitle: 'Show ads based on your interests',
                value: _personalizedAds,
                onChanged: (value) => setState(() => _personalizedAds = value),
                icon: Icons.ads_click,
                iconColor: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Data Management', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildActionTile(
                title: 'Download My Data',
                subtitle: 'Get a copy of your data',
                icon: Icons.download,
                iconColor: const Color(0xFF10B981),
                onTap: () {
                  // TODO: Download data
                },
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildActionTile(
                title: 'Clear App Data',
                subtitle: 'Remove cached data',
                icon: Icons.cleaning_services,
                iconColor: const Color(0xFF06B6D4),
                onTap: () {
                  _showClearDataDialog(context);
                },
                isDark: isDark,
              ),
            ],
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      secondary: Container(
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
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildActionTile({
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
        Icons.arrow_forward_ios,
        size: 16,
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

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Data'),
        content: const Text('This will remove all cached data. Your account will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App data cleared')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
