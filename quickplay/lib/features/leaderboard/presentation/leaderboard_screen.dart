import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/game_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final hasData = provider.totalGamesPlayed > 0;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingXXL,
                AppDimensions.paddingLG,
                AppDimensions.paddingXXL,
                0,
              ),
              child: Row(
                children: [
                  Text(
                    'Leaderboard',
                    style: AppTextStyles.h1.copyWith(fontSize: 28),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.xp} XP',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.gapLG),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXXL,
              ),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: AppTextStyles.caption,
                  unselectedLabelStyle: AppTextStyles.caption,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'All Games'),
                    Tab(text: 'Weekly'),
                    Tab(text: 'Friends'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.gapLG),

            // Content
            Expanded(
              child: hasData
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _LeaderboardList(provider: provider),
                        _LeaderboardList(provider: provider),
                        _EmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No Friends Yet',
                          subtitle: 'Invite friends to see their scores here',
                        ),
                      ],
                    )
                  : _EmptyState(
                      icon: Icons.emoji_events_outlined,
                      title: 'No Scores Yet',
                      subtitle: 'Play games to see your rankings here!',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: AppColors.textTertiary),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 400.ms,
          ),
          const SizedBox(height: AppDimensions.gapLG),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.gapSM),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _LeaderboardList extends StatelessWidget {
  final GameProvider provider;

  const _LeaderboardList({required this.provider});

  @override
  Widget build(BuildContext context) {
    // Build leaderboard from actual player data + mock competitors
    final entries = <_LeaderboardEntry>[
      _LeaderboardEntry('ShadowNinja', 2450, '🥇'),
      _LeaderboardEntry('PixelQueen', 2100, '🥈'),
      _LeaderboardEntry('ThunderBolt', 1850, '🥉'),
      _LeaderboardEntry(provider.playerName, provider.totalScore, ''),
      _LeaderboardEntry('StarGazer', 980, ''),
      _LeaderboardEntry('NeonWolf', 760, ''),
      _LeaderboardEntry('CosmicRay', 540, ''),
      _LeaderboardEntry('BlazeFury', 320, ''),
    ];

    // Sort by score
    entries.sort((a, b) => b.score.compareTo(a.score));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXXL),
      children: [
        // Top 3 podium
        if (entries.length >= 3)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.gapXXL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _PodiumItem(
                  entry: entries[1],
                  rank: 2,
                  height: 80,
                  isPlayer: entries[1].name == provider.playerName,
                ),
                const SizedBox(width: AppDimensions.gapSM),
                _PodiumItem(
                  entry: entries[0],
                  rank: 1,
                  height: 100,
                  isPlayer: entries[0].name == provider.playerName,
                ),
                const SizedBox(width: AppDimensions.gapSM),
                _PodiumItem(
                  entry: entries[2],
                  rank: 3,
                  height: 65,
                  isPlayer: entries[2].name == provider.playerName,
                ),
              ],
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
          ),

        // Ranked list
        ...List.generate(entries.length, (i) {
          final entry = entries[i];
          final isPlayer = entry.name == provider.playerName;
          return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.gapSM),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMD,
                    vertical: AppDimensions.paddingSM,
                  ),
                  decoration: BoxDecoration(
                    color: isPlayer
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(
                      color: isPlayer
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.surfaceDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${i + 1}',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: i < 3
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                      // Avatar
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isPlayer
                              ? AppColors.primary
                              : AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            entry.name[0].toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: isPlayer
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.gapMD),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPlayer ? '${entry.name} (You)' : entry.name,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: isPlayer
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${entry.score}',
                        style: AppTextStyles.h3.copyWith(
                          color: isPlayer
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate(delay: Duration(milliseconds: 100 + i * 50))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.05, end: 0);
        }),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final _LeaderboardEntry entry;
  final int rank;
  final double height;
  final bool isPlayer;

  const _PodiumItem({
    required this.entry,
    required this.rank,
    required this.height,
    required this.isPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final medals = ['', '🥇', '🥈', '🥉'];
    final colors = [
      Colors.transparent,
      AppColors.gold,
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    return Column(
      children: [
        Text(medals[rank], style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isPlayer ? AppColors.primary : colors[rank],
            shape: BoxShape.circle,
            border: Border.all(color: colors[rank], width: 2),
          ),
          child: Center(
            child: Text(
              entry.name[0].toUpperCase(),
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entry.name.length > 8
              ? '${entry.name.substring(0, 8)}...'
              : entry.name,
          style: AppTextStyles.caption.copyWith(
            fontWeight: isPlayer ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          '${entry.score}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors[rank].withValues(alpha: 0.3),
                colors[rank].withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardEntry {
  final String name;
  final int score;
  final String medal;

  _LeaderboardEntry(this.name, this.score, this.medal);
}
