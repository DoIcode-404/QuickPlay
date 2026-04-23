import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/game_widgets.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/countdown_overlay.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/providers/game_provider.dart';

/// Odd One Out — spot the slightly different icon among 4.
class OddOneOutGameplay extends StatefulWidget {
  const OddOneOutGameplay({super.key});
  @override
  State<OddOneOutGameplay> createState() => _OddOneOutGameplayState();
}

class _OddOneOutGameplayState extends State<OddOneOutGameplay> {
  late AudioService _audio;
  final _rng = Random();
  static const _iconSets = [
    [Icons.star_rounded, Icons.star_half_rounded],
    [Icons.favorite_rounded, Icons.favorite_border_rounded],
    [Icons.circle, Icons.circle_outlined],
    [Icons.square_rounded, Icons.crop_square_rounded],
    [Icons.bolt_rounded, Icons.flash_on_rounded],
    [Icons.wb_sunny_rounded, Icons.wb_sunny_outlined],
    [Icons.music_note_rounded, Icons.music_off_rounded],
    [Icons.visibility_rounded, Icons.visibility_off_rounded],
  ];

  int _score = 0;
  int _round = 0;
  int _lives = 3;
  int _oddIndex = 0;
  List<IconData> _currentIcons = [];
  Color _currentColor = AppColors.primary;
  bool _showCountdown = true;
  bool _isGameOver = false;
  int _shakeCount = 0;
  int _flashCount = 0;
  int _timeLeftMs = 5000;
  Timer? _timer;

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
      _round = 0;
      _lives = 3;
    });
    _audio.startBGM('brain');
    _nextRound();
  }

  void _nextRound() {
    _timer?.cancel();
    final set = _iconSets[_rng.nextInt(_iconSets.length)];
    _oddIndex = _rng.nextInt(4);
    _currentColor = Color.lerp(
      AppColors.primary,
      AppColors.success,
      _rng.nextDouble(),
    )!;

    _currentIcons = List.generate(4, (i) => i == _oddIndex ? set[1] : set[0]);
    _timeLeftMs = max(2000, 5000 - (_round * 200));

    setState(() => _round++);

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isGameOver) return;
      setState(() {
        _timeLeftMs -= 100;
        if (_timeLeftMs <= 0) {
          _lives--;
          _shakeCount++;
          _flashCount++;
          _audio.error();
          if (_lives <= 0) {
            _gameOver();
          } else {
            _nextRound();
          }
        }
      });
    });
  }

  void _tapChoice(int index) {
    if (_isGameOver || _showCountdown) return;

    if (index == _oddIndex) {
      _audio.success();
      setState(() => _score += 100 + (_round * 20));
      _nextRound();
    } else {
      _audio.error();
      _shakeCount++;
      _flashCount++;
      setState(() => _lives--);
      if (_lives <= 0) _gameOver();
    }
  }

  Future<void> _gameOver() async {
    _isGameOver = true;
    _timer?.cancel();
    _audio.stopBGM();
    _audio.gameOver();

    final provider = context.read<GameProvider>();
    final isNew = await provider.submitScore('Odd One Out', _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: 'Odd One Out',
      score: _score,
      isNewHighScore: isNew,
      stats: {'Rounds': '$_round'},
      onPlayAgain: () => _startGame(),
      onGoHome: () => context.go('/home'),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                gameName: 'Odd One Out',
                score: _score,
                timeDisplay: '${(_timeLeftMs / 1000).toStringAsFixed(1)}s',
                streak: _lives,
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Odd One Out',
                  onResume: () {},
                  onRestart: () => _startGame(),
                  onQuit: () => context.go('/home'),
                ),
              ),
              // Lives
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
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
              const Spacer(),
              Text(
                'Find the different one!',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // 2x2 grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return ShakeWidget(
                      shakeCount: _shakeCount,
                      child: BounceButton(
                        onTap: () => _tapChoice(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLG,
                            ),
                            border: Border.all(color: AppColors.surfaceDark),
                          ),
                          child: Center(
                            child: Icon(
                              _currentIcons.isNotEmpty
                                  ? _currentIcons[index]
                                  : Icons.help,
                              size: 48,
                              color: _currentColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          RedFlashOverlay(triggerCount: _flashCount),
          if (_showCountdown) CountdownOverlay(onComplete: _startGame),
        ],
      ),
    );
  }
}
