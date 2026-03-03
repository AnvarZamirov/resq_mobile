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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'durationMinutes': durationMinutes,
      'endedAt': endedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'notifiedContactIds': notifiedContactIds,
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
    };
  }

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    CheckInStatus parseStatus(String? v) {
      return CheckInStatus.values.firstWhere(
        (e) => e.toString().split('.').last == v,
        orElse: () => CheckInStatus.completed,
      );
    }

    return CheckIn(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      message: json['message'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      endedAt:
          json['endedAt'] != null ? DateTime.parse(json['endedAt'] as String) : null,
      status: parseStatus(json['status'] as String?),
      notifiedContactIds: (json['notifiedContactIds'] as List?)
              ?.whereType<String>()
              .toList() ??
          const [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationAddress: json['locationAddress'] as String?,
    );
  }
}

enum CheckInStatus {
  active,
  completed,
  expired,
}

