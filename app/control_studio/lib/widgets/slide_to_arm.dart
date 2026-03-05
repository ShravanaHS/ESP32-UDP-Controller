import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SlideToArmWidget extends StatelessWidget {
  final String label;
  final Function(bool) onChanged;
  final bool initialValue;

  const SlideToArmWidget({
    super.key,
    required this.label,
    required this.onChanged,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: initialValue ? AppTheme.leapOfFaithRed.withValues(alpha: 0.5) : Colors.white12, 
              width: 1,
            ),
            color: Colors.black26,
          ),
          child: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: initialValue,
              onChanged: onChanged,
              activeColor: AppTheme.leapOfFaithRed,
              activeTrackColor: Colors.transparent,
              inactiveThumbColor: Colors.grey[600],
              inactiveTrackColor: Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: initialValue ? AppTheme.leapOfFaithRed : AppTheme.textColorMuted,
            fontSize: 10,
            fontWeight: initialValue ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
