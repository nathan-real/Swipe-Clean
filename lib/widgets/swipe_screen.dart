import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:swipe_clean/services/storage_service.dart';
import '../app_colors.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../services/gallery_service.dart';

class SwipeScreen extends StatefulWidget {
  final Function(AssetEntity) onTrashPhoto;
  final Function(AssetEntity) onRemoveFromTrash;
  final String sortMode;

  const SwipeScreen({
    super.key,
    required this.onTrashPhoto,
    required this.onRemoveFromTrash,
    required this.sortMode,
  });

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final CardSwiperController controller = CardSwiperController();

  // On instancie notre service de photo
  final GalleryService _galleryService = GalleryService();

  List<AssetEntity> _images = [];
  //La liste de référence toujours triée
  List<AssetEntity> _chronologicalImages = [];
  bool _isLoading = true;

  int _currentCardIndex = 0;
  @override
  // On load les photos à l'initialisation
  void initState() {
    super.initState();
    _loadPhotos();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SwipeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // On vérifie si le mode de tri a changé par rapport à avant
    if (oldWidget.sortMode != widget.sortMode) {
      _applySorting();
    }
  }

  // Fonction qui applique ou non le filtre aléatoire
  void _applySorting() {
    setState(() {
      if (widget.sortMode == 'random') {
        // Mélange la liste au hasard
        _images.shuffle();
      } else {
        // Trie par date de création (du plus récent au plus ancien)
        _images.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
      }
    });
  }

  Future<void> _loadPhotos() async {
    // On appelle notre service.
    // On donnera le mois et l'année plus tard ici
    final photos = await _galleryService.getImages(limit: 5000);
    final trashedIds = await StorageService().getTrashList();
    // On filtre en cherchant si parmis tous les ids des photos on supprimes celles qui sont aussi dans la corbeille
    final filteredPhotos = photos.where((photo) {
      return !trashedIds.contains(photo.id);
    }).toList();

    setState(() {
      _chronologicalImages = List.from(
        filteredPhotos,
      ); // Copie exacte pour la référence
      _images = filteredPhotos;
      _isLoading = false;
    });
    _applySorting();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_images.isEmpty) {
      return const Center(
        child: Text("Aucune photo trouvée ou permission refusée"),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CardSwiper(
                controller: controller,
                cardsCount: _images.length,
                numberOfCardsDisplayed: 2,
                allowedSwipeDirection: const AllowedSwipeDirection.all(),

                onSwipe: (previousIndex, currentIndex, direction) {
                  // CAS 1 : L'utilisateur essaie de swiper en haut ou en bas
                  if (direction == CardSwiperDirection.top ||
                      direction == CardSwiperDirection.bottom) {
                    return false;
                  }

                  // On met à jour l'index de la carte actuelle dans la variable globale
                  if (currentIndex != null) {
                    setState(() {
                      _currentCardIndex = currentIndex;
                    });
                  }

                  // CAS 2 : L'utilisateur swipe à droite
                  if (direction == CardSwiperDirection.right) {
                    return true;
                  }
                  // CAS 3 : L'utilisateur swipe à gauche
                  else if (direction == CardSwiperDirection.left) {
                    widget.onTrashPhoto(_images[previousIndex]);
                    return true;
                  }

                  return false;
                },

                onUndo:
                    (
                      int? previousIndex,
                      int currentIndex,
                      CardSwiperDirection direction,
                    ) {
                      // Si la carte précédente avait été glissée à gauche (vers la corbeille)
                      if (direction == CardSwiperDirection.left) {
                        // On la retire de la liste de la corbeille
                        widget.onRemoveFromTrash(_images[currentIndex]);
                      }

                      // On met aussi à jour l'index de la carte actuelle
                      setState(() {
                        _currentCardIndex = currentIndex;
                      });
                      return true; // On autorise l'animation de retour
                    },
                cardBuilder: (context, index, x, y) {
                  final double dragPourcentage =
                      x / (MediaQuery.of(context).size.width);
                  // On utilise un clamp à 1.0 au max pour éviter les erreurs
                  final double opacity = dragPourcentage.abs().clamp(0.0, 0.6);

                  Color overlayColor = const Color.fromARGB(0, 255, 255, 255);

                  if (dragPourcentage > 0) {
                    overlayColor = Colors.green;
                  } else if (dragPourcentage < 0) {
                    overlayColor = Colors.red;
                  }

                  return Container(
                    // Boite qui fait l'ombre
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                          spreadRadius: 1,
                        ),
                      ],
                    ),

                    // Carte en elle même
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: AppColors.main),

                          // La photo
                          AssetEntityImage(
                            _images[index],
                            isOriginal: false,
                            thumbnailSize: const ThumbnailSize.square(1024),

                            fit: BoxFit.contain,
                          ),

                          Container(
                            // Calque pour afficher de la couleur au desssus
                            color: overlayColor.withValues(alpha: opacity),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Les bouttons de control
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "btn_trash",
                    onPressed: () => controller.swipe(CardSwiperDirection.left),
                    backgroundColor: Colors.red,
                    shape: CircleBorder(),
                    child: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: "btn_undo",
                    onPressed: controller.undo,
                    backgroundColor: Colors.grey,
                    shape: CircleBorder(),
                    child: const Icon(Icons.undo, color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: "btn_keep",
                    onPressed: () =>
                        controller.swipe(CardSwiperDirection.right),
                    backgroundColor: Colors.green,
                    shape: CircleBorder(),
                    child: const Icon(Icons.check_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),

            if (_currentCardIndex < _images.length)
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Builder(
                  builder: (context) {
                    // On prend la photo affichée en grand
                    final currentPhoto = _images[_currentCardIndex];

                    // On cherche sa vraie place dans la liste chronologique
                    final chronoIndex = _chronologicalImages.indexOf(
                      currentPhoto,
                    );

                    // On prépare les voisines (null si on est au tout début ou à la toute fin)
                    AssetEntity? nextPhoto = (chronoIndex > 0)
                        ? _chronologicalImages[chronoIndex - 1]
                        : null;

                    AssetEntity? previousPhoto =
                        (chronoIndex < _chronologicalImages.length - 1)
                        ? _chronologicalImages[chronoIndex + 1]
                        : null;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // On demande à la ligne d'aligner ses éléments par le haut
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // On passe la variable directement, la fonction gèrera si elle est 'null'
                        _buildMiniImage(previousPhoto, "Image suivante"),

                        const SizedBox(width: 30),
                        _buildMiniImage(nextPhoto, "Image précédente"),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget d'affichage des deux images en bas
// On ajoute le "?" à AssetEntity pour accepter les valeurs nulles
Widget _buildMiniImage(AssetEntity? photo, String text) {
  return SizedBox(
    width: 110, // On fixe la largeur totale pour donner de la place au texte
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (photo != null)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AssetEntityImage(
                photo,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(200),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          const SizedBox(width: 70, height: 70),

        const SizedBox(height: 7),

        Text(
          text,
          textAlign: TextAlign.center, // On centre le texte sous l'image
          style: const TextStyle(
            fontSize: 12, // Un texte un peu plus petit
            color: Colors.grey, // Pour que ça ressemble à un indicateur
          ),
        ),
      ],
    ),
  );
}
