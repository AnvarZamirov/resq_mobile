class Emergency {
  final String id;
  final DateTime activatedAt;
  final DateTime? resolvedAt;
  final EmergencyMode mode;
  final EmergencyStatus status;
  final Duration? responseTime;
  final int contactsReached;
  final int totalContacts;
  final int? audioDurationSeconds;
  final double? locationAccuracy;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;

  Emergency({
    required this.id,
    required this.activatedAt,
    this.resolvedAt,
    required this.mode,
    required this.status,
    this.responseTime,
    this.contactsReached = 0,
    this.totalContacts = 0,
    this.audioDurationSeconds,
    this.locationAccuracy,
    this.locationAddress,
    this.latitude,
    this.longitude,
  });

  bool get isResolved => status == EmergencyStatus.resolved;
  bool get isActive => status == EmergencyStatus.active;

  Emergency copyWith({
    String? id,
    DateTime? activatedAt,
    DateTime? resolvedAt,
    EmergencyMode? mode,
    EmergencyStatus? status,
    Duration? responseTime,
    int? contactsReached,
    int? totalContacts,
    int? audioDurationSeconds,
    double? locationAccuracy,
    String? locationAddress,
    double? latitude,
    double? longitude,
  }) {
    return Emergency(
      id: id ?? this.id,
      activatedAt: activatedAt ?? this.activatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      responseTime: responseTime ?? this.responseTime,
      contactsReached: contactsReached ?? this.contactsReached,
      totalContacts: totalContacts ?? this.totalContacts,
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activatedAt': activatedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'mode': mode.toString().split('.').last,
      'status': status.toString().split('.').last,
      'responseTimeSeconds': responseTime?.inSeconds,
      'contactsReached': contactsReached,
      'totalContacts': totalContacts,
      'audioDurationSeconds': audioDurationSeconds,
      'locationAccuracy': locationAccuracy,
      'locationAddress': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Emergency.fromJson(Map<String, dynamic> json) {
    EmergencyMode parseMode(String? v) {
      return EmergencyMode.values.firstWhere(
        (e) => e.toString().split('.').last == v,
        orElse: () => EmergencyMode.standard,
      );
    }

    EmergencyStatus parseStatus(String? v) {
      return EmergencyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == v,
        orElse: () => EmergencyStatus.active,
      );
    }

    return Emergency(
      id: json['id'] as String,
      activatedAt: DateTime.parse(json['activatedAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      mode: parseMode(json['mode'] as String?),
      status: parseStatus(json['status'] as String?),
      responseTime: json['responseTimeSeconds'] != null
          ? Duration(seconds: (json['responseTimeSeconds'] as num).toInt())
          : null,
      contactsReached: (json['contactsReached'] as num?)?.toInt() ?? 0,
      totalContacts: (json['totalContacts'] as num?)?.toInt() ?? 0,
      audioDurationSeconds: (json['audioDurationSeconds'] as num?)?.toInt(),
      locationAccuracy: (json['locationAccuracy'] as num?)?.toDouble(),
      locationAddress: json['locationAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

enum EmergencyMode {
  standard,
  followMe, // User is moving
  silentAlert, // Loud noises detected
  homeEmergency, // Geo-fencing triggered
}

enum EmergencyStatus {
  active,
  resolved,
  cancelled,
}

