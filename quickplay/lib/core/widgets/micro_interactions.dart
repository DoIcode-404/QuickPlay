import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tap-scale button wrapper — scales 0.98 on press with light haptic
class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool enableHaptics;

  const BounceButton({
    super.key,
    required this.child,
    required this.onTap,
    this.enableHaptics = true,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.enableHaptics) HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// Animated score display — bumps scale on value change
class ScoreBump extends StatelessWidget {
  final int score;
  final TextStyle style;
  final Color? glowColor;

  const ScoreBump({
    super.key,
    required this.score,
    required this.style,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(score),
      tween: Tween(begin: 1.3, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Text('$score', style: style),
        );
      },
    );
  }
}

/// Shake animation triggered by changing a trigger key
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final int shakeCount;

  const ShakeWidget({super.key, required this.child, this.shakeCount = 0});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeCount != oldWidget.shakeCount && widget.shakeCount > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final sineValue =
            sin(4 * pi * _controller.value) * 8 * (1 - _controller.value);
        return Transform.translate(offset: Offset(sineValue, 0), child: child);
      },
      child: widget.child,
    );
  }
}

/// Full-screen red flash overlay for failure feedback
class RedFlashOverlay extends StatefulWidget {
  final int triggerCount;

  const RedFlashOverlay({super.key, this.triggerCount = 0});

  @override
  State<RedFlashOverlay> createState() => _RedFlashOverlayState();
}

class _RedFlashOverlayState extends State<RedFlashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(RedFlashOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerCount != oldWidget.triggerCount &&
        widget.triggerCount > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = (1 - _controller.value) * 0.15;
        if (opacity <= 0) return const SizedBox.shrink();
        return Positioned.fill(
          child: IgnorePointer(
            child: Container(color: Colors.red.withValues(alpha: opacity)),
          ),
        );
      },
    );
  }
}

/// Radiating glow pulse for success feedback
class GlowPulse extends StatefulWidget {
  final Color color;
  final int triggerCount;
  final double size;

  const GlowPulse({
    super.key,
    required this.color,
    this.triggerCount = 0,
    this.size = 60,
  });

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(GlowPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerCount != oldWidget.triggerCount &&
        widget.triggerCount > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (!_controller.isAnimating && _controller.value == 0) {
          return const SizedBox.shrink();
        }
        final scale = 1.0 + _controller.value * 1.5;
        final opacity = (1 - _controller.value) * 0.4;
        return IgnorePointer(
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: opacity),
              ),
            ),
          ),
        );
      },
    );
  }
}
