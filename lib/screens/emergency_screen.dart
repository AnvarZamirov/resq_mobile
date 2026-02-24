import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sos_button.dart';
import '../widgets/status_indicator.dart';
import '../widgets/quick_action_chip.dart';
import '../models/system_status.dart';
import 'emergency_overlay_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final SystemStatus _systemStatus = SystemStatus(
    gpsActive: true,
    microphoneReady: true,
    networkConnected: true,
    batteryLevel: 87,
  );

  bool _isEmergencyActive = false;

  void _handleSOSActivated() {
    setState(() {
      _isEmergencyActive = true;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EmergencyOverlayScreen(),
        fullscreenDialog: true,
      ),
    ).then((_) {
      setState(() {
        _isEmergencyActive = false;
      });
    });
  }

  void _handleShareLocation() {
    // TODO: Implement share location
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Поделиться геопозицией на 15 минут')),
    );
  }

  void _handleQuickCheckIn() {
    // TODO: Implement quick check-in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Быстрый чек-ин')),
    );
  }

  void _handleSafeRide() {
    // TODO: Implement safe ride request
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Запрос безопасной поездки')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Status indicators
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StatusRow(
                statuses: [
                  StatusIndicator(
                    label: 'GPS: ${_systemStatus.gpsActive ? "Активен" : "Неактивен"}',
                    isActive: _systemStatus.gpsActive,
                    icon: Icons.location_on,
                  ),
                  StatusIndicator(
                    label: 'Микрофон: ${_systemStatus.microphoneReady ? "Готов" : "Не готов"}',
                    isActive: _systemStatus.microphoneReady,
                    icon: Icons.mic,
                  ),
                  StatusIndicator(
                    label: 'Сеть: ${_systemStatus.networkConnected ? "Подключена" : "Отключена"}',
                    isActive: _systemStatus.networkConnected,
                    icon: Icons.wifi,
                  ),
                  StatusIndicator(
                    label: 'Батарея: ${_systemStatus.batteryLevel}%',
                    isActive: _systemStatus.batteryLevel > 20,
                    icon: Icons.battery_charging_full,
                  ),
                ],
              ),
            ),
            // SOS Button
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SOSButton(
                      onSOSActivated: _handleSOSActivated,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isEmergencyActive
                          ? 'SOS активирован'
                          : 'Нажмите и удерживайте 3 секунды',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  QuickActionChip(
                    label: 'Поделиться геопозицией (15 мин)',
                    icon: Icons.location_on,
                    onTap: _handleShareLocation,
                  ),
                  QuickActionChip(
                    label: 'Быстрый чек-ин',
                    icon: Icons.check_circle_outline,
                    onTap: _handleQuickCheckIn,
                  ),
                  QuickActionChip(
                    label: 'Безопасная поездка',
                    icon: Icons.directions_car,
                    onTap: _handleSafeRide,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

