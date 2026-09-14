## Règles R8 / ProGuard pour optimiser et sécuriser l'application pour Google Play
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Ne pas obfusquer les modèles JSON et SharedPreferences
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-dontwarn io.flutter.embedding.**
