import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.splashDurationMs),
    );
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Logo icon
            ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/images/quickplay_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            // App name
            Text(
                  AppConstants.appName,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 40,
                    letterSpacing: -1.5,
                  ),
                )
                .animate(delay: 200.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms),
            const SizedBox(height: 8),
            // Tagline
            Text(
              AppConstants.appTagline,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
            const Spacer(flex: 3),
            // Loading indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
            Text(
              'Initializing Experience',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
