import 'package:flutter/material.dart';
import '../main.dart';
import 'package:swipe_clean/app_colors.dart';
import '../services/storage_service.dart';

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

  @override
  void initState() {
    super.initState();
    // On charge le paramètre stocké en mémoire dès l'ouverture de la page
    _loadVibrationSetting();
  }

  Future<void> _loadVibrationSetting() async {
    bool isEnabled = await StorageService().getVibrationEnabled();
    if (mounted) {
      setState(() {
        _vibrationEnabled = isEnabled;
      });
    }
  }

  // Méthodes
  //Quand le swith passe à ON il envoit true
  void toggleTheme(bool isDark) {
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
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
          const SizedBox(height: 20),

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
            trailing: Switch(
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
        ],
      ),
    );
  }
}
