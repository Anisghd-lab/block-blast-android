import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/storage/game_storage.dart';
import 'core/theme/app_colors.dart';
import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialisation du stockage hors ligne
  await GameStorage.init();

  // 2. Verrouillage en mode portrait (optimisé pour le jeu à une main)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 3. Configuration Edge-to-Edge conforme aux standards Android 15
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BlockBlastApp());
}

class BlockBlastApp extends StatelessWidget {
  const BlockBlastApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Block Blast Color',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: settings.currentTheme.backgroundColor,
              textTheme: GoogleFonts.rubikTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme,
              ),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00F2FE),
                surface: AppColors.surfaceContainer,
              ),
              useMaterial3: true,
            ),
            home: const GameScreen(),
          );
        },
      ),
    );
  }
}
