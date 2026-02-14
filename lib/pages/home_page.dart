import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swipe_clean/app_colors.dart';

// Widgets
import '../widgets/custom_nav_bar.dart';

// Pages
import 'gallery_page.dart';
import 'main_folders.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index de la page qu'on veut afficher
  int _currentIndex = 0;

  // La liste des pages qu'on va charger au début
  // Late car c'est une promesse
  late PageController _pageController;

  final List<Widget> _pages = [
    const MainFolders(), // Page 0
    const GalleryPage(), // Page 1
    const SettingsPage(), // Page 2
  ];

  @override
  void initState() {
    super.initState();
    // On initialise le contrôleur sur la page 0 au démarrage
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    // On détruit le contrôleur quand on quitte la page pour libérer la mémoire
    _pageController.dispose();
    super.dispose();
  }

  // Fonction pour changer de page quand on clique en bas dans la navigation bar
  void _onItemTapped(int index) {
    final isNeighbor = (index - _currentIndex).abs() == 1;

    setState(() {
      _currentIndex = index;
    });

    if (isNeighbor) {
      // Si c'est juste à côté on fait l'animation fluide
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // Si c'est loin, on téléporte pour éviter le bug de la page du milieu
      _pageController.jumpToPage(index);
    }
  }

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

      body: Stack(
        // Stack pour empiler des éléments
        children: [
          // COUCHE 1 : Les Pages
          // On met PageView en premier pour qu'il soit au fond
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: _pages,
          ),

          // COUCHE 2 : La nav bar
          // On lui passe la foncitionn pour passer d'une page à l'autre
          CustomNavBar(currentIndex: _currentIndex, onTap: _onItemTapped),
        ],
      ),
    );
  }
}
