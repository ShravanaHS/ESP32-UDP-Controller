import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeonPulseButton extends StatefulWidget {
  final String label;
  final Function(bool) onPressed;

  const NeonPulseButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<NeonPulseButton> createState() => _NeonPulseButtonState();
}

class _NeonPulseButtonState extends State<NeonPulseButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    widget.onPressed(true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed(false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    widget.onPressed(false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        decoration: BoxDecoration(
          color: _isPressed ? AppTheme.multiverseCyan : Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isPressed ? [
            BoxShadow(
              color: AppTheme.multiverseCyan.withValues(alpha: 0.6),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ] : [],
          border: Border.all(
            color: _isPressed ? Colors.white : Colors.white10,
            width: 1,
          )
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(
            color: _isPressed ? AppTheme.voidInk : Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
