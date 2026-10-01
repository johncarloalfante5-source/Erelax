import 'package:flutter/material.dart';

import '../core/app_export.dart';
import '../theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String iconName;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    required this.iconName,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: AppTheme.mutedText,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.mutedText,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: CustomIconWidget(
                  iconName: 'add_rounded',
                  color: Colors.black,
                  size: 18,
                ),
                label: Text(
                  actionLabel!,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
