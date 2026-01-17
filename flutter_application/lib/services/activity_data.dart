import '../models/activity_model.dart';

class ActivityData {
  // TODO: Remplacer par http.get('${BackendRoutes.baseUrl}/api/activity')
  static Future<List<ActivityModel>> getAllActivities() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final mockData = [
      {
        'id': '1',
        'area_name': 'Gmail → Discord',
        'status': 'Success',
        'message': 'Triggered successfully',
        'timestamp': now.subtract(const Duration(minutes: 2)).toIso8601String(),
        'is_success': true,
      },
      {
        'id': '2',
        'area_name': 'Weather → Sms',
        'status': 'Failed',
        'message': 'Failed to execute action',
        'timestamp': now.subtract(const Duration(minutes: 18)).toIso8601String(),
        'is_success': false,
      },
      {
        'id': '3',
        'area_name': 'Github → Trello',
        'status': 'Success',
        'message': 'Triggered successfully',
        'timestamp': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'is_success': true,
      },
      {
        'id': '4',
        'area_name': 'Daily Timer',
        'status': 'Success',
        'message': 'Triggered successfully',
        'timestamp': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'is_success': true,
      },
      {
        'id': '5',
        'area_name': 'Gmail → Discord',
        'status': 'Success',
        'message': 'Triggered successfully',
        'timestamp': now.subtract(const Duration(hours: 3)).toIso8601String(),
        'is_success': true,
      },
      {
        'id': '6',
        'area_name': 'Github → Trello',
        'status': 'Success',
        'message': 'New issue created',
        'timestamp': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'is_success': true,
      },
      {
        'id': '7',
        'area_name': 'Weather → Sms',
        'status': 'Failed',
        'message': 'API Error 500',
        'timestamp': now.subtract(const Duration(days: 1)).toIso8601String(),
        'is_success': false,
      },
    ];

    return mockData.map((json) => ActivityModel.fromJson(json)).toList();
  }
}