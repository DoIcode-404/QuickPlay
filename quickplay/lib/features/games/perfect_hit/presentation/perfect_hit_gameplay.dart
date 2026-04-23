import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/game_widgets.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/providers/game_provider.dart';
import '../../../../core/widgets/countdown_overlay.dart';

class PerfectHitGameplay extends StatefulWidget {
  const PerfectHitGameplay({super.key});

  @override
  State<PerfectHitGameplay> createState() => _PerfectHitGameplayState();
}

class _PerfectHitGameplayState extends State<PerfectHitGameplay>
    with TickerProviderStateMixin {
  late AnimationController _indicatorController;
  late AudioService _audio;
  int _score = 0;
  int _round = 1;
  int _streak = 0;
  int _perfects = 0;
  int _goods = 0;
  int _misses = 0;
  int _shakeCount = 0;
  int _flashCount = 0;
  final int _totalRounds = 10;
  bool _isPaused = false;
  bool _showResult = false;
  bool _showCountdown = true;
  bool _speedUpShown = false;
  String _lastHitResult = '';
  Color _lastHitColor = Colors.transparent;
  double _targetZoneStart = 0.35;
  double _targetZoneWidth = 0.3;
  double _perfectZoneStart = 0.42;
  double _perfectZoneWidth = 0.16;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _audio = AudioService(context.read<GameProvider>());
  }

  void _startGame() {
    setState(() => _showCountdown = false);
    _audio.startBGM('perfect_hit');
    _setupRound();
  }

  void _setupRound() {
    final difficulty = (_round - 1) / _totalRounds;
    _targetZoneWidth = 0.3 - (difficulty * 0.12);
    _perfectZoneWidth = 0.16 - (difficulty * 0.06);
    _targetZoneStart = 0.25 + ((_round * 7) % 30) / 100.0;
    _perfectZoneStart =
        _targetZoneStart + (_targetZoneWidth - _perfectZoneWidth) / 2;

    final speed = 1200 - (_round * 60).clamp(0, 500);
    _indicatorController.duration = Duration(milliseconds: speed);

    // Show speed-up indicator when difficulty ramps
    if (_round == 4 || _round == 7) {
      setState(() => _speedUpShown = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _speedUpShown = false);
      });
      _audio.levelUp();
    }

    if (!_isPaused) {
      _indicatorController.repeat(reverse: true);
    }
  }

  void _handleTap() {
    if (_isPaused || _showResult || _showCountdown) return;

    final position = _indicatorController.value;
    String result;
    int points;
    Color color;

    if (position >= _perfectZoneStart &&
        position <= _perfectZoneStart + _perfectZoneWidth) {
      result = 'PERFECT!';
      points = AppConstants.perfectHitPerfectScore;
      color = AppColors.gold;
      _perfects++;
      _streak++;
      _audio.perfect();
    } else if (position >= _targetZoneStart &&
        position <= _targetZoneStart + _targetZoneWidth) {
      result = 'GREAT!';
      points = AppConstants.perfectHitGoodScore;
      color = AppColors.success;
      _goods++;
      _streak++;
      _audio.tap();
    } else {
      result = 'MISS';
      points = AppConstants.perfectHitMissScore;
      color = AppColors.error;
      _misses++;
      _streak = 0;
      _shakeCount++;
      _flashCount++;
      _audio.error();
    }

    // Streak bonus
    if (_streak >= 3) points = (points * 1.5).toInt();

    setState(() {
      _score += points;
      _lastHitResult = result;
      _lastHitColor = color;
      _showResult = true;
    });

    _indicatorController.stop();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_round >= _totalRounds) {
        _showGameOver();
      } else {
        setState(() {
          _round++;
          _showResult = false;
        });
        _setupRound();
      }
    });
  }

  Future<void> _showGameOver() async {
    _indicatorController.stop();
    _audio.stopBGM();
    _audio.gameOver();
    final provider = context.read<GameProvider>();
    final isNew = await provider.submitScore(AppConstants.perfectHit, _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: AppConstants.perfectHit,
      score: _score,
      isNewHighScore: isNew,
      stats: {
        'Perfect': '$_perfects',
        'Great': '$_goods',
        'Miss': '$_misses',
        'Accuracy': '${((_perfects + _goods) / _totalRounds * 100).toInt()}%',
      },
      onPlayAgain: _resetGame,
      onGoHome: () => context.go('/home'),
    );
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _round = 1;
      _streak = 0;
      _perfects = 0;
      _goods = 0;
      _misses = 0;
      _showResult = false;
      _showCountdown = true;
    });
  }

  void _showPause() {
    _indicatorController.stop();
    setState(() => _isPaused = true);

    showPauseSheet(
      context,
      gameName: AppConstants.perfectHit,
      onResume: () {
        setState(() => _isPaused = false);
        _indicatorController.repeat(reverse: true);
      },
      onRestart: () {
        setState(() => _isPaused = false);
        _resetGame();
      },
      onQuit: () => context.go('/home'),
    );
  }

  @override
  void dispose() {
    _audio.stopBGM();
    _audio.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          Column(
            children: [
              GameHud(
                gameName: AppConstants.perfectHit,
                score: _score,
                streak: _streak,
                timeDisplay: 'Round $_round/$_totalRounds',
                onPause: _showPause,
              ),
              Expanded(
                child: ShakeWidget(
                  shakeCount: _shakeCount,
                  child: GestureDetector(
                    onTap: _handleTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Speed-up indicator
                          AnimatedOpacity(
                            opacity: _speedUpShown ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    size: 14,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Speed Up!',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.gapLG),

                          // Accuracy popup with slide+fade
                          SizedBox(
                            height: 50,
                            child: _showResult
                                ? Text(
                                        _lastHitResult,
                                        style: AppTextStyles.display.copyWith(
                                          color: _lastHitColor,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(duration: 150.ms)
                                      .slideY(
                                        begin: 0.3,
                                        end: 0,
                                        duration: 300.ms,
                                        curve: Curves.easeOutBack,
                                      )
                                      .then(delay: 400.ms)
                                      .fadeOut(duration: 200.ms)
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: AppDimensions.gapXL),

                          // Hit bar with glow
                          SizedBox(
                            height: 120,
                            child: AnimatedBuilder(
                              animation: _indicatorController,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: const Size(double.infinity, 120),
                                  painter: _HitBarPainter(
                                    indicatorPosition:
                                        _indicatorController.value,
                                    targetZoneStart: _targetZoneStart,
                                    targetZoneWidth: _targetZoneWidth,
                                    perfectZoneStart: _perfectZoneStart,
                                    perfectZoneWidth: _perfectZoneWidth,
                                    showResult: _showResult,
                                    resultColor: _lastHitColor,
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: AppDimensions.gapXL),

                          // Tap prompt
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              key: ValueKey(_showResult),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingXL,
                                vertical: AppDimensions.paddingMD,
                              ),
                              decoration: BoxDecoration(
                                color: _showResult
                                    ? AppColors.surface
                                    : AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                                border: _showResult
                                    ? null
                                    : Border.all(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                              ),
                              child: Text(
                                _showResult ? 'Get ready...' : '⎯  TAP NOW  ⎯',
                                style: AppTextStyles.buttonMedium.copyWith(
                                  color: _showResult
                                      ? AppColors.textTertiary
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppDimensions.gapXXL),

                          // Mini stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _MiniStat(
                                label: 'Perfect',
                                value: '$_perfects',
                                color: AppColors.gold,
                              ),
                              const SizedBox(width: AppDimensions.gapXL),
                              _MiniStat(
                                label: 'Great',
                                value: '$_goods',
                                color: AppColors.success,
                              ),
                              const SizedBox(width: AppDimensions.gapXL),
                              _MiniStat(
                                label: 'Miss',
                                value: '$_misses',
                                color: AppColors.error,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Red flash overlay
          RedFlashOverlay(triggerCount: _flashCount),

          // Countdown
          if (_showCountdown) CountdownOverlay(onComplete: _startGame),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScoreBump(
          score: int.tryParse(value) ?? 0,
          style: AppTextStyles.h2.copyWith(color: color),
        ),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}

class _HitBarPainter extends CustomPainter {
  final double indicatorPosition;
  final double targetZoneStart;
  final double targetZoneWidth;
  final double perfectZoneStart;
  final double perfectZoneWidth;
  final bool showResult;
  final Color resultColor;

  _HitBarPainter({
    required this.indicatorPosition,
    required this.targetZoneStart,
    required this.targetZoneWidth,
    required this.perfectZoneStart,
    required this.perfectZoneWidth,
    required this.showResult,
    required this.resultColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barHeight = 18.0;
    final barY = size.height / 2 - barHeight / 2;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, barY, size.width, barHeight),
      const Radius.circular(9),
    );

    // Track
    canvas.drawRRect(barRect, Paint()..color = const Color(0xFFEDEDFF));

    // Good zone
    final goodX = targetZoneStart * size.width;
    final goodW = targetZoneWidth * size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(goodX, barY, goodW, barHeight),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.25),
    );

    // Perfect zone with glow
    final perfX = perfectZoneStart * size.width;
    final perfW = perfectZoneWidth * size.width;
    final perfRect = Rect.fromLTWH(perfX, barY - 4, perfW, barHeight + 8);

    // Outer glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(perfRect.inflate(4), const Radius.circular(13)),
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Perfect zone body
    canvas.drawRRect(
      RRect.fromRectAndRadius(perfRect, const Radius.circular(9)),
      Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.45),
    );

    // Gradient edge shimmer
    final shimmerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x00FFD700), Color(0x99FFD700), Color(0x00FFD700)],
      ).createShader(perfRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(perfX, barY - 1, perfW, barHeight + 2),
        const Radius.circular(9),
      ),
      shimmerPaint,
    );

    // Indicator line
    final indicX = indicatorPosition * size.width;
    final linePaint = Paint()
      ..color = showResult ? resultColor : const Color(0xFF3C3CF6)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Indicator shadow
    canvas.drawLine(
      Offset(indicX, barY - 22),
      Offset(indicX, barY + barHeight + 22),
      Paint()
        ..color = (showResult ? resultColor : const Color(0xFF3C3CF6))
            .withValues(alpha: 0.2)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawLine(
      Offset(indicX, barY - 22),
      Offset(indicX, barY + barHeight + 22),
      linePaint,
    );

    // Indicator circle
    canvas.drawCircle(
      Offset(indicX, barY + barHeight / 2),
      9,
      Paint()..color = showResult ? resultColor : const Color(0xFF3C3CF6),
    );
    canvas.drawCircle(
      Offset(indicX, barY + barHeight / 2),
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _HitBarPainter oldDelegate) =>
      oldDelegate.indicatorPosition != indicatorPosition ||
      oldDelegate.showResult != showResult;
}
