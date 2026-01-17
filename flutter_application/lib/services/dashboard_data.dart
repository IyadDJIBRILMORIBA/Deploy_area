import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_model.dart';
import 'backend_routes.dart';
import 'auth_storage.dart';

class DashboardData {
  static Future<DashboardStats> getStats() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.areas}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        http.get(
          Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.userServices}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      ]);

      int activeAreas = 0;
      int connectedServices = 0;

      if (responses[0].statusCode == 200) {
        final areasData = json.decode(responses[0].body);
        final areas = areasData['areas'] as List? ?? [];
        activeAreas = areas.where((area) => area['is_active'] == true || area['is_active'] == 1).length;
      }

      if (responses[1].statusCode == 200) {
        final servicesData = json.decode(responses[1].body);
        final services = servicesData['services'] as List? ?? [];
        connectedServices = services.length;
      }

      return DashboardStats(
        runsToday: 0,
        activeAreas: activeAreas,
        connectedServices: connectedServices,
      );
    } catch (e) {
      throw Exception('Failed to load dashboard stats: $e');
    }
  }

  /// Récupérer les workflows (AREAs) depuis l'API
  static Future<List<WorkflowModel>> getWorkflows() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await http.get(
        Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.areas}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final areas = data['areas'] as List? ?? [];
        
        return areas.take(10).map((area) {
          return WorkflowModel(
            id: area['id'].toString(),
            title: area['name'] ?? 'Unnamed AREA',
            service1: area['trigger_service'] ?? 'Unknown',
            service2: area['action_service'] ?? 'Unknown',
            icon1: _getServiceIcon(area['trigger_service']),
            icon2: _getServiceIcon(area['action_service']),
            color1: _getServiceColor(area['trigger_service']),
            color2: _getServiceColor(area['action_service']),
            isActive: area['is_active'] == true || area['is_active'] == 1,
          );
        }).toList();
      } else {
        throw Exception('Failed to load workflows: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load workflows: $e');
    }
  }

  /// Récupérer le live feed (actuellement mock car pas de route backend)
  static Future<List<LiveFeedModel>> getLiveFeed() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // TODO: Remplacer par une vraie route quand le backend l'implémente
    return [
      LiveFeedModel(
        id: '1',
        title: 'Workflow executed',
        status: 'Check your AREAs for details',
        time: 'Recently',
        isSuccess: true,
      ),
    ];
  }

  static String _getServiceIcon(String? serviceName) {
    if (serviceName == null) return 'apps';
    switch (serviceName.toLowerCase()) {
      case 'google':
        return 'mail';
      case 'github':
        return 'code';
      case 'discord':
        return 'chat';
      case 'slack':
        return 'chat';
      case 'timer':
        return 'timer';
      case 'twitch':
        return 'videocam';
      case 'weather':
        return 'cloud';
      case 'trello':
        return 'dashboard';
      default:
        return 'apps';
    }
  }

  static String _getServiceColor(String? serviceName) {
    if (serviceName == null) return 'grey';
    switch (serviceName.toLowerCase()) {
      case 'google':
        return 'red';
      case 'github':
        return 'dark';
      case 'discord':
        return 'blue';
      case 'slack':
        return 'indigo';
      case 'timer':
        return 'cyan';
      case 'twitch':
        return 'purple';
      case 'weather':
        return 'orange';
      case 'trello':
        return 'green';
      default:
        return 'grey';
    }
  }
}