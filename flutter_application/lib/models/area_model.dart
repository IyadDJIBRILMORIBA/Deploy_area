class AreaModel {
  final dynamic id; // Peut être String ou int
  final String name;
  final String triggerService;
  final String triggerName;
  final Map<String, dynamic> triggerParams;
  final String actionService;
  final String actionName;
  final Map<String, dynamic> actionParams;
  final bool isActive;
  final String createdAt;

  AreaModel({
    required this.id,
    required this.name,
    required this.triggerService,
    required this.triggerName,
    this.triggerParams = const {},
    required this.actionService,
    required this.actionName,
    this.actionParams = const {},
    required this.isActive,
    required this.createdAt,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'],
      name: json['name'] ?? '',
      triggerService: json['trigger_service'] ?? '',
      // Support des deux formats : 'trigger_name' (mock) et 'trigger_action' (backend)
      triggerName: json['trigger_name'] ?? json['trigger_action'] ?? '',
      triggerParams: json['trigger_params'] is Map 
          ? Map<String, dynamic>.from(json['trigger_params'])
          : {},
      actionService: json['action_service'] ?? '',
      // Support des deux formats : 'action_name' (mock) et 'action_reaction' (backend)
      actionName: json['action_name'] ?? json['action_reaction'] ?? '',
      actionParams: json['action_params'] is Map
          ? Map<String, dynamic>.from(json['action_params'])
          : {},
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trigger_service': triggerService,
      'trigger_action': triggerName,
      'trigger_params': triggerParams,
      'action_service': actionService,
      'action_reaction': actionName,
      'action_params': actionParams,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  AreaModel copyWith({
    dynamic id,
    String? name,
    String? triggerService,
    String? triggerName,
    Map<String, dynamic>? triggerParams,
    String? actionService,
    String? actionName,
    Map<String, dynamic>? actionParams,
    bool? isActive,
    String? createdAt,
  }) {
    return AreaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      triggerService: triggerService ?? this.triggerService,
      triggerName: triggerName ?? this.triggerName,
      triggerParams: triggerParams ?? this.triggerParams,
      actionService: actionService ?? this.actionService,
      actionName: actionName ?? this.actionName,
      actionParams: actionParams ?? this.actionParams,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}