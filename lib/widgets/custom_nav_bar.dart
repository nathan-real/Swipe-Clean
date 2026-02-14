import 'package:flutter/material.dart';
import 'package:swipe_clean/app_colors.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const double navBarWidth = 330.0;
    const double stroke = 5;
    const double pillHeight = 65;

    return Positioned(
      bottom: 30, // détaché du bas
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: navBarWidth,
          height: pillHeight,
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.backgroundDark2 : Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  isDarkMode ? 0.5 : 0.25,
                ), // Ombre  A AJOUTER DANS COLORS
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                left: (navBarWidth / 3) * currentIndex + stroke,

                top: 0,
                bottom: 0,
                width: navBarWidth / 3 - stroke * 2,

                child: Center(
                  // Pillule
                  child: Container(
                    width: navBarWidth / 3 - stroke * 2,
                    height: pillHeight - stroke * 2,
                    decoration: BoxDecoration(
                      color: AppColors.main,
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                ),
              ),

              // Icons
              Row(
                children: [
                  _buildNavItem(
                    0,
                    Icons.folder_copy_outlined,
                    Icons.folder,
                    "Swipe",
                  ),
                  _buildNavItem(
                    1,
                    Icons.delete_outlined,
                    Icons.delete,
                    "Corbeille",
                  ),
                  _buildNavItem(
                    2,
                    Icons.settings_outlined,
                    Icons.settings,
                    "Paramètres",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // On construit un widget pour afficher les logos des items
  Widget _buildNavItem(
    int index,
    IconData iconOff,
    IconData iconOn,
    String label,
  ) {
    bool isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.9,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? iconOn : iconOff,
                color: isSelected ? Colors.white : Colors.grey,
                size: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
