import 'package:flutter/material.dart';
import 'models/service_model.dart';
import 'services/services_data.dart';
import 'services/deep_link_handler.dart';
import 'dart:async';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<ServiceModel> services = [];
  bool loading = true;
  StreamSubscription<Uri>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _listenToDeepLinks();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  void _listenToDeepLinks() {
    _deepLinkSubscription = DeepLinkHandler.deepLinkStream.listen((uri) {
      debugPrint('[ServicesPage] Deep link received: $uri');
      
      // Si c'est un callback OAuth
      if (uri.scheme == 'area' && uri.host == 'oauth' && uri.path == '/callback') {
        final status = uri.queryParameters['status'];
        final service = uri.queryParameters['service'];
        final error = uri.queryParameters['error'];
        
        if (status == 'connected' && service != null) {
          // Afficher un message de succès
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$service connected successfully!'),
                backgroundColor: const Color(0xFF10B981),
                duration: const Duration(seconds: 3),
              ),
            );
            
            // Recharger les services pour mettre à jour l'état de connexion
            _loadServices();
          }
        } else if (error != null) {
          // Afficher l'erreur
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OAuth error: $error'),
                backgroundColor: const Color(0xFFEF4444),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _loadServices() async {
    setState(() => loading = true);
    
    try {
      final data = await ServicesData.getAllServices();
      setState(() {
        services = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement services: $e');
      setState(() => loading = false);
    }
  }

  Future<void> _toggleService(dynamic serviceId) async {
    try {
      final serviceIdStr = serviceId.toString();
      debugPrint('[ServicesPage] Toggle service ID: $serviceIdStr');
      
      final index = services.indexWhere((s) => s.id.toString() == serviceIdStr);
      if (index == -1) {
        debugPrint('[ServicesPage] Service non trouvé dans la liste');
        return;
      }
      
      final service = services[index];
      debugPrint('[ServicesPage] Service: ${service.name}, Connected: ${service.isConnected}');
      
      final bool success;
      
      if (service.isConnected) {
        success = await ServicesData.disconnectService(serviceIdStr);
      } else {
        success = await ServicesData.connectService(serviceIdStr);
      }
      
      if (success) {
        setState(() {
          services[index] = services[index].copyWith(
            isConnected: !services[index].isConnected,
          );
        });
      }
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  void _showServiceDetails(ServiceModel service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: service.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            service.icon,
                            color: service.color,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: service.isConnected
                                      ? const Color(0xFF10B981).withOpacity(0.1)
                                      : const Color(0xFF6B7280).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  service.isConnected ? 'Connected' : 'Not Connected',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: service.isConnected
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      service.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Triggers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...service.triggers.map((trigger) => _buildFeatureItem(
                          icon: Icons.bolt,
                          title: trigger,
                          color: const Color(0xFFFBBF24),
                        )),
                    const SizedBox(height: 24),
                    Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...service.actions.map((action) => _buildFeatureItem(
                          icon: Icons.rocket_launch,
                          title: action,
                          color: const Color(0xFF4F46E5),
                        )),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _toggleService(service.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: service.isConnected
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          service.isConnected ? 'Disconnect' : 'Connect',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadServices,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Services',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect your favorite services to create powerful automations',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...services.asMap().entries.map((entry) {
                    final index = entry.key;
                    final service = entry.value;
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _buildServiceCard(service),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: service.isConnected
              ? const Color(0xFF10B981)
              : Theme.of(context).dividerColor,
          width: service.isConnected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showServiceDetails(service),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: service.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    service.icon,
                    color: service.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (service.isConnected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Connected',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}