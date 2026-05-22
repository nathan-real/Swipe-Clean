import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:swipe_clean/services/storage_service.dart';
import '../app_colors.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter/services.dart';

// Langue
import '../l10n/app_localizations.dart';

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

  bool _hapticEnabled = true;

  // Nouveau contrôleur pour la pellicule du bas
  late PageController _filmstripController;

  //Garde en mémoire les ID des photos supprimées pendant la session
  final Set<String> _trashedInSession = {};
  @override
  // On load les photos à l'initialisation
  void initState() {
    super.initState();
    _filmstripController = PageController(viewportFraction: 0.15);
    _loadPhotos();
    _loadHapticSetting();
  }

  Future<void> _loadHapticSetting() async {
    bool isEnabled = await StorageService().getVibrationEnabled();
    if (mounted) {
      setState(() {
        _hapticEnabled = isEnabled;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    _filmstripController.dispose();
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

  // Fonction appelée quand on sélectionne une photo dans la pellicule du bas
  void _injectPhotoIntoSwiper(AssetEntity selectedPhoto) {
    setState(() {
      // 1. On vérifie si la photo est déjà dans la suite de la pile
      int existingIndex = _images.indexWhere(
        (img) => img.id == selectedPhoto.id,
      );

      if (existingIndex != -1 && existingIndex > _currentCardIndex) {
        // Si elle est plus loin dans la pile, on la retire de son emplacement futur
        _images.removeAt(existingIndex);
      }

      // 2. On l'écrase à la position actuelle du swiper pour qu'elle s'affiche immédiatement
      _images[_currentCardIndex] = selectedPhoto;
    });
  }

  // Fonction pour afficher la carte principale en plein écran
  void _showFullImage(BuildContext context, AssetEntity photo) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: InteractiveViewer(
                        child: AssetEntityImage(
                          photo,
                          isOriginal: true, // Version originale
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // Le bouton Supprimer
              FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context); // On ferme la pop-up

                  // On vérifie si la photo affichée en grand est celle du swiper actuel
                  if (photo.id == _images[_currentCardIndex].id) {
                    // C'est la carte principale, on déclenche l'animation visuelle
                    controller.swipe(CardSwiperDirection.left);
                  } else {
                    // C'est une photo de la pellicule du bas !
                    widget.onTrashPhoto(photo); // On l'envoie à la corbeille

                    setState(() {
                      // On la met dans la liste noire de la session
                      _trashedInSession.add(photo.id);
                      // On la retire de la file d'attente du swiper pour ne pas tomber dessus plus tard
                      _images.removeWhere((img) => img.id == photo.id);
                    });
                  }
                },
                backgroundColor: Colors.red,
                elevation: 0,
                child: const Icon(Icons.delete_rounded, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_images.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noPhotos));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_currentCardIndex < _images.length)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Builder(
                  builder: (context) {
                    final photo = _images[_currentCardIndex];
                    final date = photo.createDateTime;

                    // Formatage simple de la date (JJ/MM/AAAA)
                    final dateString =
                        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
                    // Formatage de la résolution
                    final resolutionString = "${photo.width} x ${photo.height}";

                    return Text(
                      "$dateString   •   $resolutionString",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              child: CardSwiper(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  left: 20.0,
                  right: 20.0,
                  bottom: 20.0,
                ),
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
                    if (_hapticEnabled) HapticFeedback.selectionClick();
                    String idToSave = _images[previousIndex].id;
                    StorageService().savePhotoAsProcessed(idToSave);
                    return true;
                  }
                  // CAS 3 : L'utilisateur swipe à gauche
                  else if (direction == CardSwiperDirection.left) {
                    if (_hapticEnabled) HapticFeedback.selectionClick();

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
                      final restoredPhoto = _images[currentIndex];

                      // Si la carte précédente avait été glissée à gauche (vers la corbeille)
                      if (direction == CardSwiperDirection.left) {
                        widget.onRemoveFromTrash(restoredPhoto);

                        // --- NOUVEAU : On ressuscite la photo pour la pellicule du bas ---
                        setState(() {
                          _trashedInSession.remove(restoredPhoto.id);
                        });
                      }

                      // On met à jour l'index du Swiper principal
                      setState(() {
                        _currentCardIndex = currentIndex;
                      });

                      return true;
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

                  return GestureDetector(
                    onTap: () => _showFullImage(context, photo),
                    child: Container(
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
            // --- NOUVEAU BLOC : La Pellicule Magnétique ---
            if (_currentCardIndex < _images.length)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  height: 80,
                  child: Builder(
                    builder: (context) {
                      final currentPhoto = _images[_currentCardIndex];

                      // On prend toute la chronologie valide
                      final validChronoImages = _chronologicalImages
                          .where((img) => !_trashedInSession.contains(img.id))
                          .toList();

                      final chronoIndex = validChronoImages.indexWhere(
                        (img) => img.id == currentPhoto.id,
                      );

                      // SYNCHRONISATION : Si on swipe la grande carte, la pellicule s'aligne automatiquement
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_filmstripController.hasClients) {
                          int currentPage =
                              _filmstripController.page?.round() ?? 0;

                          if (currentPage != chronoIndex) {
                            // On calcule l'écart entre la position actuelle et la destination
                            int distance = (currentPage - chronoIndex).abs();

                            if (distance > 3) {
                              // Mode aléatoire ou grand saut : on téléporte sans animation pour préserver les performances
                              _filmstripController.jumpToPage(chronoIndex);
                            } else {
                              // Mode chronologique (déplacement de 1 ou 2 photos) : on glisse en douceur
                              _filmstripController.animateToPage(
                                chronoIndex,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          }
                        }
                      });

                      return PageView.builder(
                        controller: _filmstripController,
                        itemCount: validChronoImages.length,
                        // Le magnétisme est natif au PageView !
                        // Quand l'utilisateur s'arrête de slider sur une photo, ça déclenche ceci :
                        onPageChanged: (index) {
                          // On injecte la photo sélectionnée au premier plan du swiper
                          _injectPhotoIntoSwiper(validChronoImages[index]);
                          // Petit retour haptique pour la sensation de "cran" magnétique
                          if (_hapticEnabled) HapticFeedback.selectionClick();
                        },
                        itemBuilder: (context, index) {
                          final photo = validChronoImages[index];
                          final isCurrent = index == chronoIndex;

                          return GestureDetector(
                            onTap: isCurrent
                                ? null
                                : () => _showFullImage(context, photo),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              // L'image centrale est plus grande
                              margin: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: isCurrent ? 0 : 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: isCurrent
                                    ? Border.all(
                                        color: AppColors.main,
                                        width: 3,
                                      )
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  isCurrent ? 9 : 12,
                                ),
                                child: AssetEntityImage(
                                  photo,
                                  isOriginal: false,
                                  thumbnailSize: const ThumbnailSize.square(
                                    150,
                                  ),
                                  fit: BoxFit.cover,
                                  color: isCurrent
                                      ? null
                                      : Colors.black.withValues(alpha: 0.5),
                                  colorBlendMode: isCurrent
                                      ? null
                                      : BlendMode.darken,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
