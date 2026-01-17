import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service_model.dart';
import 'backend_routes.dart';
import 'auth_storage.dart';

class ServicesData {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/gmail.send',
      'https://www.googleapis.com/auth/gmail.modify',
    ],
  );

  /// Récupérer tous les services disponibles depuis l'API
  static Future<List<ServiceModel>> getAllServices() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Vous devez vous connecter pour voir les services');
    }

    final response = await http.get(
      Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.services}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    }

    if (response.statusCode != 200) {
      throw Exception('Erreur serveur (${response.statusCode})');
    }

    try {
      final dynamic decoded = json.decode(response.body);
      
      // L'API peut retourner soit directement un tableau, soit un objet avec "services"
      final List<dynamic> data = decoded is List ? decoded : decoded['services'];
      
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur de format de données: $e');
    }
  }

  /// Connecter un service
  static Future<bool> connectService(String serviceId) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    // Si c'est Google, on doit faire le flow OAuth mobile
    if (serviceId == '1' || serviceId.toLowerCase() == 'google') {
      try {
        await _googleSignIn.signOut();
        
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google Sign-In cancelled');
        }

        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final refreshToken = googleAuth.idToken;
        
        if (accessToken == null) {
          throw Exception('No access token from Google');
        }

        final url = Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.serviceConnect(serviceId)}');
        
        // Envoyer le token au backend
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'access_token': accessToken,
            'refresh_token': refreshToken,
            'expires_at': 3600,
          }),
        );

        return response.statusCode == 200 || response.statusCode == 201;
      } catch (e) {
        throw Exception('Failed to connect Google service: $e');
      }
    }

    // Pour les services OAuth web (GitHub, Discord, Slack, Twitch)
    // Ces services nécessitent une redirection vers une URL OAuth
    final oauthServices = ['3', '4', '5', '6', 'github', 'discord', 'slack', 'twitch'];
    final serviceIdLower = serviceId.toLowerCase();
    
    if (oauthServices.contains(serviceId) || oauthServices.contains(serviceIdLower)) {
      try {
        // Récupérer l'URL OAuth depuis le backend
        final url = Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.serviceConnect(serviceId)}');
        
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final oauthUrl = data['oauth_url'];
          
          if (oauthUrl != null) {
            debugPrint('OAuth URL for service $serviceId: $oauthUrl');
            
            // Ouvrir l'URL OAuth dans le navigateur
            final uri = Uri.parse(oauthUrl);
            if (await canLaunchUrl(uri)) {
              final launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              
              if (launched) {
                debugPrint('OAuth browser opened successfully');
                // Le callback sera géré par le backend et redirigera vers le frontend
                return true;
              } else {
                throw Exception('Failed to launch OAuth URL');
              }
            } else {
              throw Exception('Cannot launch OAuth URL: $oauthUrl');
            }
          }
        }
        
        return false;
      } catch (e) {
        throw Exception('Failed to initiate OAuth for service $serviceId: $e');
      }
    }

    // Pour les autres services (Timer, Weather, Trello, etc.)
    final url = Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.serviceConnect(serviceId)}');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Déconnecter un service
  static Future<bool> disconnectService(String serviceId) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    // Si c'est Google, déconnecter aussi du SDK
    if (serviceId == '1' || serviceId.toLowerCase() == 'google') {
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Ignorer les erreurs de déconnexion SDK
      }
    }

    final url = Uri.parse('${BackendRoutes.baseUrl}${BackendRoutes.serviceDisconnect(serviceId)}');
    
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    
    return response.statusCode == 200;
  }
}
