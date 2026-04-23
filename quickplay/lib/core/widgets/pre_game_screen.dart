import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../models/game_registry.dart';
import '../providers/game_provider.dart';
import 'gradient_button.dart';

/// Universal pre-game screen driven by [GameInfo] data.
class PreGameScreen extends StatelessWidget {
  final GameInfo game;

  const PreGameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final highScore = context.watch<GameProvider>().getHighScore(game.id);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXXL),
          child: Column(
            children: [
              const Spacer(),

              // Game icon
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          game.accentColor.withValues(alpha: 0.2),
                          game.accentColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(game.imagePath, fit: BoxFit.cover),
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(),

              const SizedBox(height: AppDimensions.gapXXL),

              // Title
              Text(
                game.title,
                style: AppTextStyles.display,
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppDimensions.gapSM),

              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: game.category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      game.category.icon,
                      size: 14,
                      color: game.category.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      game.category.label,
                      style: AppTextStyles.caption.copyWith(
                        color: game.category.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 150.ms).fadeIn(),

              const SizedBox(height: AppDimensions.gapMD),

              // Description
              Text(
                game.description,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn(),

              // High score
              if (highScore > 0) ...[
                const SizedBox(height: AppDimensions.gapMD),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 16,
                        color: AppColors.goldDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Best: $highScore',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 250.ms).fadeIn(),
              ],

              const SizedBox(height: AppDimensions.gapXXL),

              // How to play
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(color: AppColors.surfaceDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How to Play', style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.gapMD),
                    ...game.instructions.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.gapSM,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: game.accentColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${e.key + 1}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: game.accentColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.gapMD),
                            Expanded(
                              child: Text(e.value, style: AppTextStyles.body),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

              const Spacer(),

              // Start button
              GradientButton(
                text: 'Start Game',
                icon: Icons.play_arrow_rounded,
                gradient: LinearGradient(
                  colors: [
                    game.accentColor,
                    game.accentColor.withValues(alpha: 0.8),
                  ],
                ),
                onPressed: () => context.push(game.playPath),
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppDimensions.gapLG),
            ],
          ),
        ),
      ),
    );
  }
}
