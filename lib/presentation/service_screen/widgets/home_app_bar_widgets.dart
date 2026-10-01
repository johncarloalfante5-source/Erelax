import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/auth_store.dart';
import '../../../theme/app_theme.dart';

class HomeAppBarWidget extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const HomeAppBarWidget({required this.onNotificationTap, super.key});

  @override
  Widget build(BuildContext context) {
    final name = AuthStore.currentUserName;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // User avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withAlpha(102),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: GoogleFonts.dmSans(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Greeting column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.mutedText,
                  ),
                ),
                Text(
                  'Hey, $name 👋',
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceDark,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3A3A3C), width: 1),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'notifications_outlined',
                    color: AppTheme.onSurfaceDark,
                    size: 22,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
