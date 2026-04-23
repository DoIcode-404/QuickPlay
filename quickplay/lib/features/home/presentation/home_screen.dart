import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/game_registry.dart';

import '../../../core/providers/game_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameCategory? _selectedCategory;

  List<GameInfo> get _filteredGames => _selectedCategory == null
      ? GameRegistry.allGames
      : GameRegistry.byCategory(_selectedCategory!);

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingXXL,
                  AppDimensions.paddingLG,
                  AppDimensions.paddingXXL,
                  0,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Quick',
                                    style: AppTextStyles.h1.copyWith(
                                      fontSize: 28,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Play',
                                    style: AppTextStyles.h1.copyWith(
                                      fontSize: 28,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 2),
                        Text(
                          'Premium Gaming Platform',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ).animate(delay: 100.ms).fadeIn(),
                      ],
                    ),
                    const Spacer(),
                    Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMD,
                            ),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                        )
                        .animate(delay: 200.ms)
                        .fadeIn()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                        ),
                  ],
                ),
              ),
            ),

            // ── Featured Banner ──────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        bottom: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingXL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                              ),
                              child: Text(
                                '🎮 ${GameRegistry.allGames.length} Games',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${GameRegistry.allGames.length} Unique Challenges',
                              style: AppTextStyles.h1.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Reflex • Survival • Puzzle • Brain • Precision',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
              ),
            ),

            // ── Category Chips ───────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXXL,
                  ),
                  children: [
                    _CategoryChip(
                      label: 'All',
                      icon: Icons.apps_rounded,
                      count: GameRegistry.allGames.length,
                      selected: _selectedCategory == null,
                      color: AppColors.primary,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    ...GameCategory.values.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _CategoryChip(
                          label: cat.label,
                          icon: cat.icon,
                          count: GameRegistry.countByCategory(cat),
                          selected: _selectedCategory == cat,
                          color: cat.color,
                          onTap: () => setState(() => _selectedCategory = cat),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 280.ms).fadeIn(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.gapLG),
            ),

            // ── Section Title ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXXL,
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedCategory?.label ?? 'All Games',
                      style: AppTextStyles.h2,
                    ),
                    const Spacer(),
                    Text(
                      '${_filteredGames.length} Games',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ).animate(delay: 300.ms).fadeIn(),
              ),
            ),

            // ── Game Grid (2 columns) ───────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXXL,
                vertical: AppDimensions.paddingLG,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppDimensions.gapMD,
                  crossAxisSpacing: AppDimensions.gapMD,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final game = _filteredGames[index];
                  final highScore = gameProvider.getHighScore(game.id);

                  return GestureDetector(
                    onTap: () => context.push(game.routePath),
                    child:
                        Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusXL,
                                ),
                                border: Border.all(
                                  color: AppColors.surfaceDark,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Game Icon Image
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: game.accentColor.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        game.imagePath,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Title
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      game.title,
                                      style: AppTextStyles.h3.copyWith(
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Best Score Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: highScore > 0
                                          ? AppColors.gold.withValues(
                                              alpha: 0.15,
                                            )
                                          : AppColors.primary.withValues(
                                              alpha: 0.15,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (highScore > 0)
                                          const Icon(
                                            Icons.emoji_events_rounded,
                                            size: 12,
                                            color: AppColors.gold,
                                          )
                                        else
                                          const Icon(
                                            Icons.new_releases_rounded,
                                            size: 12,
                                            color: AppColors.primary,
                                          ),
                                        const SizedBox(width: 4),
                                        Text(
                                          highScore > 0 ? '$highScore' : 'NEW',
                                          style: AppTextStyles.caption.copyWith(
                                            color: highScore > 0
                                                ? AppColors.gold
                                                : AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate(
                              delay: Duration(milliseconds: 350 + (index * 40)),
                            )
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              curve: Curves.easeOutBack,
                            ),
                  );
                }, childCount: _filteredGames.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Chip Widget ──────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: selected ? color : AppColors.surfaceDark,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: AppTextStyles.caption.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
