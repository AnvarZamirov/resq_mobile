class ResQDevice {
  final String id;
  final String deviceId; // e.g., "RESQ-7B3K9"
  final bool isConnected;
  final int batteryLevel; // 0-100
  final DateTime? lastTested;
  final String? wifiNetwork;
  final int? gpsSatellites;
  final DateTime? lastLocationUpdate;

  ResQDevice({
    required this.id,
    required this.deviceId,
    this.isConnected = false,
    this.batteryLevel = 0,
    this.lastTested,
    this.wifiNetwork,
    this.gpsSatellites,
    this.lastLocationUpdate,
  });

  ResQDevice copyWith({
    String? id,
    String? deviceId,
    bool? isConnected,
    int? batteryLevel,
    DateTime? lastTested,
    String? wifiNetwork,
    int? gpsSatellites,
    DateTime? lastLocationUpdate,
  }) {
    return ResQDevice(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastTested: lastTested ?? this.lastTested,
      wifiNetwork: wifiNetwork ?? this.wifiNetwork,
      gpsSatellites: gpsSatellites ?? this.gpsSatellites,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }
}

