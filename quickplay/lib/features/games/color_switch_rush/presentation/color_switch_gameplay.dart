import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/game_widgets.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/countdown_overlay.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/providers/game_provider.dart';

/// Color Switch Rush — tap to cycle your ball's color to match ring segments.
class ColorSwitchGameplay extends StatefulWidget {
  const ColorSwitchGameplay({super.key});
  @override
  State<ColorSwitchGameplay> createState() => _ColorSwitchGameplayState();
}

class _ColorSwitchGameplayState extends State<ColorSwitchGameplay>
    with TickerProviderStateMixin {
  static const _colors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF845EC2),
  ];

  late AnimationController _ringController;
  late AudioService _audio;
  int _colorIndex = 0;
  int _score = 0;
  int _level = 1;
  double _ringAngle = 0;
  bool _showCountdown = true;
  bool _isGameOver = false;
  int _shakeCount = 0;
  int _flashCount = 0;
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _startGame() {
    setState(() => _showCountdown = false);
    _audio.startBGM('perfect_hit');
    _ringController.repeat();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isGameOver) return;
      setState(() {
        _ringAngle += 0.008 + (_level * 0.002);
        if (_ringAngle > 2 * pi) _ringAngle -= 2 * pi;
      });
    });
  }

  void _tapSwitch() {
    if (_isGameOver || _showCountdown) return;
    _audio.tap();
    setState(() {
      _colorIndex = (_colorIndex + 1) % _colors.length;
    });
  }

  void _tapPass() {
    if (_isGameOver || _showCountdown) return;
    // Check if current color matches the ring segment at 12 o'clock
    final segmentIndex = ((_ringAngle / (2 * pi)) * 4).floor() % 4;
    if (segmentIndex == _colorIndex) {
      _audio.success();
      setState(() {
        _score += 100 + (_level * 20);
        if (_score > _level * 500) _level++;
      });
    } else {
      _gameOver();
    }
  }

  Future<void> _gameOver() async {
    _isGameOver = true;
    _gameTimer?.cancel();
    _ringController.stop();
    _audio.stopBGM();
    _audio.gameOver();
    _shakeCount++;
    _flashCount++;

    final provider = context.read<GameProvider>();
    final isNew = await provider.submitScore('Color Switch Rush', _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: 'Color Switch Rush',
      score: _score,
      isNewHighScore: isNew,
      stats: {'Level': '$_level'},
      onPlayAgain: () => setState(() {
        _showCountdown = true;
        _isGameOver = false;
        _score = 0;
        _level = 1;
        _colorIndex = 0;
        _ringAngle = 0;
      }),
      onGoHome: () => context.go('/home'),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _ringController.dispose();
    _audio.stopBGM();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              GameHud(
                gameName: 'Color Switch Rush',
                score: _score,
                timeDisplay: 'Lv.$_level',
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Color Switch Rush',
                  onResume: () {},
                  onRestart: () => setState(() {
                    _showCountdown = true;
                    _isGameOver = false;
                    _score = 0;
                    _level = 1;
                  }),
                  onQuit: () => context.go('/home'),
                ),
              ),
              Expanded(
                child: ShakeWidget(
                  shakeCount: _shakeCount,
                  child: GestureDetector(
                    onTap: _tapPass,
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      child: Center(
                        child: SizedBox(
                          width: 260,
                          height: 260,
                          child: CustomPaint(
                            painter: _RingPainter(
                              angle: _ringAngle,
                              colors: _colors,
                            ),
                            child: Center(
                              child: GestureDetector(
                                onTap: _tapSwitch,
                                child:
                                    Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: _colors[_colorIndex],
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: _colors[_colorIndex]
                                                    .withValues(alpha: 0.5),
                                                blurRadius: 16,
                                              ),
                                            ],
                                          ),
                                        )
                                        .animate(
                                          target: 1,
                                          onComplete: (c) => c.forward(from: 0),
                                        )
                                        .scale(
                                          begin: const Offset(1.1, 1.1),
                                          end: const Offset(1.0, 1.0),
                                          duration: 150.ms,
                                        ),
                              ),
                            ),
                          ),
                        ),
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

class _RingPainter extends CustomPainter {
  final double angle;
  final List<Color> colors;

  _RingPainter({required this.angle, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 24.0;

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final startAngle = angle + (i * pi / 2);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        pi / 2 - 0.08,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.angle != angle;
}
