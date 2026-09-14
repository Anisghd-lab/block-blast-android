# 🎮 Block Blast Color — Jeu Android Moderne & Conforme Google Play

> **Block Blast Color** est une adaptation moderne, ultra-fluide et addictive des jeux viraux de puzzle de blocs (genre *Block Blast!* / *Block Puzzle*) spécialement conçue pour **Android** selon les standards les plus récents du **Google Play Store (2025/2026)**.

---

## 🌟 Points Forts & Fluidité Maximale

1. **⚡ Performance 60 / 120 FPS (Zero Jank)** :
   - Développé avec **Flutter 3.x** compatible avec le moteur de rendu **Impeller** (accélération matérielle Vulkan).
   - Synchronisation avec les écrans 120 Hz des smartphones Android modernes.
   - Grille 8x8 optimisée sans lag tactile ni ralentissement lors des destructions de lignes.

2. **📱 Ergonomie Mobile Tactile "Finger Offset" (-75px)** :
   - Résolution du problème n°1 des jeux de puzzle mobiles : **le doigt ne cache plus la grille ni la pièce** !
   - La pièce en cours de glissement flotte **75 pixels au-dessus du point de contact tactile**.
   - Aperçu "fantôme" (*Ghost Shadow*) en temps réel avec surbrillance cyan (valide) ou rouge (bloqué).

3. **💥 Moteur de Combos & Dopamine Loop** :
   - **Multiplicateurs consécutifs** : enchaîner des destructions déclenche les multiplicateurs `x2`, `x3`, `x4`, `x5+`.
   - **Gamme musicale ascendante** : chaque coup de combo consécutif joue la note supérieure de la gamme (*Do, Ré, Mi, Fa, Sol, La, Si, Do aigu*).
   - **Retours haptiques Android** : micro-vibrations sur le ramassage, le dépôt et explosions haptiques puissantes sur les multi-lignes.
   - **Particules explosives** : gerbes d'étincelles colorées synchronisées avec la couleur des blocs détruits.

4. **🧠 Générateur Anti-Frustration (Smart Piece Generator)** :
   - Évite les "Game Over" injustes causés par le pur hasard.
   - Analyse l'espace libre sur la grille pour garantir qu'au moins 1 à 2 pièces du trio tiré soient immédiatement posables.

5. **🎨 4 Thèmes Visuels Interchangeables** :
   - **Néon Arcade** : Obscurité spatiale, cyan électrique, rose néon et jaune vibrant.
   - **Joyaux Célestes** : Saphir, rubis, émeraude et améthyste taillés.
   - **Bois Rustique** : Chêne, teck et noyer pour une ambiance chaleureuse et zen.
   - **Zen Pastel** : Tons doux pour des sessions de détente relaxantes.

---

## 🛡️ Conformité Totale aux Règles Google Play (2025/2026)

| Exigence Google Play | Implémentation dans le projet |
|---|---|
| **Target SDK 35 (Android 15)** | `compileSdk 35` et `targetSdk 35` configurés dans `build.gradle`. |
| **Support 64-bit obligatoire** | Filtres NDK `arm64-v8a` et `x86_64` activés. |
| **Format AAB (Android App Bundle)** | Prêt pour la commande `flutter build appbundle --release`. |
| **Mode Edge-to-Edge natif** | Activé via `WindowCompat.setDecorFitsSystemWindows` (requis Android 15). |
| **Politique Sécurité des données (Data Safety)** | **100% Hors-Ligne**. Zéro collecte de données personnelles, zéro traceur. |
| **Programme Familles & Enfants (PEGI 3)** | Éligible pour tous les âges (aucune permission invasive requise). |
| **Permissions minimales** | Uniquement `android.permission.VIBRATE` pour les retours haptiques. |
| **Icône Adaptative (Android 8 à 15)** | `ic_launcher` vectoriel avec calque d'arrière-plan et premier plan distincts. |

---

## 📂 Architecture du Code Source (`lib/`)

```
lib/
├── main.dart                      # Point d'entrée, initialisation Edge-to-Edge & Providers
├── core/
│   ├── theme/
│   │   ├── app_colors.dart        # Palette néon & dégradés 3D
│   │   └── game_theme.dart        # 4 Thèmes visuels (Néon, Joyaux, Bois, Pastel)
│   ├── audio/
│   │   └── audio_service.dart     # Sons et montée en gamme des combos
│   ├── haptics/
│   │   └── haptic_service.dart    # Moteur de vibration tactile Android
│   └── storage/
│       └── game_storage.dart      # Persistance locale (SharedPreferences)
├── engine/
│   ├── block_shape.dart           # Modèle des pièces polyominos
│   ├── shape_definitions.dart     # Catalogue des 28 formes classiques
│   ├── board_state.dart           # Matrice 8x8, détection des lignes pleines
│   ├── shape_generator.dart       # Algorithme de génération anti-frustration
│   └── score_calculator.dart      # Calcul des scores et bonus de combos
├── providers/
│   ├── game_provider.dart         # Gestion d'état réactive de la partie
│   └── settings_provider.dart     # Paramètres son, haptique et thème
└── ui/
    ├── screens/
    │   ├── game_screen.dart       # Écran principal de jeu
    │   └── settings_screen.dart   # Écran des thèmes et statistiques joueur
    └── widgets/
        ├── game_board.dart        # Grille 8x8 avec DragTarget tactile
        ├── board_cell.dart        # Rendu 3D glossy de chaque case
        ├── piece_dock.dart        # Tiroir des 3 pièces disponibles
        ├── draggable_piece.dart   # Pièce déplaçable avec décalage -75px
        ├── score_header.dart      # HUD supérieur (Score, Record, Pause)
        ├── combo_banner.dart      # Bannière animée des séries de combos
        └── dialogs/
            ├── game_over_dialog.dart # Modal fin de partie & record
            └── pause_dialog.dart     # Modal pause & réglages rapides
```

---

## 🚀 Comment Tester et Publier

### 1. Test Immédiat Jouable dans le Navigateur (Web Preview)
Un prototype HTML5 / Canvas autonome avec son Web Audio et toucher mobile est disponible dans `web_preview/index.html` :
```bash
# Lancer un serveur local léger :
npx serve -p 8080 /root/block_blast_android/web_preview
# Ou avec python :
python3 -m http.server 8080 --directory /root/block_blast_android/web_preview
```
Ouvrez ensuite `http://localhost:8080` sur votre navigateur mobile ou PC !

### 2. Tester l'Application Mobile Flutter
```bash
cd /root/block_blast_android
flutter pub get
flutter run
```

### 3. Générer le bundle pour le Google Play Store
Pour créer le fichier `.aab` prêt à être téléversé sur la Google Play Console :
```bash
flutter build appbundle --release
```
Le fichier généré se trouvera dans :  
`build/app/outputs/bundle/release/app-release.aab`
