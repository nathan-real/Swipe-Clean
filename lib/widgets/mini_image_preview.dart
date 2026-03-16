import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class MiniImagePreview extends StatefulWidget {
  final AssetEntity? photo;
  final String text;
  final Function(AssetEntity) onDelete;

  const MiniImagePreview({
    super.key,
    required this.photo,
    required this.text,
    required this.onDelete,
  });

  @override
  State<MiniImagePreview> createState() => _MiniImagePreviewState();
}

class _MiniImagePreviewState extends State<MiniImagePreview> {
  // La fonction pour afficher l'image en grand
  void _showFullImage(BuildContext context, AssetEntity photo) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          // On utilise un Column pour placer le bouton en dessous de l'image
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child:
                    // Stack pour mettre la croix au dessus
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(20),
                          // Widget qui permet de zoomer
                          child: InteractiveViewer(
                            child: AssetEntityImage(
                              photo,
                              isOriginal: true,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 15), // Espace entre l'image et le bouton
              // Le bouton "Supprimer"
              FloatingActionButton(
                onPressed: () {
                  widget.onDelete(photo);
                  Navigator.pop(context);
                },
                backgroundColor: Colors.red,
                elevation: 0,
                child: const Icon(Icons.delete_rounded, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.photo != null)
            GestureDetector(
              onTap: () => _showFullImage(context, widget.photo!),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: AssetEntityImage(
                    widget.photo!,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(200),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 70, height: 70),
          const SizedBox(height: 7),
          Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
