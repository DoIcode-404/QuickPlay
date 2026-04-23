import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/game_widgets.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/providers/game_provider.dart';
import '../../../../core/widgets/countdown_overlay.dart';

class DodgeGameplay extends StatefulWidget {
  const DodgeGameplay({super.key});

  @override
  State<DodgeGameplay> createState() => _DodgeGameplayState();
}

class _DodgeGameplayState extends State<DodgeGameplay>
    with TickerProviderStateMixin {
  static const double _playerWidth = 40;
  static const double _playerHeight = 56;
  static const double _obstacleSize = 40;

  double _playerX = 0.5;
  int _score = 0;
  int _level = 1;
  int _dodged = 0;
  double _elapsed = 0;
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _showCountdown = true;
  bool _showHint = false;
  bool _showSpawnWarning = false;
  int _shakeCount = 0;
  int _flashCount = 0;

  final List<_Obstacle> _obstacles = [];
  final _random = Random();
  Timer? _gameTimer;
  Timer? _spawnTimer;
  late AudioService _audio;

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
    _checkFirstTimeHint();
  }

  Future<void> _checkFirstTimeHint() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('dodge_hint_shown') ?? false)) {
      setState(() => _showHint = true);
      await prefs.setBool('dodge_hint_shown', true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showHint = false);
      });
    }
  }

  void _onCountdownComplete() {
    setState(() => _showCountdown = false);
    _startGame();
  }

  void _startGame() {
    _isGameOver = false;
    _obstacles.clear();
    _score = 0;
    _level = 1;
    _dodged = 0;
    _elapsed = 0;
    _playerX = 0.5;
    _audio.startBGM('dodge');

    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isPaused || _isGameOver) return;
      _updateGame();
    });
    _scheduleSpawn();
  }

  void _scheduleSpawn() {
    final interval = Duration(milliseconds: max(300, 1200 - (_level * 100)));
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(interval, (_) {
      if (_isPaused || _isGameOver) return;
      _spawnObstacle();
    });

    // Show spawn warning when things speed up
    if (_level >= 3 && interval.inMilliseconds <= 600) {
      setState(() => _showSpawnWarning = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _showSpawnWarning = false);
      });
    }
  }

  void _spawnObstacle() {
    final x = _random.nextDouble() * 0.85 + 0.05;
    final speed = 2.0 + (_level * 0.5) + _random.nextDouble() * 1.5;

    double width = _obstacleSize;
    if (_level >= 3 && _random.nextDouble() > 0.7) {
      width = _obstacleSize * 1.5;
    }

    _obstacles.add(
      _Obstacle(
        x: x,
        y: -0.1,
        speed: speed,
        width: width,
        height: _obstacleSize * 0.6,
        color:
            Color.lerp(
              AppColors.error,
              AppColors.primary,
              _random.nextDouble(),
            ) ??
            AppColors.error,
      ),
    );
  }

  void _updateGame() {
    if (!mounted) return;

    setState(() {
      _elapsed += 0.016;
      _score = (_elapsed * AppConstants.dodgeDropPointsPerSecond).toInt();

      final newLevel = (_elapsed / 10).floor() + 1;
      if (newLevel != _level) {
        _level = newLevel;
        _audio.levelUp();
        _scheduleSpawn();
      }

      for (final obs in _obstacles) {
        obs.y += obs.speed * 0.005;
      }

      _obstacles.removeWhere((obs) {
        if (obs.y > 1.15) {
          _dodged++;
          return true;
        }
        return false;
      });

      for (final obs in _obstacles) {
        if (_checkCollision(obs)) {
          _gameOver();
          return;
        }
      }
    });
  }

  bool _checkCollision(_Obstacle obs) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gameHeight = MediaQuery.of(context).size.height - 100;

    final playerLeft = _playerX * screenWidth - _playerWidth / 2;
    final playerRight = playerLeft + _playerWidth;
    final playerTop = gameHeight - _playerHeight - 30;
    final playerBottom = playerTop + _playerHeight;

    final obsLeft = obs.x * screenWidth - obs.width / 2;
    final obsRight = obsLeft + obs.width;
    final obsTop = obs.y * gameHeight;
    final obsBottom = obsTop + obs.height;

    return playerRight > obsLeft + 5 &&
        playerLeft < obsRight - 5 &&
        playerBottom > obsTop + 5 &&
        playerTop < obsBottom - 5;
  }

  Future<void> _gameOver() async {
    _isGameOver = true;
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _audio.stopBGM();
    _audio.gameOver();
    _shakeCount++;
    _flashCount++;

    final provider = context.read<GameProvider>();
    final isNew = await provider.submitScore(AppConstants.dodgeDrop, _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: AppConstants.dodgeDrop,
      score: _score,
      isNewHighScore: isNew,
      stats: {
        'Time': '${_elapsed.toStringAsFixed(1)}s',
        'Level': '$_level',
        'Dodged': '$_dodged',
      },
      onPlayAgain: _resetGame,
      onGoHome: () => context.go('/home'),
    );
  }

  void _resetGame() {
    setState(() {
      _showCountdown = true;
      _isGameOver = false;
    });
  }

  void _showPause() {
    _isPaused = true;
    showPauseSheet(
      context,
      gameName: AppConstants.dodgeDrop,
      onResume: () => _isPaused = false,
      onRestart: () {
        _isPaused = false;
        _resetGame();
      },
      onQuit: () => context.go('/home'),
    );
  }

  @override
  void dispose() {
    _audio.stopBGM();
    _audio.dispose();
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              GameHud(
                gameName: AppConstants.dodgeDrop,
                score: _score,
                timeDisplay: '${_elapsed.toStringAsFixed(0)}s • Lv.$_level',
                onPause: _showPause,
              ),
              Expanded(
                child: ShakeWidget(
                  shakeCount: _shakeCount,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (_isGameOver || _showCountdown) return;
                      setState(() {
                        _playerX += details.delta.dx / screenWidth;
                        _playerX = _playerX.clamp(0.08, 0.92);
                      });
                    },
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      child: Stack(
                        children: [
                          // Grid lines
                          ...List.generate(8, (i) {
                            return Positioned(
                              left: (i + 1) * screenWidth / 9,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 0.5,
                                color: AppColors.surfaceDark.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            );
                          }),

                          // Spawn warning glow
                          if (_showSpawnWarning)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              height: 6,
                              child:
                                  Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.error.withValues(
                                                alpha: 0.0,
                                              ),
                                              AppColors.error.withValues(
                                                alpha: 0.6,
                                              ),
                                              AppColors.error.withValues(
                                                alpha: 0.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .animate(onComplete: (c) => c.forward())
                                      .fadeIn(duration: 200.ms)
                                      .then()
                                      .fadeOut(duration: 400.ms),
                            ),

                          // Obstacles with trailing opacity
                          ..._obstacles.expand((obs) {
                            final gameArea =
                                MediaQuery.of(context).size.height - 100;
                            final left = obs.x * screenWidth - obs.width / 2;
                            final top = obs.y * gameArea;

                            return [
                              // Trail 1 (behind)
                              Positioned(
                                left: left,
                                top: top - obs.height * 0.5,
                                child: Opacity(
                                  opacity: 0.15,
                                  child: Container(
                                    width: obs.width,
                                    height: obs.height,
                                    decoration: BoxDecoration(
                                      color: obs.color,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusSM,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Trail 2 (closer)
                              Positioned(
                                left: left,
                                top: top - obs.height * 0.25,
                                child: Opacity(
                                  opacity: 0.3,
                                  child: Container(
                                    width: obs.width,
                                    height: obs.height,
                                    decoration: BoxDecoration(
                                      color: obs.color,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusSM,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Main obstacle
                              Positioned(
                                left: left,
                                top: top,
                                child: Container(
                                  width: obs.width,
                                  height: obs.height,
                                  decoration: BoxDecoration(
                                    color: obs.color,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusSM,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: obs.color.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ];
                          }),

                          // Level indicator
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 100,
                            child: Center(
                              child: Text(
                                'Level $_level • ${(_level * 1.5).toStringAsFixed(1)}x',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),

                          // Player — rounded capsule with shadow
                          Positioned(
                            left: _playerX * screenWidth - _playerWidth / 2,
                            bottom: 30,
                            child: Column(
                              children: [
                                Container(
                                  width: _playerWidth,
                                  height: _playerHeight,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.successGradient,
                                    borderRadius: BorderRadius.circular(
                                      _playerWidth / 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 20,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Player shadow on ground
                                Container(
                                  width: _playerWidth * 0.7,
                                  height: 6,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ],
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

          // Red flash overlay
          RedFlashOverlay(triggerCount: _flashCount),

          // First-time hint overlay
          if (_showHint)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child:
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusXL,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.swipe_rounded,
                                  size: 28,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Drag to move',
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .then(delay: 2000.ms)
                          .fadeOut(duration: 500.ms),
                ),
              ),
            ),

          // Countdown
          if (_showCountdown)
            CountdownOverlay(onComplete: _onCountdownComplete),
        ],
      ),
    );
  }
}

class _Obstacle {
  double x;
  double y;
  double speed;
  double width;
  double height;
  Color color;

  _Obstacle({
    required this.x,
    required this.y,
    required this.speed,
    required this.width,
    required this.height,
    required this.color,
  });
}
