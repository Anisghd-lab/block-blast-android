import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage/game_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/game_theme.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    final theme = settingsProvider.currentTheme;
    final isCandy = theme.mode == GameThemeMode.sugarDelight;
    final titleColor = isCandy ? const Color(0xFF1E3A8A) : Colors.white;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PARAMÈTRES & THÈMES',
          style: TextStyle(
            fontFamily: 'Rubik',
            color: titleColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Thèmes Visuels
            _buildSectionTitle('THÈMES VISUELS', isCandy),
            const SizedBox(height: 12),
            ...GameThemeMode.values.map((mode) {
              final themeOption = GameTheme.fromMode(mode);
              final isSelected = settingsProvider.currentTheme.mode == mode;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => settingsProvider.setTheme(mode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isCandy ? Colors.white : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isCandy ? const Color(0xFF2563EB) : const Color(0xFF00F2FE))
                            : (isCandy ? CandyColors.hudCardBorder : Colors.white10),
                        width: isSelected ? 2.2 : 1.0,
                      ),
                      boxShadow: isCandy
                          ? const [
                              BoxShadow(
                                color: Color(0x15000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Pastilles des couleurs du thème
                        Row(
                          children: themeOption.blockColors.take(4).map((c) {
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          themeOption.displayName,
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            color: isSelected ? const Color(0xFF00F2FE) : Colors.white,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF00F2FE),
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Section 2: Audio & Haptiques
            _buildSectionTitle('AUDIO & VIBRATIONS', isCandy),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isCandy ? Colors.white : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCandy ? CandyColors.hudCardBorder : Colors.white10,
                ),
                boxShadow: isCandy
                    ? const [
                        BoxShadow(
                          color: Color(0x15000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  _buildToggleRow(
                    'Effets Sonores (SFX)',
                    '🔊',
                    settingsProvider.soundEnabled,
                    (_) => settingsProvider.toggleSound(),
                    isCandy,
                  ),
                  Divider(
                    color: isCandy ? const Color(0xFFE2E8F0) : Colors.white10,
                    height: 12,
                  ),
                  _buildToggleRow(
                    'Vibrations Haptiques',
                    '📳',
                    settingsProvider.hapticsEnabled,
                    (_) => settingsProvider.toggleHaptics(),
                    isCandy,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 3: Statistiques de Jeu
            _buildSectionTitle('VOS STATISTIQUES', isCandy),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildStatRow('Meilleur Score', '${GameStorage.getHighScore()}'),
                  const Divider(color: Colors.white10, height: 20),
                  _buildStatRow('Meilleure Série de Combos', 'x${GameStorage.getBestStreak()}'),
                  const Divider(color: Colors.white10, height: 20),
                  _buildStatRow('Lignes Détruites', '${GameStorage.getTotalLines()}'),
                  const Divider(color: Colors.white10, height: 20),
                  _buildStatRow('Parties Jouées', '${GameStorage.getGamesPlayed()}'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 3: Conformité & Règles Google Play
            _buildSectionTitle('CONFORMITÉ GOOGLE PLAY'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: Color(0xFF00F5A0), size: 20),
                      SizedBox(width: 8),
                      Text(
                        '100% Respect de la vie privée',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Jeu 100% hors-ligne. Aucune collecte de données personnelles, aucun traceur intrusif, conforme aux directives Familles & Sécurité des Données du Google Play Store.',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Version 1.0.0 (Target Android 15 / API 35 - 64 bits)',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, [bool isCandy = false]) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Space Grotesk',
        color: isCandy ? const Color(0xFF475569) : AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [bool isCandy = false]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            color: isCandy ? const Color(0xFF64748B) : Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Rubik',
            color: isCandy ? const Color(0xFF1E3A8A) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(
    String label,
    String icon,
    bool value,
    ValueChanged<bool> onChanged,
    bool isCandy,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: isCandy ? const Color(0xFF1E3A8A) : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: isCandy ? const Color(0xFF2563EB) : const Color(0xFF00F2FE),
          ),
        ],
      ),
    );
  }
}
