import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../widgets/custom_header.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  //La liste qui va contenir toutes les images
  List<AssetEntity> _images = [];
  //Booléen pour savoir si ça charge pour afficher un écran de chargement
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssets(); // Dès que la page s'ouvre, on lance la récupération
  }

  Future<void> _fetchAssets() async {
    // Variable qui stock la permission acceptée ou refusée
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth || ps == PermissionState.limited) {
      // On demande ques les images, pas de vidéos
      // Le type est une liste des chemins vers ces photos et pas les photos elles mêmes
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      if (albums.isNotEmpty) {
        // On prend le premier album
        List<AssetEntity> media = await albums[0].getAssetListPaged(
          page: 0,
          size: 500,
        );
        setState(() {
          // on remplit la liste globale
          _images = media;
          _isLoading = false;
        });
      } else {
        // Pas d'albums trouvés
        setState(() => _isLoading = false);
      }
    } else {
      // L'utilisateur a refusé
      setState(() => _isLoading = false);
      PhotoManager.openSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CustomHeader(),
        const SizedBox(height: 10),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _images.isEmpty
              ? const Center(child: Text("Aucune photo trouvée"))
              : GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 photos par ligne
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return AssetEntityImage(
                      _images[index],
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize.square(250),
                      fit: BoxFit.cover,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
