import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/game_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        children: [
          // Player name
          _SettingsSection(
            title: 'Profile',
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Player Name'),
                subtitle: Text(provider.playerName),
                trailing: const Icon(Icons.edit_outlined, size: 20),
                onTap: () => _showNameDialog(context, provider),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
          const SizedBox(height: AppDimensions.gapLG),

          // Preferences
          _SettingsSection(
                title: 'Preferences',
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up_outlined),
                    title: const Text('Sound Effects'),
                    subtitle: const Text('Game sounds and alerts'),
                    value: provider.soundEnabled,
                    onChanged: (_) => provider.toggleSound(),
                    activeTrackColor: AppColors.primary,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration_outlined),
                    title: const Text('Haptic Feedback'),
                    subtitle: const Text('Vibration on interactions'),
                    value: provider.hapticsEnabled,
                    onChanged: (_) => provider.toggleHaptics(),
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              )
              .animate(delay: 100.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, end: 0),
          const SizedBox(height: AppDimensions.gapLG),

          // About
          _SettingsSection(
                title: 'About',
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Version'),
                    subtitle: Text('0.1.0'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.code),
                    title: Text('Built with'),
                    subtitle: Text('Flutter & Dart'),
                  ),
                ],
              )
              .animate(delay: 200.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, end: 0),
        ],
      ),
    );
  }

  void _showNameDialog(BuildContext context, GameProvider provider) {
    final controller = TextEditingController(text: provider.playerName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.updatePlayerName(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: AppDimensions.gapSM),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: AppColors.surfaceDark),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}
