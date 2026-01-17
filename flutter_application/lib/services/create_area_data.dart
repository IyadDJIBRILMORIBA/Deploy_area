import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trigger_action_model.dart';
import 'backend_routes.dart';
import 'auth_storage.dart';

class CreateAreaData {
  /// Récupérer les triggers disponibles depuis l'API
  static Future<List<TriggerActionModel>> getAvailableTriggers() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await http.get(
        Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.services}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final services = data['services'] as List? ?? [];
        
        List<TriggerActionModel> allTriggers = [];
        
        // Pour chaque service, récupérer ses triggers
        for (var service in services) {
          final serviceId = service['id'].toString();
          final serviceName = service['name'] ?? '';
          
          // Récupérer les détails du service avec ses triggers
          final serviceResponse = await http.get(
            Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.serviceById(serviceId)}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );
          
          if (serviceResponse.statusCode == 200) {
            final serviceData = json.decode(serviceResponse.body);
            final serviceDetails = serviceData['service'] ?? {};
            final triggers = serviceDetails['triggers'] as List? ?? [];
            
            for (var trigger in triggers) {
              allTriggers.add(TriggerActionModel.fromJson({
                'id': trigger['id'] ?? trigger['name'],
                'name': trigger['name'] ?? '',
                'service_id': serviceName,
                'service_name': service['description'] ?? serviceName,
                'icon_name': _getIconName(serviceName),
                'description': trigger['description'] ?? '',
              }));
            }
          }
        }
        
        return allTriggers;
      } else {
        throw Exception('Failed to load triggers: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load triggers: $e');
    }
  }

  /// Récupérer les actions disponibles depuis l'API
  static Future<List<TriggerActionModel>> getAvailableActions() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await http.get(
        Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.services}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final services = data['services'] as List? ?? [];
        
        List<TriggerActionModel> allActions = [];
        
        // Pour chaque service, récupérer ses actions
        for (var service in services) {
          final serviceId = service['id'].toString();
          final serviceName = service['name'] ?? '';
          
          // Récupérer les détails du service avec ses actions
          final serviceResponse = await http.get(
            Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.serviceById(serviceId)}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );
          
          if (serviceResponse.statusCode == 200) {
            final serviceData = json.decode(serviceResponse.body);
            final serviceDetails = serviceData['service'] ?? {};
            final actions = serviceDetails['actions'] as List? ?? [];
            
            for (var action in actions) {
              allActions.add(TriggerActionModel.fromJson({
                'id': action['id'] ?? action['name'],
                'name': action['name'] ?? '',
                'service_id': serviceName,
                'service_name': service['description'] ?? serviceName,
                'icon_name': _getIconName(serviceName),
                'description': action['description'] ?? '',
              }));
            }
          }
        }
        
        return allActions;
      } else {
        throw Exception('Failed to load actions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load actions: $e');
    }
  }

  static String _getIconName(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'google':
        return 'email';
      case 'gmail':
        return 'email';
      case 'timer':
        return 'schedule';
      case 'github':
        return 'code';
      case 'discord':
        return 'chat';
      case 'slack':
        return 'chat';
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
}
