import 'package:photo_manager/photo_manager.dart';

class GalleryService {
  Future<List<AssetEntity>> getImages({int start = 0, int limit = 2000}) async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image, // Le secret est ici : on exclut les vidéos !
          mediaLocation: false,
        ),
      ),
    );

    if (!ps.isAuth && !ps.hasAccess) {
      return [];
    }

    FilterOptionGroup filterOption = FilterOptionGroup(
      orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
    );

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
      filterOption: filterOption,
    );

    if (albums.isEmpty) {
      return [];
    }

    final AssetPathEntity recentAlbum = albums.first;

    // On demande au système combien de photos il y a vraiment dans ce dossier
    final int totalPhotos = await recentAlbum.assetCountAsync;

    if (totalPhotos == 0) {
      return [];
    }

    final List<AssetEntity> photos = await recentAlbum.getAssetListRange(
      start: start,
      end: start + limit,
    );

    return photos;
  }
}
