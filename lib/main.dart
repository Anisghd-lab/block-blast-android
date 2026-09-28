import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/storage/game_storage.dart';
import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialisation du stockage hors ligne (Highscore, Thème, Mode Sombre)
  await GameStorage.init();

  // 2. Verrouillage en mode portrait (optimisé pour le jeu à une main)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const BlockBlastApp());
}

class BlockBlastApp extends StatelessWidget {
  const BlockBlastApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final isDark = settings.isDarkMode;
          final currentTheme = settings.currentTheme;

          // Mise à jour de l'overlay système selon le mode Dark / Light
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
          );

          final lightThemeData = ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: currentTheme.backgroundColor,
            cardColor: currentTheme.cardColor,
            textTheme: GoogleFonts.rubikTextTheme(
              ThemeData(brightness: Brightness.light).textTheme,
            ).apply(
              bodyColor: currentTheme.textColor,
              displayColor: currentTheme.textColor,
            ),
            colorScheme: ColorScheme.light(
              primary: currentTheme.primaryAccent,
              secondary: currentTheme.secondaryAccent,
              surface: currentTheme.surfaceColor,
            ),
            useMaterial3: true,
          );

          final darkThemeData = ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: currentTheme.backgroundColor,
            cardColor: currentTheme.cardColor,
            textTheme: GoogleFonts.rubikTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ).apply(
              bodyColor: currentTheme.textColor,
              displayColor: currentTheme.textColor,
            ),
            colorScheme: ColorScheme.dark(
              primary: currentTheme.primaryAccent,
              secondary: currentTheme.secondaryAccent,
              surface: currentTheme.surfaceColor,
            ),
            useMaterial3: true,
          );

          return MaterialApp(
            title: 'Blockium - Block Quest',
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: lightThemeData,
            darkTheme: darkThemeData,
            home: AnimatedTheme(
              data: isDark ? darkThemeData : lightThemeData,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: const GameScreen(),
            ),
          );
        },
      ),
    );
  }
}
