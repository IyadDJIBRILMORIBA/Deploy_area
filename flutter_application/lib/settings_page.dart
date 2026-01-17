import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'settings/account_settings_page.dart';
import 'settings/notifications_settings_page.dart';
import 'settings/privacy_settings_page.dart';
import 'settings/appearance_settings_page.dart';
import 'settings/about_page.dart';
import 'services/auth_storage.dart';
import 'services/user_service.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserProfile();
      setState(() {
        userName = userData['name'] ?? 'User';
        userEmail = userData['email'] ?? 'email@example.com';
        loading = false;
      });
    } catch (e) {
      // Fallback au cache local si l'API échoue
      final name = await AuthStorage.getUserName();
      final email = await AuthStorage.getUserEmail();
      setState(() {
        userName = name ?? 'User';
        userEmail = email ?? 'email@example.com';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          _buildProfileCard(context, isDark),
          const SizedBox(height: 24),

          // General Section
          _buildSectionTitle('General', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildSettingsTile(
                context,
                icon: Icons.account_circle,
                iconColor: const Color(0xFF6366F1),
                title: 'Account',
                subtitle: 'Manage your account details',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
                  );
                  // Recharger les données après retour de la page de settings
                  _loadUserData();
                },
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                context,
                icon: Icons.notifications,
                iconColor: const Color(0xFFF59E0B),
                title: 'Notifications',
                subtitle: 'Configure notification preferences',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsSettingsPage()),
                ),
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                context,
                icon: Icons.palette,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Appearance',
                subtitle: 'Theme and display options',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppearanceSettingsPage()),
                ),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Privacy & Security Section
          _buildSectionTitle('Privacy & Security', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildSettingsTile(
                context,
                icon: Icons.lock,
                iconColor: const Color(0xFFEF4444),
                title: 'Privacy',
                subtitle: 'Manage your privacy settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacySettingsPage()),
                ),
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                context,
                icon: Icons.security,
                iconColor: const Color(0xFF10B981),
                title: 'Security',
                subtitle: 'Password and authentication',
                onTap: () {
                  // TODO: Navigate to security page
                },
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Support Section
          _buildSectionTitle('Support', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildSettingsTile(
                context,
                icon: Icons.help,
                iconColor: const Color(0xFF06B6D4),
                title: 'Help & Support',
                subtitle: 'Get help with the app',
                onTap: () {
                  // TODO: Navigate to help page
                },
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                context,
                icon: Icons.info,
                iconColor: const Color(0xFF64748B),
                title: 'About',
                subtitle: 'App version and information',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionTitle('Danger Zone', isDark),
          _buildSettingsCard(
            context,
            isDark,
            [
              _buildSettingsTile(
                context,
                icon: Icons.logout,
                iconColor: const Color(0xFFEF4444),
                title: 'Sign Out',
                subtitle: 'Sign out from your account',
                onTap: () => _showLogoutDialog(context),
                isDark: isDark,
                showArrow: false,
              ),
              _buildDivider(isDark),
              _buildSettingsTile(
                context,
                icon: Icons.delete_forever,
                iconColor: const Color(0xFFDC2626),
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: () => _showDeleteAccountDialog(context),
                isDark: isDark,
                showArrow: false,
                isDestructive: true,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.surface, width: 3),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loading ? 'Loading...' : userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loading ? 'Loading...' : userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
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
          letterSpacing: 0.5,
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

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool showArrow = true,
    bool isDestructive = false,
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
          color: isDestructive
              ? const Color(0xFFEF4444)
              : isDark
                  ? Colors.white
                  : const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
      trailing: showArrow
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            )
          : null,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 76,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Sauvegarder le navigator avant de fermer le dialogue
              final navigator = Navigator.of(context);
              
              // Fermer le dialogue d'abord
              Navigator.pop(dialogContext);
              
              // Montrer un loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Appeler l'API backend pour se déconnecter
                await UserService.logout();
              } catch (e) {
                // En cas d'erreur API, nettoyer quand même localement
                await AuthStorage.clear();
              }
              
              // Fermer le loading
              navigator.pop();
              
              // Rediriger vers login
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Sauvegarder le navigator avant de fermer le dialogue
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              
              // Fermer le dialogue de confirmation
              Navigator.pop(dialogContext);
              
              // Montrer un loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Appeler l'API backend pour supprimer le compte
                await UserService.deleteAccount();
                
                // Fermer le loading
                navigator.pop();
                
                // Afficher le message de succès
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (successContext) => AlertDialog(
                    title: const Text('Account Deleted'),
                    content: const Text(
                      'Your account has been permanently deleted.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(successContext);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                
                // Rediriger vers login
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              } catch (e) {
                // Fermer le loading
                navigator.pop();
                
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete account: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
