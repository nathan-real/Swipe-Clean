import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swipe_clean/app_colors.dart';

// Pages
import 'gallery_page.dart';
import 'main_folders.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index de la page qu'on veut afficher
  final int _currentIndex = 0;

  // La liste des pages qu'on va charger au début
  final List<Widget> _Pages = [
    const MainFolders(), // Index 0
    const GalleryPage(), // Index 1
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.main,
        toolbarHeight: 0, // Hauteur 0 : pour juste avoir la statue bar
        elevation: 0, // Pas d'ombre
        systemOverlayStyle: SystemUiOverlayStyle
            .light, // Pour mettre les icones de la barre en blanc
      ),

      body: IndexedStack(index: _currentIndex, children: _Pages),
    );
  }
}
