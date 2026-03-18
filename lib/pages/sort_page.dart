import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/storage_service.dart';
import '../widgets/swipe_screen.dart';
import '../app_colors.dart';

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

  List<AssetEntity> _images = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSavedSortMode();
    // On copie la liste reçue pour pouvoir la manipuler
    _images = List.from(widget.photosToSort);
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
                          "Mode de tri",
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
                          segments: const [
                            ButtonSegment(
                              value: 'chronological',
                              label: Text("Chrono"),
                              icon: Icon(Icons.access_time),
                            ),
                            ButtonSegment(
                              value: 'random',
                              label: Text("Aléatoire"),
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
                            child: const Text(
                              "Annuler",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await StorageService().saveSortMode(_sortMode);
                              setState(() {});
                            },
                            child: Text(
                              "Valider",
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
      body: Column(
        children: [
          // On passe la fonction à notre widget de swipe
          Expanded(
            child: SwipeScreen(
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
