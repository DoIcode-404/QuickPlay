import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/gradient_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXXL),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'assets/images/quickplay_logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              ),
              const SizedBox(height: AppDimensions.gapXXL),
              // Title
              Text(
                    'Welcome to\n${AppConstants.appName}',
                    style: AppTextStyles.display,
                    textAlign: TextAlign.center,
                  )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppDimensions.gapMD),
              Text(
                'Discover a world of instant fun.\nPlay hundreds of games instantly.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
              const Spacer(flex: 2),
              // Google Sign In
              GradientButton(
                    text: 'Continue with Google',
                    icon: Icons.login_rounded,
                    onPressed: () => context.go('/home'),
                  )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppDimensions.gapMD),
              // Play offline
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Play Offline'),
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: AppDimensions.gapLG),
              Text(
                'Offline games work without login.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: AppDimensions.gapLG),
            ],
          ),
        ),
      ),
    );
  }
}
