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

/// Balance the Ball — drag to tilt platform and keep ball from falling off.
class BalanceBallGameplay extends StatefulWidget {
  const BalanceBallGameplay({super.key});
  @override
  State<BalanceBallGameplay> createState() => _BalanceBallGameplayState();
}

class _BalanceBallGameplayState extends State<BalanceBallGameplay> {
  late AudioService _audio;
  double _ballX = 0.0; // -1 to 1
  double _ballVel = 0.0;
  double _tilt = 0.0; // controlled by drag
  int _score = 0;
  double _elapsed = 0;
  bool _showCountdown = true;
  bool _isGameOver = false;
  int _shakeCount = 0;
  int _flashCount = 0;
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
  }

  void _startGame() {
    setState(() {
      _showCountdown = false;
      _ballX = 0;
      _ballVel = 0;
      _tilt = 0;
      _score = 0;
      _elapsed = 0;
      _isGameOver = false;
    });
    _audio.startBGM('dodge');
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isGameOver) return;
      setState(() {
        _elapsed += 0.016;
        _score = (_elapsed * 10).toInt();

        // Gravity pulls ball along tilt
        final gravity = 0.0005 + (_elapsed * 0.00003);
        _ballVel += _tilt * gravity * 60;
        _ballVel *= 0.995; // friction
        _ballX += _ballVel;

        // Random wind gusts
        if (Random().nextDouble() < 0.01) {
          _ballVel += (Random().nextDouble() - 0.5) * 0.02;
        }

        if (_ballX.abs() > 1.0) {
          _gameOver();
        }
      });
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
    final isNew = await provider.submitScore('Balance the Ball', _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: 'Balance the Ball',
      score: _score,
      isNewHighScore: isNew,
      stats: {'Time': '${_elapsed.toStringAsFixed(1)}s'},
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

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              GameHud(
                gameName: 'Balance the Ball',
                score: _score,
                timeDisplay: '${_elapsed.toStringAsFixed(0)}s',
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Balance the Ball',
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
                        _tilt += d.delta.dx / w * 2;
                        _tilt = _tilt.clamp(-1.0, 1.0);
                      });
                    },
                    onPanEnd: (_) => setState(() => _tilt *= 0.5),
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      child: CustomPaint(
                        painter: _BalancePainter(ballX: _ballX, tilt: _tilt),
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

class _BalancePainter extends CustomPainter {
  final double ballX;
  final double tilt;

  _BalancePainter({required this.ballX, required this.tilt});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.65;
    final platWidth = size.width * 0.7;

    // Platform (tilted line)
    final leftY = cy + tilt * 40;
    final rightY = cy - tilt * 40;
    final platPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - platWidth / 2, leftY),
      Offset(cx + platWidth / 2, rightY),
      platPaint,
    );

    // Pivot
    canvas.drawCircle(
      Offset(cx, cy + 30),
      8,
      Paint()..color = AppColors.surfaceDark,
    );

    // Ball
    final ballCx = cx + ballX * (platWidth / 2);
    final ballCy = leftY + (rightY - leftY) * ((ballX + 1) / 2) - 20;
    canvas.drawCircle(
      Offset(ballCx, ballCy),
      16,
      Paint()..color = AppColors.error,
    );
    canvas.drawCircle(
      Offset(ballCx, ballCy),
      16,
      Paint()
        ..color = AppColors.error.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  @override
  bool shouldRepaint(covariant _BalancePainter old) =>
      old.ballX != ballX || old.tilt != tilt;
}
