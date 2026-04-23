import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/game_widgets.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/countdown_overlay.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/providers/game_provider.dart';

/// Avoid Laser — dodge sweeping laser beams.
class AvoidLaserGameplay extends StatefulWidget {
  const AvoidLaserGameplay({super.key});
  @override
  State<AvoidLaserGameplay> createState() => _AvoidLaserGameplayState();
}

class _AvoidLaserGameplayState extends State<AvoidLaserGameplay> {
  late AudioService _audio;
  double _playerX = 0.5;
  double _playerY = 0.7;
  int _score = 0;
  double _elapsed = 0;
  bool _showCountdown = true;
  bool _isGameOver = false;
  int _shakeCount = 0;
  int _flashCount = 0;
  final List<_Laser> _lasers = [];
  Timer? _gameTimer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
  }

  void _startGame() {
    setState(() {
      _showCountdown = false;
      _isGameOver = false;
      _score = 0;
      _elapsed = 0;
      _playerX = 0.5;
      _playerY = 0.7;
      _lasers.clear();
    });
    _audio.startBGM('dodge');
    _spawnLaser();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isGameOver) return;
      _update();
    });
  }

  void _spawnLaser() {
    if (_isGameOver) return;
    final isHorizontal = _random.nextBool();
    _lasers.add(
      _Laser(
        pos: _random.nextDouble(),
        isHorizontal: isHorizontal,
        speed: 0.003 + (_elapsed * 0.0002),
        dir: _random.nextBool() ? 1 : -1,
      ),
    );

    final delay = max(800, 3000 - (_elapsed * 100).toInt());
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted && !_isGameOver) _spawnLaser();
    });
  }

  void _update() {
    setState(() {
      _elapsed += 0.016;
      _score = (_elapsed * 10).toInt();

      for (final l in _lasers) {
        l.pos += l.speed * l.dir;
        if (l.pos > 1.1 || l.pos < -0.1) l.dir *= -1;
      }

      // Collision
      for (final l in _lasers) {
        if (l.isHorizontal) {
          if ((_playerY - l.pos).abs() < 0.03 &&
              _playerX > 0.05 &&
              _playerX < 0.95) {
            _gameOver();
            return;
          }
        } else {
          if ((_playerX - l.pos).abs() < 0.03 &&
              _playerY > 0.1 &&
              _playerY < 0.9) {
            _gameOver();
            return;
          }
        }
      }

      // Remove off-screen (unlikely since they bounce)
      _lasers.removeWhere((l) => l.pos > 1.5 || l.pos < -0.5);
    });
  }

  Future<void> _gameOver() async {
    _isGameOver = true;
    _gameTimer?.cancel();
    _audio.stopBGM();
    _audio.gameOver();
    _shakeCount++;
    _flashCount++;

    final provider = context.read<GameProvider>();
    final isNew = await provider.submitScore('Avoid Laser', _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: 'Avoid Laser',
      score: _score,
      isNewHighScore: isNew,
      stats: {
        'Time': '${_elapsed.toStringAsFixed(1)}s',
        'Lasers': '${_lasers.length}',
      },
      onPlayAgain: () => setState(() {
        _showCountdown = true;
        _isGameOver = false;
      }),
      onGoHome: () => context.go('/home'),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _audio.stopBGM();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height - 100;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              GameHud(
                gameName: 'Avoid Laser',
                score: _score,
                timeDisplay: '${_elapsed.toStringAsFixed(0)}s',
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Avoid Laser',
                  onResume: () {},
                  onRestart: () => setState(() {
                    _showCountdown = true;
                    _isGameOver = false;
                  }),
                  onQuit: () => context.go('/home'),
                ),
              ),
              Expanded(
                child: ShakeWidget(
                  shakeCount: _shakeCount,
                  child: GestureDetector(
                    onPanUpdate: (d) {
                      if (_isGameOver || _showCountdown) return;
                      setState(() {
                        _playerX += d.delta.dx / w;
                        _playerY += d.delta.dy / h;
                        _playerX = _playerX.clamp(0.05, 0.95);
                        _playerY = _playerY.clamp(0.1, 0.9);
                      });
                    },
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      child: CustomPaint(
                        painter: _LaserPainter(
                          playerX: _playerX,
                          playerY: _playerY,
                          lasers: _lasers,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          RedFlashOverlay(triggerCount: _flashCount),
          if (_showCountdown) CountdownOverlay(onComplete: _startGame),
        ],
      ),
    );
  }
}

class _Laser {
  double pos;
  bool isHorizontal;
  double speed;
  double dir;
  _Laser({
    required this.pos,
    required this.isHorizontal,
    required this.speed,
    required this.dir,
  });
}

class _LaserPainter extends CustomPainter {
  final double playerX, playerY;
  final List<_Laser> lasers;
  _LaserPainter({
    required this.playerX,
    required this.playerY,
    required this.lasers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Lasers
    final laserPaint = Paint()
      ..color = AppColors.error
      ..strokeWidth = 3;
    final glowPaint = Paint()
      ..color = AppColors.error.withValues(alpha: 0.2)
      ..strokeWidth = 12;

    for (final l in lasers) {
      if (l.isHorizontal) {
        final y = l.pos * size.height;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), laserPaint);
      } else {
        final x = l.pos * size.width;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), glowPaint);
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), laserPaint);
      }
    }

    // Player
    final px = playerX * size.width;
    final py = playerY * size.height;
    canvas.drawCircle(Offset(px, py), 16, Paint()..color = AppColors.primary);
    canvas.drawCircle(
      Offset(px, py),
      16,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(covariant _LaserPainter old) => true;
}
