import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 30, 30, 30),
        appBar: AppBar(
          title: const Text('Swipe Clean'),
          centerTitle: true,
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          backgroundColor: const Color.fromARGB(255, 51, 59, 150),
        ),
        body: Center(
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    'Hello, World!',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                  Image.asset(
                    'assets/images/Kubby_Skate.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 51, 59, 150),
                      foregroundColor: Colors.white,
                      overlayColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: () {
                      print('Click!');
                    },
                    child: const Text('A button'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
