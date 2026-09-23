import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';

class BookingHeroWidget extends StatelessWidget {
  final String imageUrl;
  final String semanticLabel;
  final VoidCallback onBack;

  const BookingHeroWidget({
    required this.imageUrl,
    required this.semanticLabel,
    required this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.42;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImageWidget(
            imageUrl: imageUrl,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            semanticLabel: semanticLabel,
          ),
          // Bottom gradient fade into panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.surfaceDark],
                ),
              ),
            ),
          ),
          // Back button overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(115),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(38),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
