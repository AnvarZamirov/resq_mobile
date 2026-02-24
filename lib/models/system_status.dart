class SystemStatus {
  final bool gpsActive;
  final bool microphoneReady;
  final bool networkConnected;
  final int batteryLevel; // 0-100

  SystemStatus({
    this.gpsActive = false,
    this.microphoneReady = false,
    this.networkConnected = false,
    this.batteryLevel = 100,
  });

  SystemStatus copyWith({
    bool? gpsActive,
    bool? microphoneReady,
    bool? networkConnected,
    int? batteryLevel,
  }) {
    return SystemStatus(
      gpsActive: gpsActive ?? this.gpsActive,
      microphoneReady: microphoneReady ?? this.microphoneReady,
      networkConnected: networkConnected ?? this.networkConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
    );
  }

  bool get isReady => gpsActive && microphoneReady && networkConnected;
}

