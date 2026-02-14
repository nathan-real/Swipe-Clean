import 'package:photo_manager/photo_manager.dart';

class GalleryService {
  Future<List<AssetEntity>> getImages({
    int limit = 100,
    int? month, // on verra après ça
    int? year,
  }) async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth && !ps.hasAccess) {
      // L'utilisateur a refusé
      return [];
    }

    // Si l'utilisateur accepte
    // Configuration du filtre (c'est ici qu'on fera le tri par date plus tard)
    final FilterOptionGroup filterOption = FilterOptionGroup(
      orders: [
        // On veut les plus récentes en premier
        const OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
    );

    // Récupérer les albums (Le "Recent" est toujours le premier)
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filterOption,
    );

    if (albums.isEmpty) return [];

    // On prend l'album "Recent"
    final AssetPathEntity recentAlbum = albums.first;

    // Récupérer les photos (Pagination)
    // Ici on prend de 0 à 100.
    final List<AssetEntity> photos = await recentAlbum.getAssetListRange(
      start: 0,
      end: limit,
    );

    return photos;
  }
}
