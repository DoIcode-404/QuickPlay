import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/game_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                child: Row(
                  children: [
                    Text(
                      'Profile',
                      style: AppTextStyles.h1.copyWith(fontSize: 28),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),
            ),

            // Avatar & Name
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        provider.playerName[0].toUpperCase(),
                        style: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                  ),
                  const SizedBox(height: AppDimensions.gapMD),
                  Text(provider.playerName, style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${provider.level} • ${provider.xp} XP',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.gapMD),
                  // XP Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXXL * 2,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                      child: LinearProgressIndicator(
                        value: provider.levelProgress,
                        minHeight: 6,
                        backgroundColor: AppColors.surface,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 100.ms).fadeIn(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.gapXXL),
            ),

            // Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXXL,
                ),
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Games',
                      value: '${provider.totalGamesPlayed}',
                      icon: Icons.sports_esports_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.gapMD),
                    _StatCard(
                      label: 'Total XP',
                      value: '${provider.xp}',
                      icon: Icons.star_rounded,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: AppDimensions.gapMD),
                    _StatCard(
                      label: 'Level',
                      value: '${provider.level}',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.success,
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.gapXXL),
            ),

            // Personal Bests
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXXL,
                ),
                child: Text('Personal Bests', style: AppTextStyles.h3),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                child: Column(
                  children: [
                    _BestScoreRow(
                      game: 'Perfect Hit',
                      score: provider.perfectHitHighScore,
                      icon: Icons.gps_fixed_rounded,
                      color: AppColors.streakOrange,
                      imagePath: 'assets/images/perfect_hit_logo.png',
                    ),
                    const SizedBox(height: AppDimensions.gapMD),
                    _BestScoreRow(
                      game: '5-Second Brain',
                      score: provider.brainHighScore,
                      icon: Icons.psychology_rounded,
                      color: AppColors.xpPurple,
                      imagePath: 'assets/images/five_second_brain_logo.png',
                    ),
                    const SizedBox(height: AppDimensions.gapMD),
                    _BestScoreRow(
                      game: 'Dodge Drop',
                      score: provider.dodgeHighScore,
                      icon: Icons.rocket_launch_rounded,
                      color: AppColors.success,
                      imagePath: 'assets/images/dodge_drop_logo.png',
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
            ),

            // Achievements
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXXL,
                ),
                child: Text('Achievements', style: AppTextStyles.h3),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                child: Column(
                  children: [
                    _AchievementRow(
                      title: 'First Game',
                      description: 'Play your first game',
                      icon: Icons.flag_rounded,
                      unlocked: provider.totalGamesPlayed >= 1,
                    ),
                    _AchievementRow(
                      title: 'Dedicated Player',
                      description: 'Play 10 games',
                      icon: Icons.repeat_rounded,
                      unlocked: provider.totalGamesPlayed >= 10,
                      progress: (provider.totalGamesPlayed / 10).clamp(
                        0.0,
                        1.0,
                      ),
                    ),
                    _AchievementRow(
                      title: 'Sharp Shooter',
                      description: 'Score 500+ in Perfect Hit',
                      icon: Icons.gps_fixed_rounded,
                      unlocked: provider.perfectHitHighScore >= 500,
                      progress: (provider.perfectHitHighScore / 500).clamp(
                        0.0,
                        1.0,
                      ),
                    ),
                    _AchievementRow(
                      title: 'Brain Master',
                      description: 'Score 1000+ in 5-Second Brain',
                      icon: Icons.psychology_rounded,
                      unlocked: provider.brainHighScore >= 1000,
                      progress: (provider.brainHighScore / 1000).clamp(
                        0.0,
                        1.0,
                      ),
                    ),
                    _AchievementRow(
                      title: 'Survivor',
                      description: 'Score 300+ in Dodge Drop',
                      icon: Icons.rocket_launch_rounded,
                      unlocked: provider.dodgeHighScore >= 300,
                      progress: (provider.dodgeHighScore / 300).clamp(0.0, 1.0),
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.surfaceDark),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.h3.copyWith(color: color)),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _BestScoreRow extends StatelessWidget {
  final String game;
  final int score;
  final IconData icon;
  final Color color;
  final String? imagePath;

  const _BestScoreRow({
    required this.game,
    required this.score,
    required this.icon,
    required this.color,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Row(
        children: [
          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
          const SizedBox(width: AppDimensions.gapMD),
          Expanded(child: Text(game, style: AppTextStyles.body)),
          Text(
            score > 0 ? '$score' : '—',
            style: AppTextStyles.h3.copyWith(
              color: score > 0 ? color : AppColors.textTertiary,
            ),
          ),
          if (score > 0) ...[
            const SizedBox(width: 6),
            const Icon(Icons.emoji_events, size: 16, color: AppColors.goldDark),
          ],
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final double? progress;

  const _AchievementRow({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.gapMD),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: unlocked
              ? AppColors.gold.withValues(alpha: 0.05)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: unlocked
                ? AppColors.gold.withValues(alpha: 0.3)
                : AppColors.surfaceDark,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: unlocked
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: unlocked ? AppColors.goldDark : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: AppDimensions.gapMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: unlocked
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  if (progress != null && !unlocked) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                      child: LinearProgressIndicator(
                        value: progress!,
                        minHeight: 4,
                        backgroundColor: AppColors.surfaceDark,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (unlocked)
              const Icon(
                Icons.check_circle,
                color: AppColors.goldDark,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
