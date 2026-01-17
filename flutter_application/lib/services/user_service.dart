import 'dart:convert';
import 'package:http/http.dart' as http;
import '../backend_routes.dart';
import 'auth_storage.dart';

class UserService {
  /// Récupérer les informations de l'utilisateur connecté
  static Future<Map<String, dynamic>> getUserProfile() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.user}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['user'];
    } else {
      throw Exception('Failed to load user profile: ${response.body}');
    }
  }

  /// Mettre à jour le profil utilisateur
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
  }) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;

    final response = await http.put(
      Uri.parse('${BackendRoutes.baseUrl}/api/user/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Mettre à jour le cache local
      if (name != null || email != null) {
        await AuthStorage.saveUser(
          name ?? await AuthStorage.getUserName() ?? '',
          email ?? await AuthStorage.getUserEmail() ?? '',
        );
      }
      return data['user'];
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  /// Supprimer le compte utilisateur
  static Future<void> deleteAccount() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.delete(
      Uri.parse('${BackendRoutes.baseUrl}/api/user/delete'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Supprimer les données locales
      await AuthStorage.clear();
    } else {
      throw Exception('Failed to delete account: ${response.body}');
    }
  }

  /// Se déconnecter (appel API + nettoyage local)
  static Future<void> logout() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.logout}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Nettoyer les données locales
      await AuthStorage.clear();
    } else {
      throw Exception('Failed to logout: ${response.body}');
    }
  }
}
