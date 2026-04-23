import 'package:flutter/material.dart';

// ─── CATEGORY SYSTEM ─────────────────────────────────────────────────────

enum GameCategory { reflex, survival, puzzle, brain, precision }

extension GameCategoryX on GameCategory {
  String get label {
    switch (this) {
      case GameCategory.reflex:
        return 'Reflex';
      case GameCategory.survival:
        return 'Survival';
      case GameCategory.puzzle:
        return 'Puzzle';
      case GameCategory.brain:
        return 'Brain';
      case GameCategory.precision:
        return 'Precision';
    }
  }

  IconData get icon {
    switch (this) {
      case GameCategory.reflex:
        return Icons.flash_on_rounded;
      case GameCategory.survival:
        return Icons.shield_rounded;
      case GameCategory.puzzle:
        return Icons.extension_rounded;
      case GameCategory.brain:
        return Icons.psychology_rounded;
      case GameCategory.precision:
        return Icons.gps_fixed_rounded;
    }
  }

  Color get color {
    switch (this) {
      case GameCategory.reflex:
        return const Color(0xFFFF6B35);
      case GameCategory.survival:
        return const Color(0xFF10B981);
      case GameCategory.puzzle:
        return const Color(0xFF8B5CF6);
      case GameCategory.brain:
        return const Color(0xFF3B82F6);
      case GameCategory.precision:
        return const Color(0xFFEF4444);
    }
  }
}

// ─── GAME INFO ───────────────────────────────────────────────────────────

class GameInfo {
  final String id;
  final String title;
  final String description;
  final GameCategory category;
  final String imagePath;
  final Color accentColor;
  final String routePath;
  final String playPath;
  final List<String> instructions;
  final String bgmId;

  const GameInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imagePath,
    required this.accentColor,
    required this.routePath,
    required this.playPath,
    required this.instructions,
    required this.bgmId,
  });
}

// ─── REGISTRY ────────────────────────────────────────────────────────────

class GameRegistry {
  GameRegistry._();

  static const _games = <GameInfo>[
    // ── EXISTING 3 ───────────────────────────
    GameInfo(
      id: 'perfect_hit',
      title: 'Perfect Hit',
      description:
          'Tap at the perfect moment when the indicator hits the target zone.',
      category: GameCategory.precision,
      imagePath: 'assets/images/games/perfect_hit.png',
      accentColor: Color(0xFFFF6B35),
      routePath: '/game/perfect-hit',
      playPath: '/game/perfect-hit/play',
      instructions: [
        'Watch the indicator move across the bar',
        'Tap when it\'s in the highlighted zone',
        'Closer to center = higher score!',
      ],
      bgmId: 'perfect_hit',
    ),
    GameInfo(
      id: 'five_second_brain',
      title: '5-Second Brain',
      description:
          'Solve rapid-fire math equations before the 5-second timer runs out.',
      category: GameCategory.brain,
      imagePath: 'assets/images/games/five_second_brain.png',
      accentColor: Color(0xFF8B5CF6),
      routePath: '/game/brain',
      playPath: '/game/brain/play',
      instructions: [
        'Read the math equation',
        'Choose the correct answer from 4 options',
        'Each correct answer adds 5 seconds!',
      ],
      bgmId: 'brain',
    ),
    GameInfo(
      id: 'dodge_drop',
      title: 'Dodge Drop',
      description:
          'Dodge falling obstacles by swiping left and right. Survive as long as you can!',
      category: GameCategory.survival,
      imagePath: 'assets/images/games/dodge_drop.png',
      accentColor: Color(0xFF10B981),
      routePath: '/game/dodge',
      playPath: '/game/dodge/play',
      instructions: [
        'Drag left and right to move',
        'Dodge the falling blocks',
        'Survive as long as possible!',
      ],
      bgmId: 'dodge',
    ),

    // ── REFLEX (3 new) ───────────────────────
    GameInfo(
      id: 'color_switch_rush',
      title: 'Color Switch Rush',
      description:
          'Tap to change your ball\'s color to match the rotating ring.',
      category: GameCategory.reflex,
      imagePath: 'assets/images/games/color_switch.png',
      accentColor: Color(0xFFFF6B35),
      routePath: '/game/color-switch',
      playPath: '/game/color-switch/play',
      instructions: [
        'Your ball has a color that changes on tap',
        'Pass through ring segments matching your color',
        'Wrong color = game over!',
      ],
      bgmId: 'perfect_hit',
    ),
    GameInfo(
      id: 'tile_tap_speed',
      title: 'Tile Tap Speed',
      description:
          'Tap the highlighted tiles as fast as you can in a rapid-fire grid.',
      category: GameCategory.reflex,
      imagePath: 'assets/images/games/tile_tap.png',
      accentColor: Color(0xFFF59E0B),
      routePath: '/game/tile-tap',
      playPath: '/game/tile-tap/play',
      instructions: [
        'Tiles light up on a 3×3 grid',
        'Tap them as fast as possible',
        'Speed increases every round!',
      ],
      bgmId: 'perfect_hit',
    ),
    GameInfo(
      id: 'target_drop',
      title: 'Target Drop',
      description: 'Drop a ball onto a moving target. Precision wins!',
      category: GameCategory.reflex,
      imagePath: 'assets/images/games/target_drop.png',
      accentColor: Color(0xFFEC4899),
      routePath: '/game/target-drop',
      playPath: '/game/target-drop/play',
      instructions: [
        'A target slides left and right at the bottom',
        'Tap to drop the ball from above',
        'Hit the bullseye for max points!',
      ],
      bgmId: 'perfect_hit',
    ),

    // ── SURVIVAL (2 new) ─────────────────────
    GameInfo(
      id: 'balance_ball',
      title: 'Balance the Ball',
      description: 'Keep the ball on a tilting platform by dragging carefully.',
      category: GameCategory.survival,
      imagePath: 'assets/images/games/balance_ball.png',
      accentColor: Color(0xFF14B8A6),
      routePath: '/game/balance-ball',
      playPath: '/game/balance-ball/play',
      instructions: [
        'Drag to tilt the platform',
        'Keep the ball from rolling off',
        'Platform tilts faster over time!',
      ],
      bgmId: 'dodge',
    ),
    GameInfo(
      id: 'avoid_laser',
      title: 'Avoid Laser',
      description: 'Dodge sweeping laser beams that get faster and faster.',
      category: GameCategory.survival,
      imagePath: 'assets/images/games/avoid_laser.png',
      accentColor: Color(0xFFEF4444),
      routePath: '/game/avoid-laser',
      playPath: '/game/avoid-laser/play',
      instructions: [
        'Lasers sweep across the screen',
        'Drag your player to dodge them',
        'Speed increases every 10 seconds!',
      ],
      bgmId: 'dodge',
    ),

    // ── PUZZLE (4 new) ───────────────────────
    GameInfo(
      id: 'memory_flip',
      title: 'Memory Flip',
      description: 'Flip cards and find all matching pairs in a 3×3 grid.',
      category: GameCategory.puzzle,
      imagePath: 'assets/images/games/memory_flip.png',
      accentColor: Color(0xFF8B5CF6),
      routePath: '/game/memory-flip',
      playPath: '/game/memory-flip/play',
      instructions: [
        'Tap cards to flip them over',
        'Find matching pairs from memory',
        'Clear all pairs to advance!',
      ],
      bgmId: 'brain',
    ),
    GameInfo(
      id: 'slide_block',
      title: 'Slide Block Mini',
      description: 'Slide numbered tiles to put them in order.',
      category: GameCategory.puzzle,
      imagePath: 'assets/images/games/slide_block.png',
      accentColor: Color(0xFF6366F1),
      routePath: '/game/slide-block',
      playPath: '/game/slide-block/play',
      instructions: [
        'Tap a tile next to the empty space',
        'Arrange numbers 1-8 in order',
        'Fewer moves = higher score!',
      ],
      bgmId: 'brain',
    ),
    GameInfo(
      id: 'connect_lines',
      title: 'Connect Lines',
      description: 'Connect matching colored dots without crossing lines.',
      category: GameCategory.puzzle,
      imagePath: 'assets/images/games/connect_lines.png',
      accentColor: Color(0xFF0EA5E9),
      routePath: '/game/connect-lines',
      playPath: '/game/connect-lines/play',
      instructions: [
        'Drag from one dot to its matching pair',
        'Lines cannot cross each other',
        'Fill the entire board to win!',
      ],
      bgmId: 'brain',
    ),
    GameInfo(
      id: 'merge_numbers',
      title: 'Merge Numbers',
      description:
          'Merge matching numbers on a 3×3 grid to reach higher values.',
      category: GameCategory.puzzle,
      imagePath: 'assets/images/games/merge_numbers.png',
      accentColor: Color(0xFFD946EF),
      routePath: '/game/merge-numbers',
      playPath: '/game/merge-numbers/play',
      instructions: [
        'Tap two adjacent matching numbers to merge',
        'Merged numbers double in value',
        'Clear space and score big!',
      ],
      bgmId: 'brain',
    ),

    // ── BRAIN (2 new) ────────────────────────
    GameInfo(
      id: 'odd_one_out',
      title: 'Odd One Out',
      description: 'Spot the icon that\'s slightly different from the rest.',
      category: GameCategory.brain,
      imagePath: 'assets/images/games/odd_one_out.png',
      accentColor: Color(0xFF3B82F6),
      routePath: '/game/odd-one-out',
      playPath: '/game/odd-one-out/play',
      instructions: [
        'Four icons are shown — one is different',
        'Tap the odd one before time runs out',
        'Differences get more subtle!',
      ],
      bgmId: 'brain',
    ),
    GameInfo(
      id: 'quick_decision',
      title: 'Quick Decision',
      description: 'True or false? Decide fast before the timer expires!',
      category: GameCategory.brain,
      imagePath: 'assets/images/games/quick_decision.png',
      accentColor: Color(0xFF06B6D4),
      routePath: '/game/quick-decision',
      playPath: '/game/quick-decision/play',
      instructions: [
        'A statement appears on screen',
        'Decide if it\'s TRUE or FALSE',
        'Answer as many as you can!',
      ],
      bgmId: 'brain',
    ),

    // ── PRECISION (1 new) ────────────────────
    GameInfo(
      id: 'stack_tower',
      title: 'Stack Tower 2.0',
      description: 'Stack moving blocks perfectly to build the tallest tower.',
      category: GameCategory.precision,
      imagePath: 'assets/images/games/stack_tower.png',
      accentColor: Color(0xFFEF4444),
      routePath: '/game/stack-tower',
      playPath: '/game/stack-tower/play',
      instructions: [
        'A block slides left and right',
        'Tap to drop it on the stack',
        'Overhanging parts get cut off!',
      ],
      bgmId: 'perfect_hit',
    ),
  ];

  static List<GameInfo> get allGames => _games;

  static List<GameInfo> byCategory(GameCategory category) =>
      _games.where((g) => g.category == category).toList();

  static GameInfo? byId(String id) {
    try {
      return _games.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  static int countByCategory(GameCategory category) =>
      _games.where((g) => g.category == category).length;
}
