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

/// Connect Lines — connect matching colored dots on a grid.
class ConnectLinesGameplay extends StatefulWidget {
  const ConnectLinesGameplay({super.key});
  @override
  State<ConnectLinesGameplay> createState() => _ConnectLinesGameplayState();
}

class _ConnectLinesGameplayState extends State<ConnectLinesGameplay> {
  late AudioService _audio;
  static const _dotColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF845EC2),
    Color(0xFF3B82F6),
  ];

  final int _gridSize = 5;
  List<List<int>> _grid = []; // -1 = empty, 0-4 = color index
  int _score = 0;
  int _level = 1;
  int _pairsLeft = 0;
  bool _showCountdown = true;
  int? _selectedR, _selectedC;

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
    _generateBoard();
  }

  void _generateBoard() {
    final rng = Random();
    _grid = List.generate(_gridSize, (_) => List.filled(_gridSize, -1));
    final numPairs = 3 + (_level ~/ 2).clamp(0, 2);
    _pairsLeft = numPairs;

    for (int c = 0; c < numPairs; c++) {
      // Place two dots of each color
      for (int d = 0; d < 2; d++) {
        int r, cl;
        do {
          r = rng.nextInt(_gridSize);
          cl = rng.nextInt(_gridSize);
        } while (_grid[r][cl] != -1);
        _grid[r][cl] = c;
      }
    }
    _selectedR = null;
    _selectedC = null;
  }

  void _startGame() {
    setState(() {
      _showCountdown = false;
      _score = 0;
      _level = 1;
      _generateBoard();
    });
    _audio.startBGM('brain');
  }

  void _tapCell(int r, int c) {
    if (_showCountdown) return;
    final val = _grid[r][c];

    if (_selectedR == null) {
      if (val >= 0) {
        setState(() {
          _selectedR = r;
          _selectedC = c;
        });
        _audio.tap();
      }
    } else {
      if (r == _selectedR && c == _selectedC) {
        setState(() {
          _selectedR = null;
          _selectedC = null;
        });
        return;
      }

      final selVal = _grid[_selectedR!][_selectedC!];
      if (val == selVal && val >= 0) {
        // Match!
        _audio.success();
        setState(() {
          _grid[_selectedR!][_selectedC!] = -2; // matched
          _grid[r][c] = -2;
          _selectedR = null;
          _selectedC = null;
          _pairsLeft--;
          _score += 200;
        });

        if (_pairsLeft <= 0) {
          _audio.levelUp();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            setState(() {
              _level++;
              _generateBoard();
            });
          });
        }
      } else {
        _audio.error();
        setState(() {
          _selectedR = null;
          _selectedC = null;
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
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              GameHud(
                gameName: 'Connect Lines',
                score: _score,
                timeDisplay: 'Lv.$_level • $_pairsLeft pairs left',
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Connect Lines',
                  onResume: () {},
                  onRestart: () => _startGame(),
                  onQuit: () => context.go('/home'),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridSize,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: _gridSize * _gridSize,
                        itemBuilder: (context, index) {
                          final r = index ~/ _gridSize;
                          final c = index % _gridSize;
                          final val = _grid[r][c];
                          final isSelected = r == _selectedR && c == _selectedC;
                          final isMatched = val == -2;

                          return BounceButton(
                            onTap: () => _tapCell(r, c),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isMatched
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : val >= 0
                                    ? _dotColors[val % _dotColors.length]
                                          .withValues(alpha: 0.15)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSM,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : isMatched
                                      ? AppColors.success
                                      : AppColors.surfaceDark,
                                  width: isSelected ? 3 : 1.5,
                                ),
                              ),
                              child: val >= 0
                                  ? Center(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color:
                                              _dotColors[val %
                                                  _dotColors.length],
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  _dotColors[val %
                                                          _dotColors.length]
                                                      .withValues(alpha: 0.4),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : isMatched
                                  ? const Center(
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                        color: AppColors.success,
                                      ),
                                    )
                                  : null,
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
