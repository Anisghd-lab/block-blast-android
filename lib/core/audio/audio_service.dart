import 'package:flutter/services.dart';

/// Service gérant les effets sonores, la gamme musicale des combos et les jingles du jeu (Sugar Delight Audio Engine)
class AudioService {
  static const MethodChannel _channel = MethodChannel('com.playgames.blockblast/audio');
  static bool isEnabled = true;

  // Fréquences en Hertz de la gamme majeure pour la montée en puissance des combos (Do, Ré, Mi, Fa, Sol, La, Si, Do)
  static const List<double> comboNotes = [
    261.63, // C4 (Do) - Combo 1
    293.66, // D4 (Ré) - Combo 2
    329.63, // E4 (Mi) - Combo 3
    349.23, // F4 (Fa) - Combo 4
    392.00, // G4 (Sol) - Combo 5
    440.00, // A4 (La) - Combo 6
    493.88, // B4 (Si) - Combo 7
    523.25, // C5 (Do aigu) - Combo 8+
    587.33, // D5 (Ré aigu) - Combo 9
    659.25, // E5 (Mi aigu) - Combo 10+
  ];

  /// Joue le son léger de saisie d'une pièce
  static Future<void> playPiecePick() async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('playPop');
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Joue le son de pose d'une pièce dans la grille
  static Future<void> playPiecePlace() async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('playDrop');
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Joue la note ascendante de la gamme musicale selon la série de combos (Style Sugar Delight)
  static Future<void> playLineClear(int comboStreak) async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('playCombo', {'streak': comboStreak});
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Joue l'accord de fanfare triomphale pour les combos élevés (x3, x4+)
  static Future<void> playComboBlast() async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('playBlast');
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Joue le son d'écrasement sucré du Marteau Sucré
  static Future<void> playHammerSmash() async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('playHammer');
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Joue la détonation gazeuse de la Bombe Soda
  static Future<void> playBombExplosion() async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('playBomb');
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Joue la fanfare de victoire de niveau (3 étoiles)
  static Future<void> playLevelVictory() async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('playVictory');
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Joue le jingle de fin de partie / défaite
  static Future<void> playGameOver() async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('playDefeat');
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Joue le tintement cristallin de pièces d'or
  static Future<void> playCoinReward() async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('playCoin');
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Joue le cliquetis de la roue de la fortune
  static Future<void> playWheelTick() async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('playPop');
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
