import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/area_model.dart';
import 'backend_routes.dart';
import 'auth_storage.dart';

class AreasData {
  /// Récupérer toutes les AREAs de l'utilisateur depuis l'API
  static Future<List<AreaModel>> getAllAreas() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.areas}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> areasJson = data['areas'] ?? data;
      return areasJson.map((json) => AreaModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load areas: ${response.body}');
    }
  }

  /// Activer/Désactiver une AREA
  static Future<bool> toggleArea(String areaId) async {
    debugPrint('[AreasData] toggleArea START - areaId: $areaId');
    
    final token = await AuthStorage.getToken();
    if (token == null) {
      debugPrint('[AreasData] toggleArea ERROR - No token');
      throw Exception('No authentication token found');
    }
    
    debugPrint('[AreasData] toggleArea - Token trouvé');
    final url = '${BackendRoutes.baseUrl}${BackendRoutes.areaToggle(areaId)}';
    debugPrint('[AreasData] toggleArea - URL: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    
    debugPrint('[AreasData] toggleArea - Status: ${response.statusCode}');
    debugPrint('[AreasData] toggleArea - Body: ${response.body}');

    return response.statusCode == 200;
  }

  /// Supprimer une AREA
  static Future<bool> deleteArea(String areaId) async {
    debugPrint('[AreasData] deleteArea START - areaId: $areaId');
    
    final token = await AuthStorage.getToken();
    if (token == null) {
      debugPrint('[AreasData] deleteArea ERROR - No token');
      throw Exception('No authentication token found');
    }
    
    debugPrint('[AreasData] deleteArea - Token trouvé');
    final url = '${BackendRoutes.baseUrl}${BackendRoutes.areaById(areaId)}';
    debugPrint('[AreasData] deleteArea - URL: $url');

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    
    debugPrint('[AreasData] deleteArea - Status: ${response.statusCode}');
    debugPrint('[AreasData] deleteArea - Body: ${response.body}');

    return response.statusCode == 200;
  }

  /// Créer une nouvelle AREA
  static Future<AreaModel> createArea({
    required String name,
    required String triggerService,
    required String triggerAction,
    Map<String, dynamic>? triggerParams,
    required String actionService,
    required String actionReaction,
    Map<String, dynamic>? actionParams,
  }) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final body = {
      'name': name,
      'trigger_service': triggerService,
      'trigger_action': triggerAction,
      if (triggerParams != null) 'trigger_params': triggerParams,
      'action_service': actionService,
      'action_reaction': actionReaction,
      if (actionParams != null) 'action_params': actionParams,
    };

    debugPrint('📤 POST ${BackendRoutes.baseUrl}${BackendRoutes.areas}');
    debugPrint('📦 Body: ${json.encode(body)}');

    final response = await http.post(
      Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.areas}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    debugPrint('📥 Response status: ${response.statusCode}');
    debugPrint('📥 Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return AreaModel.fromJson(data['area'] ?? data);
    } else {
      throw Exception('Failed to create area: ${response.body}');
    }
  }

  /// Mettre à jour une AREA
  static Future<AreaModel> updateArea({
    required String areaId,
    String? name,
    bool? isActive,
    Map<String, dynamic>? triggerParams,
    Map<String, dynamic>? actionParams,
  }) async {
    debugPrint('[AreasData] updateArea START - areaId: $areaId');
    
    final token = await AuthStorage.getToken();
    if (token == null) {
      debugPrint('[AreasData] updateArea ERROR - No token');
      throw Exception('No authentication token found');
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (isActive != null) body['is_active'] = isActive;
    if (triggerParams != null) body['trigger_params'] = triggerParams;
    if (actionParams != null) body['action_params'] = actionParams;

    debugPrint('[AreasData] updateArea - Body: ${json.encode(body)}');

    final response = await http.put(
      Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.areaById(areaId)}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    debugPrint('[AreasData] updateArea - Status: ${response.statusCode}');
    debugPrint('[AreasData] updateArea - Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AreaModel.fromJson(data['area'] ?? data);
    } else {
      throw Exception('Failed to update area: ${response.body}');
    }
  }

  /// Récupérer une AREA spécifique
  static Future<AreaModel> getAreaById(String areaId) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.areaById(areaId)}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AreaModel.fromJson(data['area'] ?? data);
    } else {
      throw Exception('Failed to load area: ${response.body}');
    }
  }
}