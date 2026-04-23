import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/models/game_registry.dart';
import '../core/widgets/pre_game_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/leaderboard/presentation/leaderboard_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/home/presentation/shell_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

// ── Existing game screens ────────────────────────────────────────────
import '../features/games/perfect_hit/presentation/perfect_hit_gameplay.dart';
import '../features/games/five_second_brain/presentation/brain_gameplay.dart';
import '../features/games/dodge_drop/presentation/dodge_gameplay.dart';

// ── New game screens ─────────────────────────────────────────────────
import '../features/games/color_switch_rush/presentation/color_switch_gameplay.dart';
import '../features/games/tile_tap_speed/presentation/tile_tap_gameplay.dart';
import '../features/games/target_drop/presentation/target_drop_gameplay.dart';
import '../features/games/balance_ball/presentation/balance_ball_gameplay.dart';
import '../features/games/avoid_laser/presentation/avoid_laser_gameplay.dart';
import '../features/games/memory_flip/presentation/memory_flip_gameplay.dart';
import '../features/games/slide_block/presentation/slide_block_gameplay.dart';
import '../features/games/connect_lines/presentation/connect_lines_gameplay.dart';
import '../features/games/merge_numbers/presentation/merge_numbers_gameplay.dart';
import '../features/games/odd_one_out/presentation/odd_one_out_gameplay.dart';
import '../features/games/quick_decision/presentation/quick_decision_gameplay.dart';
import '../features/games/stack_tower/presentation/stack_tower_gameplay.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static CustomTransitionPage _slideUp(Widget child, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static CustomTransitionPage _fadeScale(Widget child, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleTween = Tween(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Resolve game ID to its gameplay widget.
  static Widget _gameplayScreen(String gameId) {
    switch (gameId) {
      case 'perfect_hit':
        return const PerfectHitGameplay();
      case 'five_second_brain':
        return const BrainGameplay();
      case 'dodge_drop':
        return const DodgeGameplay();
      case 'color_switch_rush':
        return const ColorSwitchGameplay();
      case 'tile_tap_speed':
        return const TileTapGameplay();
      case 'target_drop':
        return const TargetDropGameplay();
      case 'balance_ball':
        return const BalanceBallGameplay();
      case 'avoid_laser':
        return const AvoidLaserGameplay();
      case 'memory_flip':
        return const MemoryFlipGameplay();
      case 'slide_block':
        return const SlideBlockGameplay();
      case 'connect_lines':
        return const ConnectLinesGameplay();
      case 'merge_numbers':
        return const MergeNumbersGameplay();
      case 'odd_one_out':
        return const OddOneOutGameplay();
      case 'quick_decision':
        return const QuickDecisionGameplay();
      case 'stack_tower':
        return const StackTowerGameplay();
      default:
        return const Scaffold(body: Center(child: Text('Game not found')));
    }
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            _fadeScale(const SplashScreen(), state),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadeScale(const LoginScreen(), state),
      ),
      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/leaderboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LeaderboardScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // ── Data-driven game routes ────────────────────────────────────
      ...GameRegistry.allGames.expand(
        (game) => [
          GoRoute(
            path: game.routePath,
            pageBuilder: (context, state) =>
                _slideUp(PreGameScreen(game: game), state),
          ),
          GoRoute(
            path: game.playPath,
            pageBuilder: (context, state) =>
                _fadeScale(_gameplayScreen(game.id), state),
          ),
        ],
      ),

      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            _slideUp(const SettingsScreen(), state),
      ),
    ],
  );
}
