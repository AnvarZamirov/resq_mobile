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

