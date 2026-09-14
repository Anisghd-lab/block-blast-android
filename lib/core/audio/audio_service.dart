import 'package:flutter/services.dart';

/// Service gérant les effets sonores et la gamme musicale des combos
class AudioService {
  static bool isEnabled = true;

  // Fréquences en Hertz de la gamme majeure pour la montée en puissance des combos
  static const List<double> comboNotes = [
    261.63, // C4 (Do) - Combo 1
    293.66, // D4 (Ré) - Combo 2
    329.63, // E4 (Mi) - Combo 3
    349.23, // F4 (Fa) - Combo 4
    392.00, // G4 (Sol) - Combo 5
    440.00, // A4 (La) - Combo 6
    493.88, // B4 (Si) - Combo 7
    523.25, // C5 (Do aigu) - Combo 8+
  ];

  static void playPiecePlace() {
    if (!isEnabled) return;
    SystemSound.play(SystemSoundType.click);
  }

  static void playLineClear(int comboStreak) {
    if (!isEnabled) return;
    SystemSound.play(SystemSoundType.click);
  }

  static void playGameOver() {
    if (!isEnabled) return;
    SystemSound.play(SystemSoundType.alert);
  }
}
