import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class EmergencyOverlayScreen extends StatefulWidget {
  const EmergencyOverlayScreen({super.key});

  @override
  State<EmergencyOverlayScreen> createState() => _EmergencyOverlayScreenState();
}

class _EmergencyOverlayScreenState extends State<EmergencyOverlayScreen> {
  DateTime? _activatedAt;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  final String _status = 'Отправка координат...';
  bool _isRecording = false;
  int _audioSeconds = 0;

  @override
  void initState() {
    super.initState();
    _activatedAt = DateTime.now();
    _startTimer();
    _startAudioRecording();
    HapticFeedback.heavyImpact();
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

