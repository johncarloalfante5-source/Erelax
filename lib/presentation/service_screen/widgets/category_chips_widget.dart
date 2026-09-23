import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CategoryChipsWidget extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryChipsWidget({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isActive = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isActive ? AppTheme.primary : const Color(0xFF3A3A3C),
                  width: 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(64),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                categories[index],
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.black : AppTheme.mutedText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
