import 'package:photo_manager/photo_manager.dart';

class GalleryService {
  Future<List<AssetEntity>> getImages({
    int start = 0,
    int limit = 2000,
  }) async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth && !ps.hasAccess) {
      // L'utilisateur a refusé
      return [];
    }

    // Si l'utilisateur accepte
    // Configuration du filtre
    FilterOptionGroup filterOption = FilterOptionGroup(
      orders: [
        // On veut les plus récentes en premier
        const OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
    );

    // Récupérer les albums (Le "Recent" est toujours le premier)
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
      filterOption: filterOption,
    );

    if (albums.isEmpty) return [];

    // On prend l'album "Recent"
    final AssetPathEntity recentAlbum = albums.first;

    final List<AssetEntity> photos = await recentAlbum.getAssetListRange(
      start: start,
      end: start + limit,
    );

    return photos;
  }
}
