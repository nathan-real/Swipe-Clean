import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../widgets/custom_header.dart';
import 'sort_page.dart';
import 'package:swipe_clean/app_colors.dart';

class MainFolders extends StatefulWidget {
  final Function(AssetEntity) onTrashPhoto;
  final Function(AssetEntity) onRemoveFromTrash;

  const MainFolders({
    super.key,
    required this.onTrashPhoto,
    required this.onRemoveFromTrash,
  });

  @override
  State<MainFolders> createState() => _MainFoldersState();
}

class _MainFoldersState extends State<MainFolders>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const SizedBox(height: 20),
        const CustomHeader(),
        const SizedBox(height: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    // PageRouteBuilder pour modifier l'animation
                    PageRouteBuilder(
                      // Quand on appuie sur le bouton on va afficher la page de trie et on passe la fonction de corbeille
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          SortPage(
                            onTrashPhoto: widget.onTrashPhoto,
                            onRemoveFromTrash: widget.onRemoveFromTrash,
                          ),

                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeOutCubic;
                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                child: const Text('Démarrer le tri'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
