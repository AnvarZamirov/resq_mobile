import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/device.dart';
import '../services/device_repository.dart';
import '../services/timeline_repository.dart';
import '../models/checkin.dart';

class DeviceDashboardScreen extends StatefulWidget {
  const DeviceDashboardScreen({super.key});

  @override
  State<DeviceDashboardScreen> createState() => _DeviceDashboardScreenState();
}

class _DeviceDashboardScreenState extends State<DeviceDashboardScreen> {
  final ResQDevice _device = ResQDevice(
    id: '1',
    deviceId: 'RESQ-7B3K9',
    isConnected: true,
    batteryLevel: 78,
    lastTested: DateTime.now().subtract(const Duration(hours: 2)),
    wifiNetwork: 'Home_Network',
    gpsSatellites: 5,
    lastLocationUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
  );

  final DeviceRepository _repo = DeviceRepository();
  DeviceSettings _settings = DeviceSettings(batterySaverMode: false, lastTested: null);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _repo.load();
    if (!mounted) return;
    setState(() {
      _settings = s;
      _loading = false;
    });
  }

  Future<void> _save(DeviceSettings s) async {
    setState(() => _settings = s);
    await _repo.save(s);
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Никогда';
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ч назад';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Устройство ResQ'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Device Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        size: 32,
                        color: AppTheme.statusInfo,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ResQ Device',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              '#${_device.deviceId}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _device.isConnected
                              ? AppTheme.statusSuccess.withOpacity(0.1)
                              : AppTheme.statusError.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _device.isConnected
                                    ? AppTheme.statusSuccess
                                    : AppTheme.statusError,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _device.isConnected ? 'Подключено' : 'Отключено',
                              style: TextStyle(
                                color: _device.isConnected
                                    ? AppTheme.statusSuccess
                                    : AppTheme.statusError,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Батарея',
                          '${_device.batteryLevel}%',
                          Icons.battery_charging_full,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Последний тест',
                          _formatDateTime(_settings.lastTested ?? _device.lastTested),
                          Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Controls
          Text(
            'Управление',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.notifications_active,
            label: 'Тестовый сигнал (тихий)',
            onTap: () {
              _handleTestAlert();
            },
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.settings,
            label: 'Настройки устройства',
            onTap: () {
              // TODO: Navigate to device settings
            },
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.battery_saver,
            label: 'Режим экономии батареи',
            onTap: () {
              _toggleBatterySaver();
            },
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.history,
            label: 'История использования',
            onTap: () {
              // TODO: Navigate to usage history
            },
          ),
          const SizedBox(height: 24),
          // Device Status
          Text(
            'Статус устройства',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatusRow(
                    'Wi-Fi',
                    _device.wifiNetwork ?? 'Не подключено',
                    Icons.wifi,
                    _device.wifiNetwork != null,
                  ),
                  const Divider(),
                  _buildStatusRow(
                    'GPS',
                    '${_device.gpsSatellites ?? 0} спутников',
                    Icons.satellite,
                    _device.gpsSatellites != null && _device.gpsSatellites! > 0,
                  ),
                  const Divider(),
                  _buildStatusRow(
                    'Последнее обновление локации',
                    _formatDateTime(_device.lastLocationUpdate),
                    Icons.location_on,
                    _device.lastLocationUpdate != null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.statusInfo),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    String label,
    String value,
    IconData icon,
    bool isActive,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? AppTheme.statusSuccess : AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          if (isActive)
            Icon(
              Icons.check_circle,
              color: AppTheme.statusSuccess,
              size: 20,
            ),
        ],
      ),
    );
  }

  Future<void> _handleTestAlert() async {
    final now = DateTime.now();
    await _save(_settings.copyWith(lastTested: now));

    // Запишем событие в журнал (как check-in/тест)
    await TimelineRepository().addCheckIn(
      CheckIn(
        id: now.millisecondsSinceEpoch.toString(),
        timestamp: now,
        message: 'Тест устройства (тихий)',
        durationMinutes: 1,
        status: CheckInStatus.completed,
        endedAt: now,
        notifiedContactIds: const [],
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Тестовый сигнал выполнен и записан в журнал')),
    );
  }

  Future<void> _toggleBatterySaver() async {
    await _save(_settings.copyWith(batterySaverMode: !_settings.batterySaverMode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _settings.batterySaverMode ? 'Battery Saver: Включен' : 'Battery Saver: Выключен',
        ),
      ),
    );
  }
}

