import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../widgets/swipe_screen.dart';

class SortPage extends StatefulWidget {
  final Function(AssetEntity) onTrashPhoto;

  const SortPage({super.key, required this.onTrashPhoto});
  @override
  State<SortPage> createState() => _SortPageState();
}

class _SortPageState extends State<SortPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tri de Janvier')),
      body: Column(
        children: [
          // On passe la fonction à notre widget de swipe
          Expanded(child: SwipeScreen(onTrashPhoto: widget.onTrashPhoto)),
        ],
      ),
    );
  }
}
