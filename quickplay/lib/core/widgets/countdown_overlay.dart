import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/audio_service.dart';
import '../providers/game_provider.dart';

class CountdownOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const CountdownOverlay({super.key, required this.onComplete});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int _count = 3;
  late AudioService _audio;

  @override
  void initState() {
    super.initState();
    _audio = AudioService(context.read<GameProvider>());
    _audio.countdownTick(); // Play tick for "3"
    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_count <= 1) {
        timer.cancel();
        _audio.countdownGo();
        widget.onComplete();
      } else {
        setState(() => _count--);
        _audio.countdownTick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = _count > 0 ? '$_count' : 'GO!';
    final color = _count == 3
        ? AppColors.error
        : _count == 2
        ? AppColors.streakOrange
        : AppColors.success;

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child:
            AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    label,
                    key: ValueKey(_count),
                    style: AppTextStyles.scoreDisplay.copyWith(
                      fontSize: 80,
                      color: color,
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                ),
      ),
    );
  }
}
