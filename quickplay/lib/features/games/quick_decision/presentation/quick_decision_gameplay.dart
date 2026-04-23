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

/// Quick Decision — true or false rapid-fire judgments.
class QuickDecisionGameplay extends StatefulWidget {
  const QuickDecisionGameplay({super.key});
  @override
  State<QuickDecisionGameplay> createState() => _QuickDecisionGameplayState();
}

class _QuickDecisionGameplayState extends State<QuickDecisionGameplay> {
  late AudioService _audio;
  final _rng = Random();

  int _score = 0;
  int _round = 0;
  int _streak = 0;
  String _statement = '';
  bool _isTrue = true;
  bool _showCountdown = true;
  bool _isGameOver = false;
  int _flashCount = 0;
  int _timeLeftMs = 30000;
  Timer? _timer;

  static const _trueFacts = [
    '5 × 6 = 30',
    'The sun is a star',
    'Water freezes at 0°C',
    '12 ÷ 4 = 3',
    'There are 7 continents',
    '100 - 37 = 63',
    'A triangle has 3 sides',
    'Eart orbits the Sun',
    '8 × 8 = 64',
    '15 + 27 = 42',
    'A week has 7 days',
    '9 × 9 = 81',
  ];

  static const _falseFacts = [
    '5 × 7 = 30',
    'The moon is a planet',
    'Water boils at 50°C',
    '12 ÷ 3 = 5',
    'There are 5 continents',
    '100 - 37 = 73',
    'A square has 5 sides',
    'Venus is the closest to the Sun',
    '8 × 7 = 64',
    '15 + 27 = 43',
    'A year has 300 days',
    '9 × 8 = 81',
  ];

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
      _streak = 0;
      _timeLeftMs = 30000;
    });
    _audio.startBGM('brain');
    _nextStatement();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isGameOver) return;
      setState(() {
        _timeLeftMs -= 100;
        if (_timeLeftMs <= 0) _gameOver();
      });
    });
  }

  void _nextStatement() {
    _isTrue = _rng.nextBool();
    if (_isTrue) {
      _statement = _trueFacts[_rng.nextInt(_trueFacts.length)];
    } else {
      _statement = _falseFacts[_rng.nextInt(_falseFacts.length)];
    }
    setState(() => _round++);
  }

  void _answer(bool userSaysTrue) {
    if (_isGameOver || _showCountdown) return;

    if (userSaysTrue == _isTrue) {
      _audio.success();
      _streak++;
      setState(() => _score += 100 + (_streak * 20));
      _nextStatement();
    } else {
      _audio.error();
      _flashCount++;
      _streak = 0;
      _gameOver();
    }
  }

  Future<void> _gameOver() async {
    _isGameOver = true;
    _timer?.cancel();
    _audio.stopBGM();
    _audio.gameOver();

    final provider = context.read<GameProvider>();
    final isNew = await provider.submitScore('Quick Decision', _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: 'Quick Decision',
      score: _score,
      isNewHighScore: isNew,
      stats: {'Rounds': '$_round', 'Streak': '$_streak'},
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
                gameName: 'Quick Decision',
                score: _score,
                timeDisplay: '${(_timeLeftMs / 1000).toStringAsFixed(1)}s',
                streak: _streak > 1 ? _streak : null,
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Quick Decision',
                  onResume: () {},
                  onRestart: () => _startGame(),
                  onQuit: () => context.go('/home'),
                ),
              ),
              const Spacer(),
              // Statement
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    border: Border.all(color: AppColors.surfaceDark),
                  ),
                  child: Text(
                    _statement.isEmpty ? '...' : _statement,
                    style: AppTextStyles.h1.copyWith(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(),
              // True / False buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: BounceButton(
                        onTap: () => _answer(true),
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLG,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'TRUE',
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BounceButton(
                        onTap: () => _answer(false),
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLG,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'FALSE',
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
          RedFlashOverlay(triggerCount: _flashCount),
          if (_showCountdown) CountdownOverlay(onComplete: _startGame),
        ],
      ),
    );
  }
}
