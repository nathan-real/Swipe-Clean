import 'package:flutter/material.dart';
import '../widgets/swipe_screen.dart';

class SortPage extends StatefulWidget {
  const SortPage({super.key});

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
      body: Column(children: [const Expanded(child: SwipeScreen())]),
    );
  }
}
