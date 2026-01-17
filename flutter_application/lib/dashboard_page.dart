import 'package:flutter/material.dart';
import 'dart:math';
import 'services/auth_storage.dart';
import 'login_page.dart';
import 'my_areas_page.dart';
import 'services_page.dart';
import 'activity_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'create_area_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'models/dashboard_model.dart';
import 'services/dashboard_data.dart';

class DashboardPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const DashboardPage({
    super.key,
    this.userName = "Utilisateur",
    this.userEmail = "email inconnu",
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Variables pour stocker les données chargées
  DashboardStats? stats;
  List<WorkflowModel> workflows = [];
  List<LiveFeedModel> liveFeed = [];
  bool loading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => loading = true);

    try {
      // Charger toutes les données en parallèle
      final results = await Future.wait([
        DashboardData.getStats(),
        DashboardData.getWorkflows(),
        DashboardData.getLiveFeed(),
      ]);

      setState(() {
        stats = results[0] as DashboardStats;
        workflows = results[1] as List<WorkflowModel>;
        liveFeed = results[2] as List<LiveFeedModel>;
        loading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement dashboard: $e');
      setState(() => loading = false);
    }
  }

  Future<void> _logout() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (e) {
      debugPrint("Erreur déconnexion Google: $e");
    }

    await AuthStorage.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'mail':
        return Icons.mail;
      case 'psychology':
        return Icons.psychology;
      case 'code':
        return Icons.code;
      case 'chat':
        return Icons.chat;
      case 'cloud':
        return Icons.cloud;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'dark':
        return const Color(0xFF1F2937);
      case 'indigo':
        return const Color(0xFF6366F1);
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Liste des pages pour la navigation
    final List<Widget> pages = [
      _buildDashboardContent(),
      const ServicesPage(),
      const MyAreasPage(),
      const ActivityPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBarForPage(),
      body: pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Services';
      case 2:
        return 'My AREAs';
      case 3:
        return 'Activity';
      case 4:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildBottomNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'Home', 0, isDark),
            _buildNavItem(Icons.apps_rounded, 'Services', 1, isDark),
            const SizedBox(width: 40), // Espace pour le FAB
            _buildNavItem(Icons.auto_awesome_rounded, 'AREAs', 2, isDark),
            _buildNavItem(Icons.history_rounded, 'Activity', 3, isDark),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBarForPage() {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _getPageTitle(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark) {
    final isSelected = _currentIndex == index;
    final color = isSelected 
        ? Theme.of(context).colorScheme.primary 
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * (1 + sin(value * pi))),
          child: child,
        );
      },
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32.5),
            onTap: () {
              // Navigation vers la page de création d'AREA avec animation
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const CreateAreaPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;
                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header Section avec stats
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue, ${widget.userName.split(' ')[0]} 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                label: 'RUNS TODAY',
                                value: stats?.runsToday.toString() ?? '0',
                                icon: Icons.check_circle,
                                iconColor: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                label: 'ACTIVE',
                                value: stats?.activeAreas.toString() ?? '0',
                                icon: Icons.bolt,
                                iconColor: const Color(0xFFFBBF24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                label: 'SERVICES',
                                value: stats?.connectedServices.toString() ?? '0',
                                icon: Icons.apps,
                                iconColor: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNewWorkflowCard(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Workflows Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Workflows',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...workflows.map((workflow) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildWorkflowItem(workflow),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Live Feed Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Feed',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...liveFeed.map((feed) => _buildLiveFeedItem(feed)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewWorkflowCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEW WORKFLOW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a new\nautomation.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowItem(WorkflowModel workflow) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getColorFromString(workflow.color1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconFromString(workflow.icon1),
              color: _getColorFromString(workflow.color1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workflow.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(_getIconFromString(workflow.icon1),
                        size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      workflow.service1,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(_getIconFromString(workflow.icon2),
                        size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      workflow.service2,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: workflow.isActive
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFF6B7280).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: workflow.isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  workflow.isActive ? 'ACTIVE' : 'PAUSED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: workflow.isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveFeedItem(LiveFeedModel feed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: feed.isSuccess
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feed.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feed.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: feed.isSuccess
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          Text(
            feed.time,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}