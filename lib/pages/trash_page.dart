import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:swipe_clean/app_colors.dart';

//Langue
import '../l10n/app_localizations.dart';

class TrashPage extends StatefulWidget {
  // La page reçoit la liste de l'extérieur + la fonction de suppression
  final List<AssetEntity> trashedPhotos;
  final VoidCallback onEmptyTrash;
  final Function(AssetEntity) onRemoveFromTrash;

  const TrashPage({
    super.key,
    required this.trashedPhotos,
    required this.onEmptyTrash,
    required this.onRemoveFromTrash,
  });

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage>
    with AutomaticKeepAliveClientMixin {
  // Permet de garder la position du scroll quand on change d'onglet

  // Fonction qui permet d'envoyer la notif system de supression définitive des photos
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundNavBar(context),
          surfaceTintColor: Colors.transparent,
          title: Text(
            AppLocalizations.of(context)!.toEmptyTrash,
            style: TextStyle(
              color: AppColors.text(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.deleteWarning,
            style: TextStyle(color: AppColors.text(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Annuler
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la pop-up
                widget.onEmptyTrash();
              },
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  Colors.red.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Si la liste est vide, on garde l'affichage simple centré
    if (widget.trashedPhotos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.emptyTrash,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Si on a des photos, on utilise un Stack pour l'effet de superposition
    return Stack(
      children: [
        // COUCHE 1 : La grille
        // Elle prend tout l'écran
        Positioned.fill(
          child: GridView.builder(
            // On ajoute un grand padding en bas de la liste
            // Pour que l'utilisateur puisse scroller la toute dernière ligne de photos au-dessus de la nav bar et du bouton.
            padding: const EdgeInsets.only(
              left: 4,
              right: 4,
              top: 4,
              bottom: 200,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: widget.trashedPhotos.length,
            itemBuilder: (context, index) {
              final photo = widget.trashedPhotos[index];

              return GestureDetector(
                onTap: () {
                  // Ouvre la page plein écran quand on clique sur la photo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImagePage(
                        photo: photo,
                        onRemoveFromTrash: widget.onRemoveFromTrash,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AssetEntityImage(
                    photo,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(250),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        // COUCHE 2 : Le bouton flottant
        Positioned(
          bottom: 120.0,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.extended(
              onPressed: _showDeleteConfirmation,
              backgroundColor: Colors.red,
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: Text(
                AppLocalizations.of(context)!.deleteAll,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Petite classe en plus qui sert à afficher l'image en grande
class FullScreenImagePage extends StatelessWidget {
  final AssetEntity photo;
  // On importe la fonction pour enlever une photo de la corbeille
  final Function(AssetEntity) onRemoveFromTrash;

  const FullScreenImagePage({
    super.key,
    required this.photo,
    required this.onRemoveFromTrash,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // On fait prendre toute la place à l'image
            Expanded(
              // Permet de zoomer
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: AssetEntityImage(
                  photo,
                  isOriginal: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Le bouton en dessous
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: FloatingActionButton.extended(
                heroTag: "btn_undo_fullscreen",
                onPressed: () {
                  // On retire la photo de la corbeille
                  onRemoveFromTrash(photo);
                  Navigator.pop(context); // On ferme la page plein écran
                },
                backgroundColor: Colors.grey,
                icon: const Icon(Icons.undo, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context)!.removeFromTrash,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
