import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';

class OnboardingHeroWidget extends StatelessWidget {
  final VoidCallback onGetStarted;
  final bool showCta;

  const OnboardingHeroWidget({
    required this.onGetStarted,
    required this.showCta,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-bleed hero image
        CustomImageWidget(
          imageUrl:
              'https://images.pexels.com/photos/3997989/pexels-photo-3997989.jpeg',
          width: size.width,
          height: size.height,
          fit: BoxFit.cover,
          semanticLabel:
              'Therapist performing a relaxing back massage on a client in a serene spa setting',
        ),
        // Dark gradient overlay — bottom 60%
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0x400F0F0F),
                Color(0xCC0F0F0F),
                Color(0xF50F0F0F),
              ],
              stops: [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        ),
        // Content overlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo / brand
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'E-RELAX',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Text block — bottom left
                Text(
                  'Find Near By\nSalons &\nBook Services',
                  style: GoogleFonts.dmSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Easily discover top-rated massage centers near you with real-time booking. Browse available services, compare ratings, and book your session.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(179),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                // Dots + CTA row
                Row(
                  children: [
                    // Dot indicators
                    Row(
                      children: List.generate(3, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(right: 6),
                          width: i == 0 ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == 0
                                ? AppTheme.primary
                                : Colors.white.withAlpha(102),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    // CTA arrow button
                    if (showCta)
                      GestureDetector(
                        onTap: onGetStarted,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withAlpha(102),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
