import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/gradient_button.dart';

class DodgePreGame extends StatelessWidget {
  const DodgePreGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXXL),
          child: Column(
            children: [
              const Spacer(),
              ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/dodge_drop_logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(),
              const SizedBox(height: AppDimensions.gapXXL),
              Text(
                AppConstants.dodgeDrop,
                style: AppTextStyles.display,
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppDimensions.gapMD),
              Text(
                AppConstants.dodgeDropDesc,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: AppDimensions.gapXXL),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(color: AppColors.surfaceDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Controls', style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.gapMD),
                    _ControlRow(
                      icon: Icons.swipe,
                      text: 'Drag left/right to move',
                    ),
                    _ControlRow(
                      icon: Icons.speed,
                      text: 'Speed increases over time',
                    ),
                    _ControlRow(
                      icon: Icons.timer,
                      text: 'Survive as long as you can',
                    ),
                    _ControlRow(
                      icon: Icons.star,
                      text: 'Score 10 points per second',
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const Spacer(),
              GradientButton(
                text: 'Start Game',
                icon: Icons.play_arrow_rounded,
                gradient: AppColors.successGradient,
                onPressed: () => context.push('/game/dodge/play'),
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppDimensions.gapLG),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ControlRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.gapSM),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.success),
          const SizedBox(width: AppDimensions.gapMD),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
