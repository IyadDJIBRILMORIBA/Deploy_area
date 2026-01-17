import 'package:flutter/material.dart';

class TriggerActionModel {
  final String id;
  final String name;
  final String serviceId;
  final String serviceName;
  final IconData icon;
  final String description;

  TriggerActionModel({
    required this.id,
    required this.name,
    required this.serviceId,
    required this.serviceName,
    required this.icon,
    required this.description,
  });

  factory TriggerActionModel.fromJson(Map<String, dynamic> json) {
    return TriggerActionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String,
      icon: _getIconFromString(json['icon_name'] as String? ?? 'help'),
      description: json['description'] as String? ?? '',
    );
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'mail':
      case 'email':
        return Icons.email_rounded;
      case 'schedule':
      case 'time':
      case 'timer':
        return Icons.schedule_rounded;
      case 'webhook':
        return Icons.webhook_rounded;
      case 'notification':
      case 'notify':
        return Icons.notifications_rounded;
      case 'send':
      case 'post':
        return Icons.send_rounded;
      case 'save':
      case 'database':
        return Icons.save_rounded;
      case 'code':
      case 'github':
        return Icons.code_rounded;
      case 'event':
      case 'calendar':
        return Icons.event_rounded;
      case 'message':
      case 'chat':
        return Icons.chat_bubble_rounded;
      case 'cloud':
      case 'weather':
        return Icons.cloud_rounded;
      case 'bolt':
      case 'flash':
        return Icons.bolt_rounded;
      case 'videocam':
      case 'twitch':
        return Icons.videocam_rounded;
      case 'dashboard':
      case 'trello':
        return Icons.dashboard_rounded;
      default:
        return Icons.extension_rounded;
    }
  }
}
