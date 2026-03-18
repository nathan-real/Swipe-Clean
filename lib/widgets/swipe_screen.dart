import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:swipe_clean/services/storage_service.dart';
import '../app_colors.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../widgets/mini_image_preview.dart';

class SwipeScreen extends StatefulWidget {
  final Function(AssetEntity) onTrashPhoto;
  final Function(AssetEntity) onRemoveFromTrash;
  final String sortMode;

  final List<AssetEntity> photos;

  const SwipeScreen({
    super.key,
    required this.onTrashPhoto,
    required this.onRemoveFromTrash,
    required this.sortMode,
    required this.photos,
  });

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final CardSwiperController controller = CardSwiperController();

  // On instancie notre service de photo

  List<AssetEntity> _images = [];
  //La liste de référence toujours triée
  List<AssetEntity> _chronologicalImages = [];
  bool _isLoading = true;

  int _currentCardIndex = 0;

  //Garde en mémoire les ID des photos supprimées pendant la session
  final Set<String> _trashedInSession = {};
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

  // Fonction qui charge les photos
  Future<void> _loadPhotos() async {
    final trashedIds = await StorageService().getTrashList();
    // On filtre en cherchant si parmis tous les ids des photos on supprimes celles qui sont aussi dans la corbeille
    final filteredPhotos = widget.photos.where((photo) {
      return !trashedIds.contains(photo.id);
    }).toList();

    setState(() {
      _chronologicalImages = List.from(filteredPhotos)
        ..sort((a, b) => a.createDateTime.compareTo(b.createDateTime));
      // Copie exacte pour la référence
      _images = List.from(filteredPhotos);
      _isLoading = false;
    });
    _applySorting();
  }

  // Fonction appelée depuis la pop-up pour mettre à la corbeille
  void _sendPhotoToTrash(AssetEntity photo) {
    // Ici on met vraiment la photo dans la corbeille
    widget.onTrashPhoto(photo);

    // On l'ajoute à notre mémoire locale pour que l'interface s'adapte
    setState(() {
      _trashedInSession.add(photo.id);

      // On cherche la photo dans la liste du swiper
      int targetIndex = _images.indexOf(photo);

      // Si la photo est "dans le futur", on la supprime de la liste. Le swiper la sautera automatiquement
      if (targetIndex != -1 && targetIndex > _currentCardIndex) {
        _images.removeAt(targetIndex);
      }
    });
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
                isLoop: false,
                controller: controller,
                cardsCount: _images.length,
                numberOfCardsDisplayed: _images.length > 1 ? 2 : 1,
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
                    // On enregistre dans la session qu'elle est supprimée
                    setState(
                      () => _trashedInSession.add(_images[previousIndex].id),
                    );
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
                  final photo = _images[index];
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
                            photo,
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
                    final currentPhoto = _images[_currentCardIndex];

                    //On crée une liste qui exclut les photos supprimées dans la session
                    final validChronoImages = _chronologicalImages
                        .where((img) => !_trashedInSession.contains(img.id))
                        .toList();

                    // On cherche la position de la photo actuelle dans cette liste propre
                    final chronoIndex = validChronoImages.indexWhere(
                      (img) => img.id == currentPhoto.id,
                    );

                    AssetEntity? nextPhoto;
                    AssetEntity? previousPhoto;

                    //On prend les voisines
                    if (chronoIndex != -1) {
                      // S'il y a des photos avant dans la liste (donc plus récentes)
                      if (chronoIndex > 0) {
                        previousPhoto = validChronoImages[chronoIndex - 1];
                      }

                      // S'il y a des photos après dans la liste (donc plus anciennes)
                      if (chronoIndex < validChronoImages.length - 1) {
                        nextPhoto = validChronoImages[chronoIndex + 1];
                      }
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MiniImagePreview(
                          photo: previousPhoto,
                          text: "Image suivante",
                          onDelete: _sendPhotoToTrash,
                        ),
                        const SizedBox(width: 30),
                        MiniImagePreview(
                          photo: nextPhoto,
                          text: "Image précédente",
                          onDelete: _sendPhotoToTrash,
                        ),
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
