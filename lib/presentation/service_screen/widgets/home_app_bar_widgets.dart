import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class HomeAppBarWidget extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const HomeAppBarWidget({required this.onNotificationTap, super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl:
                    'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                semanticLabel:
                    'Profile photo of Filipino woman with long dark hair smiling',
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
                  'Hey, Maria 👋',
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
