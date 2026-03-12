import 'package:flutter/material.dart';
import '../main.dart';
import 'package:swipe_clean/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// Class state car on a besoin de setState pour l'animation du bouton
class _SettingsPageState extends State<SettingsPage> {
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
          'Paramètres',
          style: TextStyle(color: AppColors.text(context)),
        ),
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        iconTheme: IconThemeData(color: AppColors.text(context)),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 30.0, right: 30.0),
            leading: const Icon(Icons.dark_mode),
            title: const Text("Mode Sombre"),
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
        ],
      ),
    );
  }
}
