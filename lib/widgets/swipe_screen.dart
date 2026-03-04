import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../app_colors.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../services/gallery_service.dart';

class SwipeScreen extends StatefulWidget {
  final Function(AssetEntity) onTrashPhoto;

  const SwipeScreen({super.key, required this.onTrashPhoto});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final CardSwiperController controller = CardSwiperController();

  // On instancie notre service de photo
  final GalleryService _galleryService = GalleryService();

  List<AssetEntity> _images = [];
  bool _isLoading = true;

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

  Future<void> _loadPhotos() async {
    // On appelle notre service.
    // On donnera le mois et l'année plus tard ici
    final photos = await _galleryService.getImages(limit: 100);

    setState(() {
      _images = photos;
      _isLoading = false;
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
                    heroTag: "btn_keep",
                    onPressed: () =>
                        controller.swipe(CardSwiperDirection.right),
                    backgroundColor: Colors.green,
                    shape: CircleBorder(),
                    child: const Icon(Icons.check_rounded, color: Colors.white),
                  ),
                ], // Fin des children du Row
              ), // Fin du Row
            ), // Fin du Padding

            SizedBox(height: 130),
          ],
        ),
      ),
    );
  }
}
