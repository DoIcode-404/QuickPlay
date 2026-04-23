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

/// Stack Tower 2.0 — drop blocks and stack them precisely.
class StackTowerGameplay extends StatefulWidget {
  const StackTowerGameplay({super.key});
  @override
  State<StackTowerGameplay> createState() => _StackTowerGameplayState();
}

class _StackTowerGameplayState extends State<StackTowerGameplay> {
  late AudioService _audio;
  int _score = 0;
  int _level = 0;
  double _blockX = 0;
  double _blockDir = 1;
  double _blockWidth = 0.6;
  double _lastBlockX = 0.5;
  double _lastBlockWidth = 0.6;
  bool _showCountdown = true;
  bool _isGameOver = false;
  int _shakeCount = 0;
  int _flashCount = 0;
  Timer? _gameTimer;
  final List<_StackBlock> _stack = [];

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
      _level = 0;
      _blockWidth = 0.6;
      _lastBlockX = 0.5;
      _lastBlockWidth = 0.6;
      _blockX = 0;
      _blockDir = 1;
      _stack.clear();
    });
    _audio.startBGM('perfect_hit');
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isGameOver) return;
      setState(() {
        final speed = 0.008 + (_level * 0.001);
        _blockX += _blockDir * speed;
        if (_blockX > 1.0 - _blockWidth / 2) _blockDir = -1;
        if (_blockX < _blockWidth / 2) _blockDir = 1;
      });
    });
  }

  void _dropBlock() {
    if (_isGameOver || _showCountdown) return;
    _audio.tap();

    // Calculate overlap
    final currentLeft = _blockX - _blockWidth / 2;
    final currentRight = _blockX + _blockWidth / 2;
    final lastLeft = _lastBlockX - _lastBlockWidth / 2;
    final lastRight = _lastBlockX + _lastBlockWidth / 2;

    final overlapLeft = max(currentLeft, lastLeft);
    final overlapRight = min(currentRight, lastRight);
    final overlapWidth = overlapRight - overlapLeft;

    if (overlapWidth <= 0.01) {
      // Miss
      _gameOver();
      return;
    }

    // Success
    final isPerfect = (overlapWidth - _lastBlockWidth).abs() < 0.02;
    if (isPerfect) {
      _audio.perfect();
      _score += 200;
    } else {
      _audio.success();
      _score += 100;
    }

    final newCenter = overlapLeft + overlapWidth / 2;
    final hue = (30.0 + _level * 25) % 360;

    _stack.add(
      _StackBlock(
        x: newCenter,
        width: overlapWidth,
        color: HSLColor.fromAHSL(1, hue, 0.7, 0.5).toColor(),
      ),
    );

    setState(() {
      _level++;
      _lastBlockX = newCenter;
      _lastBlockWidth = overlapWidth;
      _blockWidth = overlapWidth;
      _blockX = 0;
      _blockDir = 1;
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
    final isNew = await provider.submitScore('Stack Tower 2.0', _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: 'Stack Tower 2.0',
      score: _score,
      isNewHighScore: isNew,
      stats: {'Height': '$_level'},
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
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              GameHud(
                gameName: 'Stack Tower',
                score: _score,
                timeDisplay: 'Height: $_level',
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Stack Tower 2.0',
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
                    onTap: _dropBlock,
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      child: CustomPaint(
                        painter: _TowerPainter(
                          stack: _stack,
                          currentX: _blockX,
                          currentWidth: _blockWidth,
                          level: _level,
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

class _StackBlock {
  final double x;
  final double width;
  final Color color;
  _StackBlock({required this.x, required this.width, required this.color});
}

class _TowerPainter extends CustomPainter {
  final List<_StackBlock> stack;
  final double currentX;
  final double currentWidth;
  final int level;

  _TowerPainter({
    required this.stack,
    required this.currentX,
    required this.currentWidth,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final blockH = 28.0;
    final baseY = size.height - 40;

    // Draw stacked blocks (from bottom up)
    final visibleStart = max(0, stack.length - 15);
    for (int i = visibleStart; i < stack.length; i++) {
      final b = stack[i];
      final idx = i - visibleStart;
      final y = baseY - (idx + 1) * blockH;
      final left = (b.x - b.width / 2) * size.width;
      final w = b.width * size.width;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, y, w, blockH - 2),
          const Radius.circular(4),
        ),
        Paint()..color = b.color,
      );
      // Highlight
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + 2, y + 2, w - 4, 6),
          const Radius.circular(2),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.2),
      );
    }

    // Draw current moving block
    final visibleIdx = stack.length - visibleStart;
    final curY = baseY - (visibleIdx + 1) * blockH;
    final curLeft = (currentX - currentWidth / 2) * size.width;
    final curW = currentWidth * size.width;
    final hue = (30.0 + level * 25) % 360;
    final curColor = HSLColor.fromAHSL(1, hue, 0.7, 0.5).toColor();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(curLeft, curY, curW, blockH - 2),
        const Radius.circular(4),
      ),
      Paint()..color = curColor,
    );
    // Glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(curLeft, curY, curW, blockH - 2),
        const Radius.circular(4),
      ),
      Paint()
        ..color = curColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Base platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, baseY, size.width * 0.8, 8),
        const Radius.circular(4),
      ),
      Paint()..color = AppColors.surfaceDark,
    );
  }

  @override
  bool shouldRepaint(covariant _TowerPainter old) => true;
}
