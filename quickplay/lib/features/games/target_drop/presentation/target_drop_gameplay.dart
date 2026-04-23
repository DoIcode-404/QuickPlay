import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/game_widgets.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/countdown_overlay.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/providers/game_provider.dart';

/// Target Drop — drop a ball onto a moving target for accuracy scoring.
class TargetDropGameplay extends StatefulWidget {
  const TargetDropGameplay({super.key});
  @override
  State<TargetDropGameplay> createState() => _TargetDropGameplayState();
}

class _TargetDropGameplayState extends State<TargetDropGameplay>
    with TickerProviderStateMixin {
  late AudioService _audio;
  int _score = 0;
  int _round = 0;
  final int _maxRounds = 10;
  double _targetX = 0.5;
  double _targetDir = 1;
  double _ballY = -1;
  bool _dropping = false;
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
      _round = 1;
      _score = 0;
      _ballY = -1;
      _dropping = false;
    });
    _audio.startBGM('perfect_hit');
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isGameOver) return;
      setState(() {
        // Move target
        final speed = 0.005 + (_round * 0.001);
        _targetX += _targetDir * speed;
        if (_targetX > 0.85) _targetDir = -1;
        if (_targetX < 0.15) _targetDir = 1;

        // Drop ball
        if (_dropping) {
          _ballY += 0.025;
          if (_ballY >= 0.85) {
            _checkHit();
          }
        }
      });
    });
  }

  void _drop() {
    if (_dropping || _isGameOver || _showCountdown) return;
    _audio.tap();
    setState(() {
      _dropping = true;
      _ballY = 0;
    });
  }

  void _checkHit() {
    final distance = (0.5 - _targetX).abs();

    int points;
    if (distance < 0.05) {
      points = 150;
      _audio.perfect();
    } else if (distance < 0.12) {
      points = 100;
      _audio.success();
    } else if (distance < 0.2) {
      points = 50;
      _audio.tap();
    } else {
      points = 0;
      _audio.error();
      _shakeCount++;
      _flashCount++;
    }

    setState(() {
      _score += points;
      _dropping = false;
      _ballY = -1;
    });

    if (_round >= _maxRounds) {
      _endGame();
    } else {
      setState(() => _round++);
    }
  }

  Future<void> _endGame() async {
    _isGameOver = true;
    _gameTimer?.cancel();
    _audio.stopBGM();
    _audio.gameOver();

    final provider = context.read<GameProvider>();
    final isNew = await provider.submitScore('Target Drop', _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: 'Target Drop',
      score: _score,
      isNewHighScore: isNew,
      stats: {'Rounds': '$_round/$_maxRounds'},
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
    final h = MediaQuery.of(context).size.height - 120;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              GameHud(
                gameName: 'Target Drop',
                score: _score,
                timeDisplay: 'Round $_round/$_maxRounds',
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Target Drop',
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
                    onTap: _drop,
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      child: Stack(
                        children: [
                          // Ball
                          if (!_dropping)
                            Positioned(
                              left: w / 2 - 18,
                              top: 40,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_dropping)
                            Positioned(
                              left: w / 2 - 18,
                              top: 40 + (_ballY * h * 0.8),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Target
                          Positioned(
                            left: _targetX * w - 30,
                            bottom: 40,
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.successGradient,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 4,
                                  height: 20,
                                  color: AppColors.success.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tap hint
                          if (!_dropping)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: h * 0.4,
                              child: Center(
                                child: Text(
                                  'Tap to drop!',
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
