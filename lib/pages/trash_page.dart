import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class TrashPage extends StatefulWidget {
  // La page reçoit la liste de l'extérieur + la fonction de suppression
  final List<AssetEntity> trashedPhotos;
  final VoidCallback onEmptyTrash;

  const TrashPage({
    super.key,
    required this.trashedPhotos,
    required this.onEmptyTrash,
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
          title: const Text("Vider la corbeille ?"),
          content: const Text(
            "Ces photos seront définitivement supprimées de votre appareil. Cette action est irréversible.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Annuler
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la pop-up
                widget.onEmptyTrash();
              },
              child: const Text(
                "Supprimer",
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

    return Column(
      children: [
        Expanded(
          // On vérifie si la liste est vide
          child: widget.trashedPhotos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "La corbeille est vide",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: widget.trashedPhotos.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AssetEntityImage(
                        // On lit la liste passée en paramètre
                        widget.trashedPhotos[index],
                        isOriginal: false,
                        // Réduction de la taille des images pour les faire charger plus vite à l'écran
                        thumbnailSize: const ThumbnailSize.square(250),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
        ),
        if (widget.trashedPhotos.isNotEmpty)
          Padding(
            // On ajoute une marge en bas pour éviter que la NavBar ne le cache
            padding: const EdgeInsets.only(top: 15.0, bottom: 120.0),
            child: FloatingActionButton.extended(
              onPressed: _showDeleteConfirmation,
              backgroundColor: Colors.red,
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text(
                "Tout supprimer",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
