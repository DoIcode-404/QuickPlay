import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import 'gradient_button.dart';
import 'micro_interactions.dart';

// ─── PREMIUM GAME HUD ────────────────────────────────────────────────────

class GameHud extends StatelessWidget {
  final String gameName;
  final int score;
  final String? timeDisplay;
  final int? streak;
  final VoidCallback onPause;

  const GameHud({
    super.key,
    required this.gameName,
    required this.score,
    this.timeDisplay,
    this.streak,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Score chip (left)
            _HudChip(
              gradient: AppColors.primaryGradient,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 4),
                  ScoreBump(
                    score: score,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Streak indicator
            if (streak != null && streak! > 1) ...[
              const SizedBox(width: 6),
              _HudChip(
                color: AppColors.streakOrange.withValues(alpha: 0.12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 13,
                      color: AppColors.streakOrange,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${streak}x',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.streakOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 200.ms,
                curve: Curves.easeOutBack,
              ),
            ],

            const Spacer(),

            // Timer/Level chip (right)
            if (timeDisplay != null) ...[
              _HudChip(
                color: AppColors.surface,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeDisplay!,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Circular pause button (top-right)
            BounceButton(
              onTap: onPause,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceDark, width: 1.5),
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final Color? color;

  const _HudChip({required this.child, this.gradient, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (color ?? AppColors.surface) : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: child,
    );
  }
}

// ─── PREMIUM PAUSE BOTTOM SHEET ──────────────────────────────────────────

void showPauseSheet(
  BuildContext context, {
  required String gameName,
  required VoidCallback onResume,
  required VoidCallback onRestart,
  required VoidCallback onQuit,
}) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PauseSheet(
      gameName: gameName,
      onResume: () {
        Navigator.pop(ctx);
        onResume();
      },
      onRestart: () {
        Navigator.pop(ctx);
        onRestart();
      },
      onQuit: () {
        Navigator.pop(ctx);
        onQuit();
      },
    ),
  );
}

class _PauseSheet extends StatelessWidget {
  final String gameName;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const _PauseSheet({
    required this.gameName,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppDimensions.gapXL),

          // Pause icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pause_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: AppDimensions.gapLG),

          Text('Game Paused', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(gameName, style: AppTextStyles.caption),
          const SizedBox(height: AppDimensions.gapXXL),

          GradientButton(
            text: 'Resume',
            icon: Icons.play_arrow_rounded,
            onPressed: onResume,
          ),
          const SizedBox(height: AppDimensions.gapMD),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppDimensions.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Restart'),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.gapMD),
              Expanded(
                child: SizedBox(
                  height: AppDimensions.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: onQuit,
                    icon: Icon(
                      Icons.exit_to_app_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    label: Text(
                      'Exit',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.gapLG),
        ],
      ),
    ).animate().slideY(
      begin: 0.1,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOutCubic,
    );
  }
}

// ─── PREMIUM GAME OVER BOTTOM SHEET ──────────────────────────────────────

void showGameOverSheet(
  BuildContext context, {
  required String gameName,
  required int score,
  bool isNewHighScore = false,
  Map<String, String>? stats,
  required VoidCallback onPlayAgain,
  required VoidCallback onGoHome,
}) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _GameOverSheet(
      gameName: gameName,
      score: score,
      isNewHighScore: isNewHighScore,
      stats: stats,
      onPlayAgain: () {
        Navigator.pop(ctx);
        onPlayAgain();
      },
      onGoHome: () {
        Navigator.pop(ctx);
        onGoHome();
      },
    ),
  );
}

class _GameOverSheet extends StatelessWidget {
  final String gameName;
  final int score;
  final bool isNewHighScore;
  final Map<String, String>? stats;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  const _GameOverSheet({
    required this.gameName,
    required this.score,
    required this.isNewHighScore,
    this.stats,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppDimensions.gapXL),

          // New high score badge
          if (isNewHighScore)
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'New High Score!',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )
                .shimmer(duration: 1500.ms, delay: 500.ms),

          if (isNewHighScore) const SizedBox(height: AppDimensions.gapLG),

          Text(
            'Game Over',
            style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.gapMD),

          // Big animated score
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: score),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Text(
                '$value',
                style: AppTextStyles.scoreDisplay.copyWith(fontSize: 56),
              );
            },
          ),
          Text('POINTS', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.gapXL),

          // Stats grid
          if (stats != null && stats!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: stats!.entries.map((e) {
                  return Column(
                    children: [
                      Text(
                        e.value,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        e.key,
                        style: AppTextStyles.label.copyWith(fontSize: 10),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: AppDimensions.gapXXL),

          // CTA buttons
          GradientButton(
            text: 'Play Again',
            icon: Icons.refresh_rounded,
            onPressed: onPlayAgain,
          ),
          const SizedBox(height: AppDimensions.gapMD),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: onGoHome,
              icon: const Icon(Icons.home_rounded, size: 18),
              label: const Text('Back to Home'),
            ),
          ),
          const SizedBox(height: AppDimensions.gapLG),
        ],
      ),
    ).animate().slideY(
      begin: 0.15,
      end: 0,
      duration: 350.ms,
      curve: Curves.easeOutCubic,
    );
  }
}

// ─── KEEP LEGACY CLASSES FOR BACKWARD COMPAT (deprecated, use sheets) ────

class PauseDialog extends StatelessWidget {
  final String gameName;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseDialog({
    super.key,
    required this.gameName,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class GameOverDialog extends StatelessWidget {
  final String gameName;
  final int score;
  final int? highScore;
  final bool isNewHighScore;
  final Map<String, String>? stats;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  const GameOverDialog({
    super.key,
    required this.gameName,
    required this.score,
    this.highScore,
    this.isNewHighScore = false,
    this.stats,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
