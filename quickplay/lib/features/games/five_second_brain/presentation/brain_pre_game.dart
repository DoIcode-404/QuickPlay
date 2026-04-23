import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/gradient_button.dart';

class BrainPreGame extends StatelessWidget {
  const BrainPreGame({super.key});

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
                      'assets/images/five_second_brain_logo.png',
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
                AppConstants.fiveSecondBrain,
                style: AppTextStyles.display,
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppDimensions.gapMD),
              Text(
                AppConstants.fiveSecondBrainDesc,
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
                    Text('Rules', style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.gapMD),
                    _RuleRow(icon: Icons.timer, text: '5 seconds per question'),
                    _RuleRow(
                      icon: Icons.star,
                      text: '100 points per correct answer',
                    ),
                    _RuleRow(
                      icon: Icons.local_fire_department,
                      text: 'Streak bonus: +50 per streak',
                    ),
                    _RuleRow(
                      icon: Icons.heart_broken,
                      text: '3 lives — game ends at 0',
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const Spacer(),
              GradientButton(
                text: 'Start Game',
                icon: Icons.play_arrow_rounded,
                gradient: const LinearGradient(
                  colors: [AppColors.xpPurple, Color(0xFFa78bfa)],
                ),
                onPressed: () => context.push('/game/brain/play'),
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppDimensions.gapLG),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RuleRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.gapSM),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.xpPurple),
          const SizedBox(width: AppDimensions.gapMD),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
