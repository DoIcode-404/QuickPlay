import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/game_widgets.dart';
import '../../../../core/widgets/timer_bar.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/providers/game_provider.dart';
import '../../../../core/widgets/countdown_overlay.dart';

class BrainGameplay extends StatefulWidget {
  const BrainGameplay({super.key});

  @override
  State<BrainGameplay> createState() => _BrainGameplayState();
}

class _BrainGameplayState extends State<BrainGameplay> {
  final _random = Random();
  late AudioService _audio;
  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _lives = 3;
  int _questionsAnswered = 0;
  int _correctAnswers = 0;
  double _timeRemaining = 1.0;
  Timer? _timer;
  bool _isPaused = false;
  bool _showCountdown = true;
  int _shakeCount = 0;
  int _flashCount = 0;

  int _num1 = 0;
  int _num2 = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  List<int> _options = [];
  bool? _lastAnswerCorrect;
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
    _generateQuestion();
  }

  void _startGame() {
    setState(() => _showCountdown = false);
    _audio.startBGM('brain');
    _startTimer();
  }

  void _generateQuestion() {
    int maxNum = 20 + (_questionsAnswered * 3).clamp(0, 80);
    _num1 = _random.nextInt(maxNum) + 1;
    _num2 = _random.nextInt(maxNum ~/ 2) + 1;

    final ops = ['+', '-', '×'];
    _operator =
        ops[_random.nextInt(
          _questionsAnswered < 5 ? 1 : (_questionsAnswered < 10 ? 2 : 3),
        )];

    switch (_operator) {
      case '+':
        _correctAnswer = _num1 + _num2;
        break;
      case '-':
        if (_num1 < _num2) {
          final temp = _num1;
          _num1 = _num2;
          _num2 = temp;
        }
        _correctAnswer = _num1 - _num2;
        break;
      case '×':
        _num1 = _random.nextInt(12) + 2;
        _num2 = _random.nextInt(12) + 2;
        _correctAnswer = _num1 * _num2;
        break;
    }

    final optionSet = <int>{_correctAnswer};
    while (optionSet.length < 4) {
      int offset = _random.nextInt(20) - 10;
      if (offset == 0) offset = 1;
      optionSet.add(_correctAnswer + offset);
    }
    _options = optionSet.toList()..shuffle();
    _selectedOption = null;
    _lastAnswerCorrect = null;
  }

  void _startTimer() {
    _timeRemaining = 1.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isPaused) return;
      setState(() {
        _timeRemaining -= 0.01;
        if (_timeRemaining <= 0) {
          _timeRemaining = 0;
          _handleTimeout();
        }
      });
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    _audio.error();

    setState(() {
      _lives--;
      _streak = 0;
      _lastAnswerCorrect = false;
      _questionsAnswered++;
      _shakeCount++;
      _flashCount++;
    });

    if (_lives <= 0) {
      Future.delayed(const Duration(milliseconds: 500), _showGameOver);
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _generateQuestion());
          _startTimer();
        }
      });
    }
  }

  void _selectAnswer(int answer) {
    if (_selectedOption != null) return;
    _timer?.cancel();

    final correct = answer == _correctAnswer;

    setState(() {
      _selectedOption = answer;
      _lastAnswerCorrect = correct;
      _questionsAnswered++;

      if (correct) {
        _correctAnswers++;
        _streak++;
        if (_streak > _maxStreak) _maxStreak = _streak;
        _score += AppConstants.brainCorrectScore;
        if (_streak > 1) _score += AppConstants.brainStreakBonus;
        _audio.success();
      } else {
        _lives--;
        _streak = 0;
        _shakeCount++;
        _flashCount++;
        _audio.error();
      }
    });

    if (_lives <= 0) {
      Future.delayed(const Duration(milliseconds: 800), _showGameOver);
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _generateQuestion());
          _startTimer();
        }
      });
    }
  }

  Future<void> _showGameOver() async {
    _timer?.cancel();
    _audio.stopBGM();
    _audio.gameOver();
    final provider = context.read<GameProvider>();
    final isNew = await provider.submitScore(
      AppConstants.fiveSecondBrain,
      _score,
    );
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: AppConstants.fiveSecondBrain,
      score: _score,
      isNewHighScore: isNew,
      stats: {
        'Correct': '$_correctAnswers',
        'Streak': '$_maxStreak',
        'Accuracy': _questionsAnswered > 0
            ? '${(_correctAnswers / _questionsAnswered * 100).toInt()}%'
            : '0%',
      },
      onPlayAgain: _resetGame,
      onGoHome: () => context.go('/home'),
    );
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _streak = 0;
      _maxStreak = 0;
      _lives = 3;
      _questionsAnswered = 0;
      _correctAnswers = 0;
      _showCountdown = true;
    });
    _generateQuestion();
  }

  void _showPause() {
    _timer?.cancel();
    _isPaused = true;

    showPauseSheet(
      context,
      gameName: AppConstants.fiveSecondBrain,
      onResume: () {
        _isPaused = false;
        _startTimer();
      },
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
    _timer?.cancel();
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
                gameName: AppConstants.fiveSecondBrain,
                score: _score,
                streak: _streak,
                onPause: _showPause,
              ),
              Expanded(
                child: ShakeWidget(
                  shakeCount: _shakeCount,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXXL,
                      vertical: AppDimensions.paddingLG,
                    ),
                    child: Column(
                      children: [
                        // Lives row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: AnimatedScale(
                                scale: i < _lives ? 1.0 : 0.7,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  i < _lives
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 24,
                                  color: i < _lives
                                      ? AppColors.error
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.gapLG),

                        // Circular timer ring
                        CircularTimerRing(
                          progress: _timeRemaining,
                          size: 100,
                          strokeWidth: 7,
                          child: Text(
                            '${(_timeRemaining * 5).ceil()}s',
                            style: AppTextStyles.timerDisplay.copyWith(
                              fontSize: 22,
                              color: _timeRemaining > 0.5
                                  ? AppColors.success
                                  : _timeRemaining > 0.25
                                  ? AppColors.warning
                                  : AppColors.error,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Equation — large, bold, centered
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation.drive(
                                  Tween(begin: 0.9, end: 1.0).chain(
                                    CurveTween(curve: Curves.easeOutBack),
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            '$_num1 $_operator $_num2 = ?',
                            key: ValueKey(
                              'q$_questionsAnswered-$_num1$_operator$_num2',
                            ),
                            style: AppTextStyles.scoreDisplay.copyWith(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        // Feedback text
                        SizedBox(
                          height: 36,
                          child: _lastAnswerCorrect != null
                              ? Text(
                                      _lastAnswerCorrect!
                                          ? '+${_streak > 1 ? '${AppConstants.brainCorrectScore + AppConstants.brainStreakBonus}' : '${AppConstants.brainCorrectScore}'}'
                                          : 'Answer: $_correctAnswer',
                                      style: AppTextStyles.body.copyWith(
                                        color: _lastAnswerCorrect!
                                            ? AppColors.success
                                            : AppColors.error,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 150.ms)
                                    .slideY(
                                      begin: 0.3,
                                      end: 0,
                                      duration: 250.ms,
                                    )
                              : const SizedBox.shrink(),
                        ),

                        const Spacer(),

                        // 2×2 Answer grid — big touch targets
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: AppDimensions.gapMD,
                          crossAxisSpacing: AppDimensions.gapMD,
                          childAspectRatio: 2.2,
                          physics: const NeverScrollableScrollPhysics(),
                          children: _options.map((option) {
                            final isCorrect = option == _correctAnswer;
                            final isSelected = option == _selectedOption;
                            final hasAnswered = _selectedOption != null;

                            Color bgColor = AppColors.background;
                            Color borderColor = AppColors.surfaceDark;
                            Color textColor = AppColors.textPrimary;

                            if (hasAnswered) {
                              if (isCorrect) {
                                bgColor = AppColors.successLight;
                                borderColor = AppColors.success;
                                textColor = AppColors.success;
                              } else if (isSelected) {
                                bgColor = AppColors.errorLight;
                                borderColor = AppColors.error;
                                textColor = AppColors.error;
                              } else {
                                bgColor = AppColors.surface;
                                borderColor = AppColors.surfaceDark;
                                textColor = AppColors.textTertiary;
                              }
                            }

                            return BounceButton(
                              enableHaptics: !hasAnswered,
                              onTap: () => _selectAnswer(option),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMD,
                                  ),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                  boxShadow: !hasAnswered
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.06,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '$option',
                                    style: AppTextStyles.h2.copyWith(
                                      color: textColor,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: AppDimensions.gapXL),
                      ],
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
