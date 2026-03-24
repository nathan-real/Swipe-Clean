import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../pages/sort_page.dart';
import '../utils/slide_up_route.dart';
import '../app_colors.dart';

//Langue
import '../l10n/app_localizations.dart';

Future<void> openFolderExplorerSheet(
  BuildContext context, {
  required Function(AssetEntity) onTrashPhoto,
  required Function(AssetEntity) onRemoveFromTrash,
}) async {
  // On demande les dossiers
  final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
    type: RequestType.image,
  );
  if (!context.mounted) return;

  // On affiche le menu
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (context) {
      return Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.deviceFolders,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];

                // Liste des dossiers
                return ListTile(
                  leading: const Icon(
                    Icons.folder_rounded,
                    color: AppColors.main,
                  ),
                  title: Text(album.name),
                  // Infos sur le nombre de photos
                  trailing: FutureBuilder<int>(
                    future: album.assetCountAsync,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          "${snapshot.data}",
                          style: TextStyle(color: Colors.grey.shade600),
                        );
                      }
                      return const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  ),
                  onTap: () async {
                    Navigator.pop(context); // Ferme le BottomSheet

                    final int count = await album.assetCountAsync;
                    final List<AssetEntity> albumPhotos = await album
                        .getAssetListRange(start: 0, end: count);

                    if (!context.mounted) return;

                    // Navigation vers la page de tri
                    Navigator.push(
                      context,
                      SlideUpRoute(
                        page: SortPage(
                          onTrashPhoto: onTrashPhoto,
                          onRemoveFromTrash: onRemoveFromTrash,
                          photosToSort: albumPhotos,
                          title: album.name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
