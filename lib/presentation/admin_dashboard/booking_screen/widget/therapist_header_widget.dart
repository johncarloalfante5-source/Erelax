import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class TherapistHeaderWidget extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String serviceName;
  final double price;
  final int durationMinutes;

  const TherapistHeaderWidget({
    required this.name,
    required this.location,
    required this.rating,
    required this.serviceName,
    required this.price,
    required this.durationMinutes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service name chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(31),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppTheme.primary.withAlpha(64), width: 1),
          ),
          child: Text(
            serviceName,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Name + rating row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primary.withAlpha(77),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppTheme.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Location
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppTheme.mutedText,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              location,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Price + duration row
        Row(
          children: [
            Text(
              '₱${price.toStringAsFixed(0)}',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.mutedText,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$durationMinutes min session',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
