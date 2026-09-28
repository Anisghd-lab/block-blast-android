import 'package:flutter/services.dart';

/// Service gérant les retours haptiques tactiles (Game Feel pour Android)
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

  /// Clic lors de la rotation ou miroir d'une pièce
  static void onPieceRotate() {
    if (!isEnabled) return;
    HapticFeedback.selectionClick();
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

  /// Impact puissant pour les séries de combos (x2, x3, x4+)
  static void onComboBlast() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Vibration percutante lors de l'écrasement au Marteau Sucré
  static void onHammerSmash() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Double vibration explosive pour la Bombe Soda
  static void onBombExplosion() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 90), () {
      if (isEnabled) HapticFeedback.mediumImpact();
    });
  }

  /// Pulsation victorieuse lors de la réussite d'un niveau
  static void onLevelVictory() {
    if (!isEnabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 140), () {
      if (isEnabled) HapticFeedback.heavyImpact();
    });
  }

  /// Vibration continue d'échec / Game Over
  static void onGameOver() {
    if (!isEnabled) return;
    HapticFeedback.vibrate();
  }

  /// Clic lors du défilement de la Roue de la Fortune
  static void onWheelTick() {
    if (!isEnabled) return;
    HapticFeedback.selectionClick();
  }

  /// Impact lors de l'obtention d'un lot à la Roue
  static void onWheelReward() {
    if (!isEnabled) return;
    HapticFeedback.mediumImpact();
  }
}
