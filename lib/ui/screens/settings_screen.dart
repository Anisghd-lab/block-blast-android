import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage/game_storage.dart';
import '../../core/theme/game_theme.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = settingsProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PARAMÈTRES & THÈMES',
          style: TextStyle(
            fontFamily: 'Rubik',
            color: theme.textColor,
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
            // Section 0: Apparence (Mode Sombre / Mode Clair)
            _buildSectionTitle('APPARENCE', theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: theme.isDark ? Colors.black26 : const Color(0x0C000000),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildToggleRow(
                settingsProvider.isDarkMode ? 'Mode Sombre' : 'Mode Clair',
                settingsProvider.isDarkMode ? '🌙' : '☀️',
                settingsProvider.isDarkMode,
                (_) => settingsProvider.toggleDarkMode(),
                theme,
              ),
            ),

            const SizedBox(height: 24),

            // Section 1: Thèmes Visuels
            _buildSectionTitle('THÈMES VISUELS', theme),
            const SizedBox(height: 12),
            ...GameThemeMode.values.map((mode) {
              final themeOption = GameTheme.getTheme(mode, isDark: settingsProvider.isDarkMode);
              final isSelected = settingsProvider.currentThemeMode == mode;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => settingsProvider.setTheme(mode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.cardColor : theme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.primaryAccent : theme.borderColor,
                        width: isSelected ? 2.2 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? theme.primaryAccent.withValues(alpha: 0.25)
                              : (theme.isDark ? Colors.black12 : const Color(0x08000000)),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Pastilles des couleurs du thème
                        Row(
                          children: themeOption.blockColors.take(5).map((c) {
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
                            color: isSelected ? theme.primaryAccent : theme.textColor,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: theme.primaryAccent,
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
            _buildSectionTitle('AUDIO & VIBRATIONS', theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: theme.isDark ? Colors.black26 : const Color(0x0C000000),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildToggleRow(
                    'Effets Sonores (SFX)',
                    '🔊',
                    settingsProvider.soundEnabled,
                    (_) => settingsProvider.toggleSound(),
                    theme,
                  ),
                  Divider(
                    color: theme.dividerColor,
                    height: 12,
                  ),
                  _buildToggleRow(
                    'Vibrations Haptiques',
                    '📳',
                    settingsProvider.hapticsEnabled,
                    (_) => settingsProvider.toggleHaptics(),
                    theme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 3: Statistiques de Jeu
            _buildSectionTitle('VOS STATISTIQUES', theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.borderColor),
              ),
              child: Column(
                children: [
                  _buildStatRow('Meilleur Score', '${GameStorage.getHighScore()}', theme),
                  Divider(color: theme.dividerColor, height: 20),
                  _buildStatRow('Meilleure Série de Combos', 'x${GameStorage.getBestStreak()}', theme),
                  Divider(color: theme.dividerColor, height: 20),
                  _buildStatRow('Lignes Détruites', '${GameStorage.getTotalLines()}', theme),
                  Divider(color: theme.dividerColor, height: 20),
                  _buildStatRow('Parties Jouées', '${GameStorage.getGamesPlayed()}', theme),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 4: Conformité & Règles Google Play
            _buildSectionTitle('CONFORMITÉ GOOGLE PLAY', theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: theme.successColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '100% Respect de la vie privée',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: theme.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jeu 100% hors-ligne. Aucune collecte de données personnelles, aucun traceur intrusif, conforme aux directives Familles & Sécurité des Données du Google Play Store.',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: theme.textMutedColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Version 1.0.0 (Target Android 15 / API 35 - 64 bits)',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: theme.textMutedColor.withValues(alpha: 0.6),
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

  Widget _buildSectionTitle(String title, GameTheme theme) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Space Grotesk',
        color: theme.textMutedColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildStatRow(String label, String value, GameTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            color: theme.textMutedColor,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Rubik',
            color: theme.textColor,
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
    GameTheme theme,
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
                  color: theme.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: theme.primaryAccent,
          ),
        ],
      ),
    );
  }
}
