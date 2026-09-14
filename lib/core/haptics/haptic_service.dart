import 'package:flutter/services.dart';

/// Service gérant les retours haptiques tactiles (Game Feel)
class HapticService {
  static bool isEnabled = true;

  /// Vibration légère au ramassage d'un bloc
  static void onPiecePick() {
    if (!isEnabled) return;
    HapticFeedback.selectionClick();
  }

  /// Clic net au dépôt valide d'un bloc
  static void onPieceDrop() {
    if (!isEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Impact lors de la destruction d'une ou plusieurs lignes
  static void onLineClear({int lineCount = 1}) {
    if (!isEnabled) return;
    if (lineCount >= 3) {
      HapticFeedback.heavyImpact();
    } else if (lineCount == 2) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  /// Impact puissant pour les combos élevés (x3, x4, etc.)
  static void onComboBlast() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Vibration d'échec / Game Over
  static void onGameOver() {
    if (!isEnabled) return;
    HapticFeedback.vibrate();
  }
}
