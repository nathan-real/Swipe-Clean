import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../widgets/custom_header.dart';
import 'sort_page.dart';
import 'package:swipe_clean/app_colors.dart';
import '../services/gallery_service.dart';
import '../utils/slide_up_route.dart';
import '../widgets/folder_explorer_sheet.dart';

// Langue
import '../l10n/app_localizations.dart';

class MainFolders extends StatefulWidget {
  final Function(AssetEntity) onTrashPhoto;
  final Function(AssetEntity) onRemoveFromTrash;

  const MainFolders({
    super.key,
    required this.onTrashPhoto,
    required this.onRemoveFromTrash,
  });

  @override
  State<MainFolders> createState() => _MainFoldersState();
}

class _MainFoldersState extends State<MainFolders>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  // Dictionnaire pour ranger les mois par année
  Map<int, Map<int, List<AssetEntity>>> _foldersMap = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  // Fonction pour charger les dossiers
  Future<void> _loadFolders() async {
    const int chunkSize = 2000; // Taille de la tranche
    int currentOffset = 0;
    bool hasMore = true;

    Map<int, Map<int, List<AssetEntity>>> tempFolders = {};
    while (hasMore) {
      // On demande une tranche de photos
      final photosChunk = await GalleryService().getImages(
        start: currentOffset,
        limit: chunkSize,
      );

      //Si la tranche est vide, on a atteint la fin de la galerie
      if (photosChunk.isEmpty) {
        hasMore = false;
        break;
      }

      // On traite les dates de cette tranche
      for (var photo in photosChunk) {
        // Optionnel : On s'assure que la date est valide avant de l'utiliser
        final year = photo.createDateTime.year;
        final month = photo.createDateTime.month;

        if (!tempFolders.containsKey(year)) {
          tempFolders[year] = {};
        }
        if (!tempFolders[year]!.containsKey(month)) {
          tempFolders[year]![month] = [];
        }

        // On ajoute la photo à la liste du mois
        tempFolders[year]![month]!.add(photo);
      }

      //On prépare les données pour l'affichage
      // On créer un dico d'entiers pour les années et de liste des photos pour les mois de chaques années
      Map<int, Map<int, List<AssetEntity>>> finalFolders = {};
      final sortedYears = tempFolders.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      for (var year in sortedYears) {
        final sortedMonths = tempFolders[year]!.keys.toList()
          ..sort((a, b) => b.compareTo(a));
        finalFolders[year] = {};
        for (var month in sortedMonths) {
          finalFolders[year]![month] = tempFolders[year]![month]!;
        }
      }

      // On met à jour l'écran immédiatement
      // L'utilisateur verra les premiers dossiers apparaître
      setState(() {
        _foldersMap = finalFolders;
        _isLoading = false;
      });

      // On décale le curseur pour la prochaine requête en arrière-plan
      currentOffset += chunkSize;
    }
  }

  // Petit outil pour traduire le numéro du mois en texte
  String _getMonthName(BuildContext context, int monthNumber) {
    // On charge les traductions une seule fois pour la fonction
    final l10n = AppLocalizations.of(context)!;

    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];

    return months[monthNumber - 1];
  }

  void _loadAllPhotos() {
    List<AssetEntity> allPhotos = [];

    for (int year in _foldersMap.keys) {
      final monthsData = _foldersMap[year]!;

      for (int month in monthsData.keys) {
        allPhotos.addAll(monthsData[month]!);
      }
    }

    Navigator.push(
      context,
      SlideUpRoute(
        page: SortPage(
          onTrashPhoto: widget.onTrashPhoto,
          onRemoveFromTrash: widget.onRemoveFromTrash,
          photosToSort: allPhotos,
          title: AppLocalizations.of(context)!.allGallery,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const CustomHeader(),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Pour les espacer proprement
          children: [
            ElevatedButton.icon(
              onPressed: _loadAllPhotos,
              icon: const Icon(Icons.layers_rounded),
              label: Text(AppLocalizations.of(context)!.allGallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.main,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => openFolderExplorerSheet(
                context,
                onTrashPhoto: widget.onTrashPhoto,
                onRemoveFromTrash: widget.onRemoveFromTrash,
              ),
              icon: const Icon(Icons.folder_rounded),
              label: Text(AppLocalizations.of(context)!.folder),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.main,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Affichage des dossiers
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _foldersMap.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.noPhotos))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: _foldersMap.length,
                  // Ici on construit une tuile de la liste
                  itemBuilder: (context, index) {
                    final year = _foldersMap.keys.elementAt(index);
                    final monthsData = _foldersMap[year]!;
                    final monthsList = monthsData.keys
                        .toList(); // Les numéros des mois

                    // Somme du nombre de photo par an
                    final int totalPhotosForYear = monthsData.values.fold(
                      0,
                      (sum, photos) => sum + photos.length,
                    );

                    return Container(
                      // Les marges pour détacher la tuile des autres et des bords de l'écran
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 6.0,
                      ),

                      decoration: BoxDecoration(
                        color: AppColors.pills(context),
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),

                        child: Theme(
                          // Enlève les bordures par défaut de l'ExpansionTile
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                          ),
                          // La brique principale de la listview
                          child: ExpansionTile(
                            iconColor: AppColors.main,
                            textColor: AppColors.main,

                            title: Text.rich(
                              TextSpan(
                                children: [
                                  //L'année en grand et en gras
                                  TextSpan(
                                    text: year.toString(),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Le nombre de photos
                                  TextSpan(
                                    text:
                                        "  ($totalPhotosForYear ${AppLocalizations.of(context)!.photos})",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.text(
                                        context,
                                      ).withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            children: monthsList.map((month) {
                              final photosForThisMonth = monthsData[month]!;

                              final int monthPhotoCount =
                                  photosForThisMonth.length;

                              final AssetEntity firstPhoto =
                                  photosForThisMonth.first;

                              // Composant présent dans la place qui s'étend
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                leading: Container(
                                  width: 45, // Taille du carré
                                  height: 45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  // Pour que l'image respecte les bords arrondis du container
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Fond uni au cas où l'image tarde à charger
                                        Container(
                                          color: AppColors.main.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                        // La photo de preview
                                        AssetEntityImage(
                                          firstPhoto,
                                          isOriginal:
                                              false, // On demande une miniature
                                          thumbnailSize:
                                              const ThumbnailSize.square(100),
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                title: Text.rich(
                                  TextSpan(
                                    children: [
                                      // Le nom du mois
                                      TextSpan(
                                        text: _getMonthName(context, month),
                                        style: const TextStyle(
                                          fontSize:
                                              16, // Un peu plus petit que l'année
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      // Le compteur de photos
                                      TextSpan(
                                        text: "  ($monthPhotoCount)",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.text(
                                            context,
                                          ).withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlideUpRoute(
                                      page: SortPage(
                                        onTrashPhoto: widget.onTrashPhoto,
                                        onRemoveFromTrash:
                                            widget.onRemoveFromTrash,
                                        photosToSort: photosForThisMonth,
                                        title:
                                            "${_getMonthName(context, month)} $year",
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
