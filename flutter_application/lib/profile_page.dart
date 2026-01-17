import 'package:flutter/material.dart';
import 'services/auth_storage.dart';
import 'services/user_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String userEmail = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => loading = true);
    try {
      final userData = await UserService.getUserProfile();
      setState(() {
        userName = userData['name'] ?? 'User';
        userEmail = userData['email'] ?? 'email@example.com';
        loading = false;
      });
      // Mettre à jour le cache local
      await AuthStorage.saveUser(userName, userEmail);
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await UserService.logout();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        // En cas d'erreur API, nettoyer quand même localement
        await AuthStorage.clear();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.9 + (0.1 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                          onTap: () {
                            // TODO: Navigate to edit profile
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () {
                            // TODO: Navigate to notifications settings
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingItem(
                          icon: Icons.security_outlined,
                          title: 'Security',
                          onTap: () {
                            // TODO: Navigate to security settings
                          },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            onTap: () {
                              // TODO: Navigate to help
                            },
                          ),
                          const Divider(height: 1),
                          _buildSettingItem(
                            icon: Icons.info_outline,
                            title: 'About',
                            onTap: () {
                              // TODO: Navigate to about
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.95 + (0.05 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _buildSettingItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        iconColor: const Color(0xFFEF4444),
                        textColor: const Color(0xFFEF4444),
                        onTap: _logout,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? const Color(0xFF6B7280),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor ?? const Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
