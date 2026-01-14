import 'package:flutter/material.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Data
  int count = 0;

  //Méthodes
  void incrementer() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Clean'),
        centerTitle: true,
        actions: [
          // Bouton vers Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Compteur : $count', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: incrementer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 51, 59, 150),
                foregroundColor: Colors.white,
              ),
              child: const Text("Augmenter"),
            ),
          ],
        ),
      ),
    );
  }
}
