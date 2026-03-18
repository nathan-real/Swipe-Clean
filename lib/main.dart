import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'app_colors.dart';
import 'package:flutter/services.dart';

// Variable global pour le thème
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // On impose les orientations autorisées
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    // On lance l'application uniquement une fois que le système a validé ce réglage
    runApp(const MyApp());
  });
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
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          // Paramètres pour le thème clair
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            primaryColor: AppColors.main,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.main,
              foregroundColor: Colors.black,
            ),
          ),

          // Paramètres pour le thème dark
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color.fromARGB(
              255,
              30,
              30,
              30,
            ), // Fond sombre
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.main,
              foregroundColor: Colors.white, // Texte de l'AppBar en blanc
            ),
          ),

          home: const HomePage(),
        );
      },
    );
  }
}
