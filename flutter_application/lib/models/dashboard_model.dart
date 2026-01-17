class DashboardStats {
  final int runsToday;
  final int activeAreas;
  final int connectedServices;

  DashboardStats({
    required this.runsToday,
    required this.activeAreas,
    required this.connectedServices,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      runsToday: json['runs_today'] ?? 0,
      activeAreas: json['active_areas'] ?? 0,
      connectedServices: json['connected_services'] ?? 0,
    );
  }
}

class WorkflowModel {
  final String id;
  final String title;
  final String service1;
  final String service2;
  final String icon1;
  final String icon2;
  final String color1;
  final String color2;
  final bool isActive;

  WorkflowModel({
    required this.id,
    required this.title,
    required this.service1,
    required this.service2,
    required this.icon1,
    required this.icon2,
    required this.color1,
    required this.color2,
    required this.isActive,
  });

  factory WorkflowModel.fromJson(Map<String, dynamic> json) {
    return WorkflowModel(
      id: json['id'],
      title: json['title'],
      service1: json['service1'],
      service2: json['service2'],
      icon1: json['icon1'],
      icon2: json['icon2'],
      color1: json['color1'],
      color2: json['color2'],
      isActive: json['is_active'] ?? false,
    );
  }
}

class LiveFeedModel {
  final String id;
  final String title;
  final String status;
  final String time;
  final bool isSuccess;

  LiveFeedModel({
    required this.id,
    required this.title,
    required this.status,
    required this.time,
    required this.isSuccess,
  });

  factory LiveFeedModel.fromJson(Map<String, dynamic> json) {
    return LiveFeedModel(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      time: json['time'],
      isSuccess: json['is_success'] ?? false,
    );
  }
}