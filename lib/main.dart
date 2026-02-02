import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'app_colors.dart';

// Variable global pour le thème
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute ThemeMode
    return ValueListenableBuilder<ThemeMode>(
      // On écoute cette variable
      valueListenable: themeNotifier,
      // Le builder permet de construire dès que la variable écoutée bouge
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Swipe Clean',

          themeMode: currentMode,
          // Paramètres pour le thème clair
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.textWhite,
            primaryColor: AppColors.main,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.main,
              foregroundColor: AppColors.textWhite,
            ),
          ),

          // Paramètres pour le thème dark
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.backgroundDark,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.main,
              foregroundColor: AppColors.textWhite,
            ),
          ),

          home: const HomePage(),
        );
      },
    );
  }
}
