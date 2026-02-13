import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final List<Color> _cards = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CardSwiper(
                cardsCount: _cards.length,
                allowedSwipeDirection: const AllowedSwipeDirection.all(),

                onSwipe: (previousIndex, currentIndex, direction) {
                  // CAS 1 : L'utilisateur essaie de swiper en haut ou en bas
                  if (direction == CardSwiperDirection.top ||
                      direction == CardSwiperDirection.bottom) {
                    return false;
                  }

                  // CAS 2 : L'utilisateur swipe à droite
                  if (direction == CardSwiperDirection.right) {
                    return true;
                  }
                  // CAS 3 : L'utilisateur swipe à gauche
                  else if (direction == CardSwiperDirection.left) {
                    return true;
                  }

                  return false;
                },
                cardBuilder: (context, index, x, y) {
                  return Container(
                    decoration: BoxDecoration(
                      color: _cards[index],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                  );
                },
              ),
            ),
            SizedBox(height: 170),
          ],
        ),
      ),
    );
  }
}
