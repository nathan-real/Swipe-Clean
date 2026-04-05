import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/storage_service.dart';
import '../widgets/swipe_screen.dart';
import '../app_colors.dart';

// Langue
import '../l10n/app_localizations.dart';

class SortPage extends StatefulWidget {
  final Function(AssetEntity) onTrashPhoto;
  final Function(AssetEntity) onRemoveFromTrash;
  final List<AssetEntity> photosToSort;
  final String title;

  const SortPage({
    super.key,
    required this.onTrashPhoto,
    required this.onRemoveFromTrash,
    required this.photosToSort,
    required this.title,
  });
  @override
  State<SortPage> createState() => _SortPageState();
}

class _SortPageState extends State<SortPage>
    with AutomaticKeepAliveClientMixin {
  String _sortMode = 'chronological';
  bool _isReady = false;

  //Une clé unique pour forcer le rechargement du swiper
  Key _swiperKey = UniqueKey();

  List<AssetEntity> _images = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadSavedSortMode();
    final processedIds = await StorageService().getProcessedPhotoIds();

    setState(() {
      _images = widget.photosToSort
          .where((photo) => !processedIds.contains(photo.id))
          .toList();
      _isReady = true; // On indique que le filtrage est terminé
    });
  }

  Future<void> _loadSavedSortMode() async {
    String savedMode = await StorageService().getSortMode();
    setState(() {
      _sortMode = savedMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.backgroundNavBar(context),
                  surfaceTintColor: Colors.transparent,
                  title: Text(
                    AppLocalizations.of(context)!.restartSortTitle,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.restartSortWarning,
                    style: TextStyle(color: AppColors.text(context)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        // On récupère tous les IDs du dossier actuel pour les "oublier"
                        List<String> idsInFolder = widget.photosToSort
                            .map((p) => p.id)
                            .toList();
                        await StorageService().resetProcessedPhotos(
                          idsInFolder,
                        );

                        // On recharge la liste complète
                        setState(() {
                          _images = List.from(widget.photosToSort);
                          _swiperKey = UniqueKey();
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.restart,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () {
              // Boite de dialogue
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    // Pour mettre à jour la boite de dialogue quand on appuie sur un bouton
                    builder: (context, setStateDialog) {
                      return AlertDialog(
                        backgroundColor: AppColors.backgroundNavBar(context),
                        surfaceTintColor: Colors.transparent,
                        title: Text(
                          AppLocalizations.of(context)!.sortMode,
                          style: TextStyle(
                            color: AppColors.text(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        content: SegmentedButton<String>(
                          style: ButtonStyle(
                            // Couleur de fond quand le bouton est SÉLECTIONNÉ
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppColors.main;
                                  }
                                  return AppColors.main.withValues(alpha: 0.2);
                                }),

                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.white;
                                  }
                                  return AppColors.text(context);
                                }),

                            // Couleur de la bordure autour des boutons
                            side: WidgetStateProperty.all(
                              BorderSide(
                                color: AppColors.main.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          segments: [
                            ButtonSegment(
                              value: 'chronological',
                              label: Text(AppLocalizations.of(context)!.chrono),
                              icon: Icon(Icons.access_time),
                            ),
                            ButtonSegment(
                              value: 'random',
                              label: Text(AppLocalizations.of(context)!.random),
                              icon: Icon(Icons.shuffle),
                            ),
                          ],
                          selected: {_sortMode},
                          onSelectionChanged: (Set<String> newSelection) {
                            setStateDialog(() {
                              // On récupère le premier élément sélectionné
                              _sortMode = newSelection.first;
                            });
                          },
                        ),

                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
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
                            onPressed: () async {
                              Navigator.pop(context);
                              await StorageService().saveSortMode(_sortMode);
                              setState(() {});
                            },
                            style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all(
                                Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.confirm,
                              style: TextStyle(
                                color: AppColors.text(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: !_isReady
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // On passe la fonction à notre widget de swipe
                Expanded(
                  child: SwipeScreen(
                    key: _swiperKey,
                    onTrashPhoto: widget.onTrashPhoto,
                    onRemoveFromTrash: widget.onRemoveFromTrash,
                    sortMode: _sortMode,
                    photos: _images,
                  ),
                ),
              ],
            ),
    );
  }
}
