import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'app_colors.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

//Langue
import 'l10n/app_localizations.dart';

// Variable global pour le thème
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Variable globale pour la langue (null = langue du système)
final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // On lit la préférence stockée
  bool isDark = await StorageService().getThemeMode();

  // On met à jour le notifier global AVANT de lancer l'app
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  // On lit la langue choisie par l'utilisateur (null = langue du système)
  final String? languageCode = await StorageService().getLanguage();
  localeNotifier.value = languageCode != null ? Locale(languageCode) : null;

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
        // On écoute aussi la langue choisie
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeNotifier,
          builder: (context, currentLocale, child) {
            return MaterialApp(
              title: 'Swipe Clean',
              // Langue forcée par l'utilisateur (null = langue du système)
              locale: currentLocale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              // Si la langue du téléphone n'est pas traduite, on affiche l'anglais
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                for (final locale in supportedLocales) {
                  if (locale.languageCode == deviceLocale?.languageCode) {
                    return locale;
                  }
                }
                return const Locale(
                  'en',
                ); // Langue non prise en charge → anglais
              },
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
      },
    );
  }
}
