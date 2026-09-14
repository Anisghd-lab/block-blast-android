import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_provider.dart';

class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;

  const PauseDialog({
    Key? key,
    required this.onResume,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PARTIE EN PAUSE',
              style: TextStyle(
                fontFamily: 'Rubik',
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),

            const SizedBox(height: 24),

            // Toggles Son et Vibration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSettingToggle(
                  icon: settingsProvider.soundEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  label: 'Sons',
                  isActive: settingsProvider.soundEnabled,
                  onTap: () => settingsProvider.toggleSound(),
                ),
                _buildSettingToggle(
                  icon: settingsProvider.hapticsEnabled
                      ? Icons.vibration_rounded
                      : Icons.smartphone_rounded,
                  label: 'Vibration',
                  isActive: settingsProvider.hapticsEnabled,
                  onTap: () => settingsProvider.toggleHaptics(),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Bouton Reprendre
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F2FE),
                  foregroundColor: const Color(0xFF00373A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onResume,
                child: const Text(
                  'REPRENDRE',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bouton Recommencer
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onRestart,
                child: const Text(
                  'RECOMMENCER',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceElevated : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFF00F2FE) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF00F2FE) : AppColors.textMuted,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                color: isActive ? Colors.white : AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
