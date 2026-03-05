import 'package:flutter/material.dart';

class ControlButton extends StatefulWidget {
  final String label;
  final Function(bool)? onPressed;

  const ControlButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
        if (widget.onPressed != null) widget.onPressed!(true);
      },
      onTapUp: (_) {
        setState(() => isPressed = false);
        if (widget.onPressed != null) widget.onPressed!(false);
      },
      onTapCancel: () {
        setState(() => isPressed = false);
        if (widget.onPressed != null) widget.onPressed!(false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isPressed ? Colors.blue[700] : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPressed ? Colors.blue[400]! : Colors.grey[600]!,
            width: isPressed ? 2 : 1,
          ),
          boxShadow: isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: isPressed ? Colors.white : Colors.grey[300],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
