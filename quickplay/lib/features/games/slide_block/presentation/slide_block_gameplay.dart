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

/// Slide Block Mini — 3x3 sliding puzzle (8-tile).
class SlideBlockGameplay extends StatefulWidget {
  const SlideBlockGameplay({super.key});
  @override
  State<SlideBlockGameplay> createState() => _SlideBlockGameplayState();
}

class _SlideBlockGameplayState extends State<SlideBlockGameplay> {
  late AudioService _audio;
  List<int> _tiles = []; // 0 = empty
  int _moves = 0;
  int _level = 1;
  int _score = 0;
  bool _showCountdown = true;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
    _shuffle();
  }

  void _shuffle() {
    _tiles = List.generate(9, (i) => i); // 0-8, 0=empty
    final rng = Random();
    // Perform valid random moves to ensure solvability
    for (int i = 0; i < 100 + (_level * 30); i++) {
      final empty = _tiles.indexOf(0);
      final neighbors = <int>[];
      if (empty % 3 > 0) neighbors.add(empty - 1);
      if (empty % 3 < 2) neighbors.add(empty + 1);
      if (empty > 2) neighbors.add(empty - 3);
      if (empty < 6) neighbors.add(empty + 3);
      final swap = neighbors[rng.nextInt(neighbors.length)];
      _tiles[empty] = _tiles[swap];
      _tiles[swap] = 0;
    }
    _moves = 0;
    _solved = false;
  }

  void _startGame() {
    setState(() {
      _showCountdown = false;
      _score = 0;
      _level = 1;
      _shuffle();
    });
    _audio.startBGM('brain');
  }

  void _tapTile(int index) {
    if (_solved || _showCountdown) return;
    final empty = _tiles.indexOf(0);
    final validSwap =
        (index == empty - 1 && empty % 3 > 0) ||
        (index == empty + 1 && empty % 3 < 2) ||
        (index == empty - 3) ||
        (index == empty + 3);

    if (!validSwap) return;

    _audio.tap();
    setState(() {
      _tiles[empty] = _tiles[index];
      _tiles[index] = 0;
      _moves++;
    });

    // Check win
    bool won = true;
    for (int i = 0; i < 8; i++) {
      if (_tiles[i] != i + 1) {
        won = false;
        break;
      }
    }
    if (won) {
      _solved = true;
      _score += max(100, 1000 - (_moves * 10));
      _audio.success();
      _audio.levelUp();

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _level++;
          _shuffle();
        });
      });
    }
  }

  @override
  void dispose() {
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
                gameName: 'Slide Block Mini',
                score: _score,
                timeDisplay: 'Lv.$_level • $_moves moves',
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Slide Block Mini',
                  onResume: () {},
                  onRestart: () => _startGame(),
                  onQuit: () => context.go('/home'),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          final val = _tiles[index];
                          if (val == 0) {
                            return const SizedBox();
                          }
                          return BounceButton(
                            onTap: () => _tapTile(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMD,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$val',
                                  style: AppTextStyles.h1.copyWith(
                                    color: Colors.white,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showCountdown) CountdownOverlay(onComplete: _startGame),
        ],
      ),
    );
  }
}
