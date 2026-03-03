import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/emergency_service.dart';
import '../services/contacts_repository.dart';
import '../services/sos_dispatcher.dart';
import '../services/timeline_repository.dart';
import '../models/emergency.dart';

class EmergencyOverlayScreen extends StatefulWidget {
  final EmergencyService service;

  const EmergencyOverlayScreen({super.key, required this.service});

  @override
  State<EmergencyOverlayScreen> createState() => _EmergencyOverlayScreenState();
}

class _EmergencyOverlayScreenState extends State<EmergencyOverlayScreen> {
  DateTime? _activatedAt;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  String _status = 'Получаем координаты...';
  bool _isRecording = false;
  int _audioSeconds = 0;

  bool _loading = true;
  String? _message;
  bool _locationOk = false;
  int _sentCount = 0;
  int _attemptedCount = 0;

  @override
  void initState() {
    super.initState();
    _activatedAt = DateTime.now();
    _startTimer();
    _startAudioRecording();
    HapticFeedback.heavyImpact();
    _runEmergencyFlow();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(_activatedAt!);
      });
    });
  }

  void _startAudioRecording() {
    setState(() {
      _isRecording = true;
    });
    // Simulate audio recording
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _audioSeconds++;
        if (_audioSeconds >= 30) {
          _isRecording = false;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _runEmergencyFlow() async {
    try {
      setState(() {
        _loading = true;
        _status = 'Получаем координаты...';
      });

      final res = await widget.service.triggerSOS();
      if (!mounted) return;

      // Auto-dispatch SOS to contacts (Android: send SMS; iOS: open composer)
      final contacts = await ContactsRepository().load();
      final dispatchRes = await SosDispatcher().dispatch(
        contacts: contacts,
        message: res.message,
      );

      // Log to timeline
      final emergency = Emergency(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        activatedAt: DateTime.now(),
        resolvedAt: null,
        mode: EmergencyMode.standard,
        status: EmergencyStatus.active,
        contactsReached: dispatchRes.sent,
        totalContacts: dispatchRes.attempted,
        audioDurationSeconds: 30,
        locationAccuracy: null,
        latitude: res.lat,
        longitude: res.lng,
      );
      await TimelineRepository().addEmergency(emergency);

      setState(() {
        _message = res.message;
        _locationOk = res.locationOk;
        _sentCount = dispatchRes.sent;
        _attemptedCount = dispatchRes.attempted;
        _status = res.locationOk
            ? 'Координаты получены. Готово к отправке.'
            : 'Координаты недоступны. Готово к отправке без GPS.';
        if (dispatchRes.note != null) {
          _status = '${_status}\n${dispatchRes.note}';
        } else if (dispatchRes.attempted > 0) {
          _status = 'Отправлено: ${dispatchRes.sent}/${dispatchRes.attempted}\n$_status';
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = 'Ошибка получения данных. Можно отправить без GPS.';
        _loading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _handleSafe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text(
          'Вы в безопасности?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Это отключит экстренный режим и уведомит контакты.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusSuccess,
            ),
            child: const Text('Да, я в безопасности'),
          ),
        ],
      ),
    );
  }

  Future<void> _share() async {
    final msg = _message;
    if (msg == null || msg.trim().isEmpty) return;
    await Share.share(msg);
  }

  Future<void> _openSmsComposer() async {
    final msg = _message;
    if (msg == null || msg.trim().isEmpty) return;

    // iOS/Android: cannot send SMS silently; only opens composer.
    final uri = Uri(
      scheme: 'sms',
      path: '',
      queryParameters: <String, String>{
        'body': msg,
      },
    );
    final ok = await launchUrl(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть SMS приложение')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.emergencyTheme,
      child: Scaffold(
        backgroundColor: AppTheme.emergencyBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Timer
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      _formatDuration(_elapsed),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppTheme.emergencyRed,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'С момента активации',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              // Status
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 80,
                        color: AppTheme.emergencyRed,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SOS АКТИВИРОВАН',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          _status,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (!_loading && _attemptedCount > 0) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Отправлено: $_sentCount/$_attemptedCount',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (_loading) ...[
                        const SizedBox(height: 24),
                        const CircularProgressIndicator(),
                      ] else ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: (_locationOk ? AppTheme.statusSuccess : AppTheme.statusWarning).withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _locationOk ? 'GPS: OK' : 'GPS: нет данных',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      const SizedBox(height: 48),
                      // Audio recording indicator
                      if (_isRecording)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(10, (index) {
                                return Container(
                                  width: 4,
                                  height: 20 + (index % 3) * 10.0,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.emergencyRed,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Запись аудио: $_audioSeconds/30 сек',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _share,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emergencyRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Поделиться SOS сообщением',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _loading ? null : _openSmsComposer,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withAlpha(60)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Открыть SMS (с текстом)'),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSafe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.statusSuccess,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Я в безопасности',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Call contact #1
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Позвонить контакту'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Call police
                          },
                          icon: const Icon(Icons.local_police),
                          label: const Text('Полиция'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

