import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/game_widgets.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/countdown_overlay.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/providers/game_provider.dart';

/// Tile Tap Speed — tap highlighted tiles as fast as possible.
class TileTapGameplay extends StatefulWidget {
  const TileTapGameplay({super.key});
  @override
  State<TileTapGameplay> createState() => _TileTapGameplayState();
}

class _TileTapGameplayState extends State<TileTapGameplay> {
  late AudioService _audio;
  final _random = Random();
  int _score = 0;
  int _level = 1;
  int _tapped = 0;
  int _activeTile = -1;
  bool _showCountdown = true;
  bool _isGameOver = false;
  int _shakeCount = 0;
  int _flashCount = 0;
  int _lives = 3;
  Timer? _tileTimer;
  int _timeLeftMs = 30000;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
  }

  void _startGame() {
    setState(() => _showCountdown = false);
    _audio.startBGM('perfect_hit');
    _nextTile();
    _clockTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isGameOver) return;
      setState(() {
        _timeLeftMs -= 100;
        if (_timeLeftMs <= 0) _gameOver();
      });
    });
  }

  void _nextTile() {
    _tileTimer?.cancel();
    final next = _random.nextInt(9);
    setState(() => _activeTile = next);

    final timeout = max(600, 1500 - (_level * 100));
    _tileTimer = Timer(Duration(milliseconds: timeout), () {
      if (!mounted || _isGameOver) return;
      // Missed
      setState(() {
        _lives--;
        _shakeCount++;
        _flashCount++;
      });
      _audio.error();
      if (_lives <= 0) {
        _gameOver();
      } else {
        _nextTile();
      }
    });
  }

  void _tapTile(int index) {
    if (_isGameOver || _showCountdown) return;
    if (index == _activeTile) {
      _audio.success();
      setState(() {
        _score += 50 + (_level * 10);
        _tapped++;
        if (_tapped % 5 == 0) {
          _level++;
          _audio.levelUp();
        }
      });
      _nextTile();
    } else {
      _audio.error();
      setState(() {
        _lives--;
        _shakeCount++;
        _flashCount++;
      });
      if (_lives <= 0) _gameOver();
    }
  }

  Future<void> _gameOver() async {
    _isGameOver = true;
    _tileTimer?.cancel();
    _clockTimer?.cancel();
    _audio.stopBGM();
    _audio.gameOver();

    final provider = context.read<GameProvider>();
    final isNew = await provider.submitScore('Tile Tap Speed', _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: 'Tile Tap Speed',
      score: _score,
      isNewHighScore: isNew,
      stats: {'Tapped': '$_tapped', 'Level': '$_level'},
      onPlayAgain: () => setState(() {
        _showCountdown = true;
        _isGameOver = false;
        _score = 0;
        _level = 1;
        _tapped = 0;
        _lives = 3;
        _timeLeftMs = 30000;
      }),
      onGoHome: () => context.go('/home'),
    );
  }

  @override
  void dispose() {
    _tileTimer?.cancel();
    _clockTimer?.cancel();
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
                gameName: 'Tile Tap Speed',
                score: _score,
                timeDisplay: '${(_timeLeftMs / 1000).toStringAsFixed(1)}s',
                streak: _lives,
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Tile Tap Speed',
                  onResume: () {},
                  onRestart: () => setState(() {
                    _showCountdown = true;
                    _isGameOver = false;
                    _score = 0;
                    _level = 1;
                    _tapped = 0;
                    _lives = 3;
                    _timeLeftMs = 30000;
                  }),
                  onQuit: () => context.go('/home'),
                ),
              ),
              // Lives
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        i < _lives ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: i < _lives
                            ? AppColors.error
                            : AppColors.surfaceDark,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ShakeWidget(
                  shakeCount: _shakeCount,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        final isActive = index == _activeTile;
                        return BounceButton(
                          onTap: () => _tapTile(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLG,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 16,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isActive
                                ? const Icon(
                                    Icons.touch_app_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  )
                                : null,
                          ),
                        );
                      },
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
