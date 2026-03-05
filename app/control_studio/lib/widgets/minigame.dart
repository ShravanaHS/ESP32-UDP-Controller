import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DroneDodgerGame extends StatefulWidget {
  const DroneDodgerGame({super.key});

  @override
  State<DroneDodgerGame> createState() => _DroneDodgerGameState();
}

class _DroneDodgerGameState extends State<DroneDodgerGame> with TickerProviderStateMixin {
  late AnimationController _gameLoop;
  
  // Game State
  double _playerY = 0.5; // 0.0 to 1.0 (top to bottom)
  double _playerVY = 0.0;
  final double _gravity = 0.002;
  final double _jumpForce = -0.03;
  
  final List<_Obstacle> _obstacles = [];
  int _score = 0;
  bool _isGameOver = false;
  bool _hasStarted = false;

  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(days: 99), // Infinite loop
    )..addListener(_update);
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _playerY = 0.5;
      _playerVY = 0.0;
      _obstacles.clear();
      _score = 0;
      _isGameOver = false;
      _hasStarted = true;
    });
    _gameLoop.forward(from: 0.0);
  }

  void _jump() {
    if (!_hasStarted || _isGameOver) {
      _startGame();
      return;
    }
    _playerVY = _jumpForce;
  }

  void _update() {
    if (_isGameOver) return;

    setState(() {
      // Physics
      _playerVY += _gravity;
      _playerY += _playerVY;

      // Bound checks
      if (_playerY > 1.0 || _playerY < 0.0) {
        _gameOver();
      }

      // Obstacles
      for (var obs in _obstacles) {
        obs.x -= 0.015; // Speed
      }

      // Score and remove off-screen
      if (_obstacles.isNotEmpty && _obstacles.first.x < -0.2) {
        _obstacles.removeAt(0);
        _score++;
      }

      // Spawn new
      if (_obstacles.isEmpty || _obstacles.last.x < 0.6) {
        _obstacles.add(_Obstacle(
          x: 1.2,
          gapY: _rnd.nextDouble() * 0.6 + 0.2, // 0.2 to 0.8
          gapSize: 0.3,
        ));
      }

      // Collision
      for (var obs in _obstacles) {
        if (obs.x > 0.1 && obs.x < 0.3) { // Player is around x=0.2
          if (_playerY < obs.gapY - (obs.gapSize/2) || _playerY > obs.gapY + (obs.gapSize/2)) {
            _gameOver();
          }
        }
      }
    });
  }

  void _gameOver() {
    _gameLoop.stop();
    setState(() {
      _isGameOver = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _jump,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.voidInk,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.wireframe),
          boxShadow: [
            BoxShadow(
              color: AppTheme.multiverseCyan.withValues(alpha: 0.1),
              blurRadius: 10,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
            painter: _GamePainter(
              playerY: _playerY,
              obstacles: _obstacles,
            ),
            child: Center(
              child: _hasStarted && !_isGameOver
                  ? Positioned(
                      top: 10,
                      right: 20,
                      child: Text(
                        'SCORE: $_score',
                        style: const TextStyle(
                          color: AppTheme.multiverseCyan,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isGameOver ? 'CRASHED!' : 'DRONE DODGER',
                          style: const TextStyle(
                            color: AppTheme.glitchMagenta,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isGameOver ? 'SCORE: $_score\nTAP TO RESTART' : 'TAP TO START\nTAP TO FLY',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textColorMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Obstacle {
  double x;
  final double gapY;
  final double gapSize;
  _Obstacle({required this.x, required this.gapY, required this.gapSize});
}

class _GamePainter extends CustomPainter {
  final double playerY;
  final List<_Obstacle> obstacles;

  _GamePainter({required this.playerY, required this.obstacles});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Player (Drone)
    final playerPaint = Paint()
      ..color = AppTheme.multiverseCyan
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);
    
    final playerCenter = Offset(size.width * 0.2, size.height * playerY);
    canvas.drawRect(
      Rect.fromCenter(center: playerCenter, width: 20, height: 10), 
      playerPaint
    );
    canvas.drawRect(
      Rect.fromCenter(center: playerCenter, width: 20, height: 10), 
      Paint()..color = Colors.white
    );

    // Draw Obstacles (Pillars)
    final obsPaint = Paint()
      ..color = AppTheme.wireframe
      ..style = PaintingStyle.fill;
    
    final obsBorderPaint = Paint()
      ..color = AppTheme.glitchMagenta.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var obs in obstacles) {
      double xPx = obs.x * size.width;
      double wPx = size.width * 0.1;
      
      double gapTopYPx = (obs.gapY - obs.gapSize/2) * size.height;
      double gapBotYPx = (obs.gapY + obs.gapSize/2) * size.height;

      // Top Pillar
      Rect topRect = Rect.fromLTRB(xPx, 0, xPx + wPx, gapTopYPx);
      canvas.drawRect(topRect, obsPaint);
      canvas.drawRect(topRect, obsBorderPaint);

      // Bottom Pillar
      Rect botRect = Rect.fromLTRB(xPx, gapBotYPx, xPx + wPx, size.height);
      canvas.drawRect(botRect, obsPaint);
      canvas.drawRect(botRect, obsBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
