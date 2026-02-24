class CheckIn {
  final String id;
  final DateTime timestamp;
  final String? message;
  final int? durationMinutes;
  final DateTime? endedAt;
  final CheckInStatus status;
  final List<String> notifiedContactIds;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;

  CheckIn({
    required this.id,
    required this.timestamp,
    this.message,
    this.durationMinutes,
    this.endedAt,
    required this.status,
    this.notifiedContactIds = const [],
    this.latitude,
    this.longitude,
    this.locationAddress,
  });

  bool get isActive => status == CheckInStatus.active;
  bool get isExpired => status == CheckInStatus.expired;

  CheckIn copyWith({
    String? id,
    DateTime? timestamp,
    String? message,
    int? durationMinutes,
    DateTime? endedAt,
    CheckInStatus? status,
    List<String>? notifiedContactIds,
    double? latitude,
    double? longitude,
    String? locationAddress,
  }) {
    return CheckIn(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      notifiedContactIds: notifiedContactIds ?? this.notifiedContactIds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
    );
  }
}

enum CheckInStatus {
  active,
  completed,
  expired,
}

