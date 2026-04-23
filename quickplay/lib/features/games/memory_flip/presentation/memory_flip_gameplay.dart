import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/game_widgets.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/countdown_overlay.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/providers/game_provider.dart';

/// Memory Flip — flip to find matching pairs on a grid.
class MemoryFlipGameplay extends StatefulWidget {
  const MemoryFlipGameplay({super.key});
  @override
  State<MemoryFlipGameplay> createState() => _MemoryFlipGameplayState();
}

class _MemoryFlipGameplayState extends State<MemoryFlipGameplay> {
  late AudioService _audio;
  static const _icons = [
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.bolt_rounded,
    Icons.diamond_rounded,
    Icons.local_fire_department_rounded,
    Icons.music_note_rounded,
    Icons.pets_rounded,
    Icons.wb_sunny_rounded,
  ];

  List<IconData> _cards = [];
  List<bool> _revealed = [];
  List<bool> _matched = [];
  int? _firstFlip;
  int _score = 0;
  int _moves = 0;
  int _pairs = 0;
  int _level = 1;
  int _totalPairs = 0;
  bool _showCountdown = true;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
    _generateBoard();
  }

  void _generateBoard() {
    final numPairs = _level <= 2 ? 4 : 6;
    _totalPairs = numPairs;
    final icons = List<IconData>.from(_icons)..shuffle();
    final selected = icons.take(numPairs).toList();
    _cards = [...selected, ...selected]..shuffle();
    _revealed = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _firstFlip = null;
    _pairs = 0;
    _locked = false;
  }

  void _startGame() {
    setState(() {
      _showCountdown = false;
      _score = 0;
      _moves = 0;
      _level = 1;
      _generateBoard();
    });
    _audio.startBGM('brain');
  }

  void _flipCard(int index) {
    if (_locked || _revealed[index] || _matched[index] || _showCountdown) {
      return;
    }
    _audio.tap();

    setState(() {
      _revealed[index] = true;
      _moves++;
    });

    if (_firstFlip == null) {
      _firstFlip = index;
    } else {
      _locked = true;
      final first = _firstFlip!;
      _firstFlip = null;

      if (_cards[first] == _cards[index]) {
        // Match found
        _audio.success();
        setState(() {
          _matched[first] = true;
          _matched[index] = true;
          _pairs++;
          _score += max(10, 200 - (_moves * 5));
          _locked = false;
        });

        if (_pairs >= _totalPairs) {
          // Level complete
          _audio.levelUp();
          Future.delayed(const Duration(milliseconds: 600), () {
            if (!mounted) return;
            setState(() {
              _level++;
              _generateBoard();
            });
          });
        }
      } else {
        // No match
        _audio.error();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() {
            _revealed[first] = false;
            _revealed[index] = false;
            _locked = false;
          });
        });
      }
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
    final cols = _cards.length <= 8 ? 4 : 4;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              GameHud(
                gameName: 'Memory Flip',
                score: _score,
                timeDisplay: 'Lv.$_level • $_moves moves',
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Memory Flip',
                  onResume: () {},
                  onRestart: () => _startGame(),
                  onQuit: () => context.go('/home'),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final isRevealed = _revealed[index] || _matched[index];
                      return BounceButton(
                        onTap: () => _flipCard(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _matched[index]
                                ? AppColors.success.withValues(alpha: 0.2)
                                : isRevealed
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMD,
                            ),
                            border: Border.all(
                              color: _matched[index]
                                  ? AppColors.success
                                  : isRevealed
                                  ? AppColors.primary
                                  : AppColors.surfaceDark,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isRevealed
                                ? Icon(
                                    _cards[index],
                                    size: 32,
                                    color: _matched[index]
                                        ? AppColors.success
                                        : AppColors.primary,
                                  )
                                : const Icon(
                                    Icons.question_mark_rounded,
                                    size: 24,
                                    color: AppColors.textTertiary,
                                  ),
                          ),
                        ),
                      );
                    },
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
