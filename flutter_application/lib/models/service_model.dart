import 'package:flutter/material.dart';

class ServiceModel {
  final dynamic id; // Peut être String ou int
  final String name;
  final String description;
  final String iconName;
  final String colorName;
  final bool isConnected;
  final List<String> triggers;
  final List<String> actions;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorName,
    required this.isConnected,
    required this.triggers,
    required this.actions,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Support des deux formats : mock et API backend
    return ServiceModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // Support de 'icon' (backend) et 'icon_name' (mock)
      iconName: json['icon_name'] ?? _getIconFromUrl(json['icon']),
      // Support de 'color' (backend) et 'color_name' (mock)
      colorName: json['color_name'] ?? _getColorFromHex(json['color']),
      isConnected: json['is_connected'] ?? false,
      triggers: List<String>.from(json['triggers'] ?? []),
      actions: List<String>.from(json['actions'] ?? []),
    );
  }

  // Extraire un nom d'icône depuis une URL ou emoji
  static String _getIconFromUrl(dynamic icon) {
    if (icon == null) return 'apps';
    String iconStr = icon.toString();
    
    // Si c'est une URL, extraire le nom du service
    if (iconStr.contains('google')) return 'mail';
    if (iconStr.contains('github')) return 'code';
    if (iconStr.contains('discord')) return 'chat';
    if (iconStr.contains('slack')) return 'chat';
    if (iconStr.contains('twitch')) return 'videocam';
    if (iconStr.contains('weather')) return 'cloud';
    if (iconStr.contains('trello')) return 'dashboard';
    
    // Si c'est un emoji
    if (iconStr == '⏰') return 'timer';
    if (iconStr == '☁️') return 'cloud';
    if (iconStr == '🎮') return 'videocam';
    if (iconStr == '📋') return 'dashboard';
    
    return 'apps';
  }

  // Extraire un nom de couleur depuis un code hexadécimal
  static String _getColorFromHex(dynamic color) {
    if (color == null) return 'grey';
    String colorStr = color.toString().toLowerCase();
    
    if (colorStr.contains('4285f4') || colorStr.contains('red')) return 'red';
    if (colorStr.contains('1f2937') || colorStr.contains('dark')) return 'dark';
    if (colorStr.contains('5865f2') || colorStr.contains('blue')) return 'blue';
    if (colorStr.contains('06b6d4') || colorStr.contains('cyan')) return 'cyan';
    if (colorStr.contains('0079bf') || colorStr.contains('sky')) return 'sky';
    if (colorStr.contains('ff6b6b')) return 'light_blue';
    if (colorStr.contains('9146ff') || colorStr.contains('purple')) return 'purple';
    if (colorStr.contains('ffa500') || colorStr.contains('orange')) return 'orange';
    if (colorStr.contains('10b981') || colorStr.contains('green')) return 'green';
    
    return 'grey';
  }

  ServiceModel copyWith({
    dynamic id,
    String? name,
    String? description,
    String? iconName,
    String? colorName,
    bool? isConnected,
    List<String>? triggers,
    List<String>? actions,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorName: colorName ?? this.colorName,
      isConnected: isConnected ?? this.isConnected,
      triggers: triggers ?? this.triggers,
      actions: actions ?? this.actions,
    );
  }

  IconData get icon {
    switch (iconName) {
      case 'mail':
        return Icons.mail;
      case 'code':
        return Icons.code;
      case 'chat':
        return Icons.chat;
      case 'timer':
        return Icons.timer;
      case 'dashboard':
        return Icons.dashboard;
      case 'cloud':
        return Icons.cloud;
      case 'videocam':
        return Icons.videocam;
      default:
        return Icons.apps;
    }
  }

  Color get color {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'dark':
        return const Color(0xFF1F2937);
      case 'blue':
        return const Color(0xFF5865F2);
      case 'cyan':
        return const Color(0xFF06B6D4);
      case 'sky':
        return const Color(0xFF0079BF);
      case 'light_blue':
        return Colors.blue;
      case 'purple':
        return const Color(0xFF9146FF);
      case 'orange':
        return const Color(0xFFFFA500);
      case 'green':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }
}