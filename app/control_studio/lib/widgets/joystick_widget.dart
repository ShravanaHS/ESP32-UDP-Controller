import 'package:flutter/material.dart';

class JoystickWidget extends StatefulWidget {
  final double size;
  final Function(Offset)? onChanged;

  const JoystickWidget({
    super.key,
    this.size = 150.0,
    this.onChanged,
  });

  @override
  State<JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> {
  Offset position = Offset.zero;

  void _updatePosition(Offset newPosition) {
    setState(() {
      position = newPosition;
    });
    if (widget.onChanged != null) {
      // Normalize position to -1.0 to 1.0 range
      final normalized = Offset(
        (position.dx / (widget.size / 2)).clamp(-1.0, 1.0),
        (position.dy / (widget.size / 2)).clamp(-1.0, 1.0),
      );
      widget.onChanged!(normalized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerOffset = widget.size / 2;

    return GestureDetector(
      onPanStart: (details) {
        _updatePosition(details.localPosition - Offset(centerOffset, centerOffset));
      },
      onPanUpdate: (details) {
        final newPos = details.localPosition - Offset(centerOffset, centerOffset);
        // Constrain to circle
        if (newPos.distance <= centerOffset) {
          _updatePosition(newPos);
        } else {
          final normalized = newPos / newPos.distance;
          _updatePosition(normalized * centerOffset);
        }
      },
      onPanEnd: (details) {
        _updatePosition(Offset.zero);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[800],
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Container for thumb limits
            Container(
              width: widget.size * 0.9,
              height: widget.size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 2),
              ),
            ),
            // The thumb
            Positioned(
              left: centerOffset + position.dx - (widget.size * 0.15),
              top: centerOffset + position.dy - (widget.size * 0.15),
              child: Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
