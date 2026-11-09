import 'package:flutter/material.dart';
import '../main.dart';
import 'package:swipe_clean/app_colors.dart';
import '../services/storage_service.dart';
import '../utils/format_utils.dart';

//Langue
import '../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// Class state car on a besoin de setState pour l'animation du bouton
class _SettingsPageState extends State<SettingsPage> {
  bool _vibrationEnabled = true;
  bool _isLoading = true;

  // Variable pour l'espace libéré
  int _savedSpaceBytes = 0;

  @override
  void initState() {
    super.initState();
    // On charge le paramètre stocké en mémoire dès l'ouverture de la page
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    bool isEnabled = await StorageService().getVibrationEnabled();
    int savedSpace = await StorageService()
        .getSavedSpace(); // On lit l'espace sauvé
    if (mounted) {
      setState(() {
        _vibrationEnabled = isEnabled;
        _savedSpaceBytes = savedSpace;
        _isLoading = false;
      });
    }
  }

  //Quand le swith passe à ON il envoit true
  void toggleTheme(bool isDark) {
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    StorageService().saveThemeMode(isDark);
  }

  // Langues disponibles, écrites dans leur propre langue
  static const Map<String, String> _languageNames = {
    'de': 'Deutsch',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'hi': 'हिन्दी',
    'it': 'Italiano',
    'ru': 'Русский',
    'uk': 'Українська',
  };

  // Change la langue de l'application (null = langue du système)
  void _changeLanguage(String? languageCode) {
    localeNotifier.value = languageCode != null ? Locale(languageCode) : null;
    StorageService().saveLanguage(languageCode);
  }

  // Boîte de dialogue pour choisir la langue
  void _showLanguageDialog(BuildContext context) {
    final String? currentCode = localeNotifier.value?.languageCode;

    // Une ligne de la liste, avec une coche si c'est la langue actuelle
    Widget buildOption(String? code, String label) {
      return ListTile(
        title: Text(label, style: TextStyle(color: AppColors.text(context))),
        trailing: currentCode == code
            ? const Icon(Icons.check_rounded, color: AppColors.main)
            : null,
        onTap: () {
          Navigator.pop(context);
          _changeLanguage(code);
        },
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundNavBar(context),
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context)!.language,
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              buildOption(null, AppLocalizations.of(context)!.systemLanguage),
              for (final entry in _languageNames.entries)
                buildOption(entry.key, entry.value),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final bool isCurrentlyDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(color: AppColors.text(context)),
        ),
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        iconTheme: IconThemeData(color: AppColors.text(context)),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Carte qui indique la place libérée
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.main,
                  AppColors.main.withValues(alpha: 0.55),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.main.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 20),
                // Textes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.spaceSaved,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Affichage dynamique de la taille
                      _isLoading
                          ? const SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              formatBytes(_savedSpaceBytes),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Switch du thème
          ListTile(
            contentPadding: const EdgeInsets.only(left: 30.0, right: 30.0),
            leading: const Icon(Icons.dark_mode),
            title: Text(AppLocalizations.of(context)!.darkmode),
            trailing: Switch(
              // Valeur du switch quand on rentre dans la page
              value: isCurrentlyDark,
              //Quand le swith passe à ON il envoit true
              onChanged: (val) {
                toggleTheme(val);
                // On relance le build pour afficher les modifs, donc pas de fonction à mettre
                setState(() {});
              },
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.main,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
            ),
          ),

          // Switch Vibration
          ListTile(
            contentPadding: const EdgeInsets.only(left: 30.0, right: 30.0),
            leading: const Icon(Icons.vibration_rounded),
            title: Text(AppLocalizations.of(context)!.vibrationSetting),
            trailing: _isLoading
                ? const SizedBox(width: 60, height: 40)
                : Switch(
                    value: _vibrationEnabled,
                    onChanged: (val) async {
                      // 1. On sauvegarde le choix en mémoire
                      await StorageService().setVibrationEnabled(val);

                      // 2. On met à jour l'interface
                      setState(() {
                        _vibrationEnabled = val;
                      });
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.main,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                  ),
          ),

          // Choix de la langue
          ListTile(
            contentPadding: const EdgeInsets.only(left: 30.0, right: 30.0),
            leading: const Icon(Icons.language_rounded),
            title: Text(AppLocalizations.of(context)!.language),
            subtitle: Text(
              localeNotifier.value == null
                  ? AppLocalizations.of(context)!.systemLanguage
                  : _languageNames[localeNotifier.value!.languageCode] ?? '',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showLanguageDialog(context),
          ),
        ],
      ),
    );
  }
}
