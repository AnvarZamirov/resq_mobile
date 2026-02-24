import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusIndicator extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData icon;

  const StatusIndicator({
    super.key,
    required this.label,
    required this.isActive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: isActive ? AppTheme.statusSuccess : AppTheme.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isActive ? AppTheme.statusSuccess : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class StatusRow extends StatelessWidget {
  final List<StatusIndicator> statuses;

  const StatusRow({
    super.key,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: statuses,
    );
  }
}

