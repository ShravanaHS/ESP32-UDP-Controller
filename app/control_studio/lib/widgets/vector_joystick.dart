import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VectorJoystickWidget extends StatefulWidget {
  final double size;
  final Function(Offset) onChanged;

  const VectorJoystickWidget({
    super.key,
    required this.size,
    required this.onChanged,
  });

  @override
  State<VectorJoystickWidget> createState() => _VectorJoystickWidgetState();
}

class _VectorJoystickWidgetState extends State<VectorJoystickWidget> {
  Offset _currentPos = Offset.zero;

  void _updatePosition(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    Offset offsetFromCenter = localPosition - center;

    // Clamp to circle
    final maxRadius = widget.size / 2 - 25; // 25 is thumb radius
    final distance = offsetFromCenter.distance;
    
    if (distance > maxRadius) {
      offsetFromCenter = Offset.fromDirection(offsetFromCenter.direction, maxRadius);
    }

    setState(() {
      _currentPos = offsetFromCenter;
    });

    // Normalize -1 to 1
    widget.onChanged(Offset(
      offsetFromCenter.dx / maxRadius,
      -offsetFromCenter.dy / maxRadius, // Invert Y
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _updatePosition(details.localPosition),
      onPanUpdate: (details) => _updatePosition(details.localPosition),
      onPanEnd: (details) {
        setState(() {
          _currentPos = Offset.zero;
        });
        widget.onChanged(Offset.zero);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[900],
          border: Border.all(color: Colors.grey[800]!, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: widget.size / 2 + _currentPos.dx - 25,
              top: widget.size / 2 + _currentPos.dy - 25,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
