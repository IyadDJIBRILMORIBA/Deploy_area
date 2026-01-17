class ActivityModel {
  final String id;
  final String areaName;
  final String status;
  final String message;
  final DateTime timestamp;
  final bool isSuccess;

  ActivityModel({
    required this.id,
    required this.areaName,
    required this.status,
    required this.message,
    required this.timestamp,
    required this.isSuccess,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'].toString(),
      areaName: json['area_name'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'])
          : DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      isSuccess: json['is_success'] ?? false,
    );
  }
}