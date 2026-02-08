import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';

class MainFolders extends StatefulWidget {
  const MainFolders({super.key});

  @override
  State<MainFolders> createState() => _MainFoldersState();
}

class _MainFoldersState extends State<MainFolders>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const SizedBox(height: 20),
        const CustomHeader(),
        const SizedBox(height: 10),
      ],
    );
  }
}
