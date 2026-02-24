import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback? onSOSActivated;
  final VoidCallback? onCancel;

  const SOSButton({
    super.key,
    this.onSOSActivated,
    this.onCancel,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  double _progress = 0.0;
  Timer? _progressTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startProgress() {
    _progressTimer?.cancel();
    _progress = 0.0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _progress += 0.01; // 3 seconds = 100 steps of 30ms
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _activateSOS();
        }
      });
    });
  }

  void _stopProgress() {
    _progressTimer?.cancel();
    setState(() {
      _progress = 0.0;
      _isPressed = false;
    });
  }

  void _activateSOS() {
    HapticFeedback.heavyImpact();
    _progressTimer?.cancel();
    widget.onSOSActivated?.call();
  }

  void _onPanStart(DragStartDetails details) {
    HapticFeedback.lightImpact();
    setState(() {
      _isPressed = true;
    });
    _startProgress();
  }

  void _onPanEnd(DragEndDetails details) {
    if (_progress < 1.0) {
      HapticFeedback.mediumImpact();
      _stopProgress();
      widget.onCancel?.call();
    }
  }

  void _onPanCancel() {
    _stopProgress();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : _pulseAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.emergencyRed,
                    ),
                  ),
                ),
                // SOS Button
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isPressed
                        ? AppTheme.emergencyRedDark
                        : AppTheme.emergencyRed,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.emergencyRed.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

