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
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 Mo";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} Ko";
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo";
    }
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} Go";
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
                              _formatBytes(_savedSpaceBytes),
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
        ],
      ),
    );
  }
}
