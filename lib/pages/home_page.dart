import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swipe_clean/app_colors.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0;

  void incrementer() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.main,
        toolbarHeight: 0, // Hauteur 0 : pour juste avoir la statue bar
        elevation: 0, // Pas d'ombre
        systemOverlayStyle: SystemUiOverlayStyle
            .light, // Pour mettre les icones de la barre en blanc
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          Row(
            children: [
              const SizedBox(width: 48),
              const Expanded(
                child: Text(
                  'Swipe Clean',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          Expanded(
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
        ],
      ),
    );
  }
}
