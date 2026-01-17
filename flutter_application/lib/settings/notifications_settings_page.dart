import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _areaExecutions = true;
  bool _areaErrors = true;
  bool _marketingEmails = false;
  bool _weeklyDigest = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('General', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: _pushNotifications,
                onChanged: (value) => setState(() => _pushNotifications = value),
                icon: Icons.notifications_active,
                iconColor: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildSwitchTile(
                title: 'Email Notifications',
                subtitle: 'Receive email updates',
                value: _emailNotifications,
                onChanged: (value) => setState(() => _emailNotifications = value),
                icon: Icons.email,
                iconColor: const Color(0xFF6366F1),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('AREA Activity', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildSwitchTile(
                title: 'Successful Executions',
                subtitle: 'Notify when AREAs execute successfully',
                value: _areaExecutions,
                onChanged: (value) => setState(() => _areaExecutions = value),
                icon: Icons.check_circle,
                iconColor: const Color(0xFF10B981),
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildSwitchTile(
                title: 'Errors & Failures',
                subtitle: 'Notify when AREAs fail',
                value: _areaErrors,
                onChanged: (value) => setState(() => _areaErrors = value),
                icon: Icons.error,
                iconColor: const Color(0xFFEF4444),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Email Preferences', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildSwitchTile(
                title: 'Weekly Digest',
                subtitle: 'Receive weekly activity summary',
                value: _weeklyDigest,
                onChanged: (value) => setState(() => _weeklyDigest = value),
                icon: Icons.summarize,
                iconColor: const Color(0xFF8B5CF6),
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildSwitchTile(
                title: 'Marketing Emails',
                subtitle: 'Product updates and offers',
                value: _marketingEmails,
                onChanged: (value) => setState(() => _marketingEmails = value),
                icon: Icons.campaign,
                iconColor: const Color(0xFF06B6D4),
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

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 76,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
    );
  }
}
