import 'package:flutter/material.dart';

class AppColors {
  // Les couleurs qui restent identiques peu importe le thème
  static const Color main = Color.fromARGB(255, 51, 59, 150);

  // Les couleurs dynamiques
  // Nav Bar
  static Color backgroundNavBar(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 50, 50, 50)
        : const Color.fromARGB(255, 240, 240, 240);
  }

  // Le texte principal
  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors
              .white // Texte blanc sur fond sombre
        : Colors.black; // Texte noir sur fond clair
  }

  // Pillule main folders
  static Color pills(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 20, 20, 20)
        : const Color.fromARGB(255, 229, 229, 229);
  }
}
