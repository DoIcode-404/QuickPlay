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

/// Merge Numbers Mini — merge same-value adjacent numbers on a 3x3 grid.
class MergeNumbersGameplay extends StatefulWidget {
  const MergeNumbersGameplay({super.key});
  @override
  State<MergeNumbersGameplay> createState() => _MergeNumbersGameplayState();
}

class _MergeNumbersGameplayState extends State<MergeNumbersGameplay> {
  late AudioService _audio;
  List<List<int>> _grid = [];
  int _score = 0;
  int? _selR, _selC;
  bool _showCountdown = true;
  bool _isGameOver = false;
  final _rng = Random();

  static const _tileColors = {
    2: Color(0xFFEDE0C8),
    4: Color(0xFFEDE0B0),
    8: Color(0xFFF2B179),
    16: Color(0xFFF59563),
    32: Color(0xFFF67C5F),
    64: Color(0xFFF65E3B),
    128: Color(0xFFEDCF72),
    256: Color(0xFFEDCC61),
    512: Color(0xFF9B59B6),
    1024: Color(0xFF1ABC9C),
  };

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
    _initGrid();
  }

  void _initGrid() {
    _grid = List.generate(
      3,
      (_) => List.generate(3, (_) {
        return _rng.nextBool() ? 2 : (_rng.nextDouble() < 0.3 ? 4 : 2);
      }),
    );
  }

  void _startGame() {
    setState(() {
      _showCountdown = false;
      _isGameOver = false;
      _score = 0;
      _initGrid();
    });
    _audio.startBGM('brain');
  }

  void _tapCell(int r, int c) {
    if (_showCountdown || _isGameOver) return;

    if (_selR == null) {
      setState(() {
        _selR = r;
        _selC = c;
      });
      _audio.tap();
      return;
    }

    // Check adjacency
    final dr = (r - _selR!).abs();
    final dc = (c - _selC!).abs();
    final adjacent = (dr + dc) == 1;

    if (adjacent && _grid[r][c] == _grid[_selR!][_selC!] && _grid[r][c] > 0) {
      // Merge!
      _audio.success();
      setState(() {
        _grid[r][c] *= 2;
        _score += _grid[r][c];
        _grid[_selR!][_selC!] = 0;
        _selR = null;
        _selC = null;
      });

      // Fill empty cells
      _fillEmpty();

      // Check game over
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_hasValidMoves()) _gameOver();
      });
    } else {
      setState(() {
        _selR = r;
        _selC = c;
      });
      _audio.tap();
    }
  }

  void _fillEmpty() {
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (_grid[r][c] == 0) {
          _grid[r][c] = _rng.nextDouble() < 0.7 ? 2 : 4;
        }
      }
    }
  }

  bool _hasValidMoves() {
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (c < 2 && _grid[r][c] == _grid[r][c + 1]) return true;
        if (r < 2 && _grid[r][c] == _grid[r + 1][c]) return true;
      }
    }
    return false;
  }

  Future<void> _gameOver() async {
    _isGameOver = true;
    _audio.stopBGM();
    _audio.gameOver();

    final provider = context.read<GameProvider>();
    final isNew = await provider.submitScore('Merge Numbers Mini', _score);
    if (!mounted) return;

    showGameOverSheet(
      context,
      gameName: 'Merge Numbers Mini',
      score: _score,
      isNewHighScore: isNew,
      stats: {},
      onPlayAgain: () => _startGame(),
      onGoHome: () => context.go('/home'),
    );
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
                gameName: 'Merge Numbers',
                score: _score,
                timeDisplay: 'Merge matching tiles',
                onPause: () => showPauseSheet(
                  context,
                  gameName: 'Merge Numbers Mini',
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
                          final r = index ~/ 3;
                          final c = index % 3;
                          final val = _grid.isNotEmpty ? _grid[r][c] : 0;
                          final isSelected = r == _selR && c == _selC;
                          final color =
                              _tileColors[val] ?? const Color(0xFFCDC1B4);

                          return BounceButton(
                            onTap: () => _tapCell(r, c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMD,
                                ),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primary,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  val > 0 ? '$val' : '',
                                  style: AppTextStyles.h1.copyWith(
                                    color: val > 4
                                        ? Colors.white
                                        : const Color(0xFF776E65),
                                    fontSize: val >= 100 ? 22 : 28,
                                    fontWeight: FontWeight.w800,
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
