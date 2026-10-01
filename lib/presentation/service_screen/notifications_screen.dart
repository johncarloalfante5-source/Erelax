import 'package:flutter/material.dart';

import '../../core/auth_store.dart';
import '../../core/booking_store.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  List<Map<String, dynamic>> _notifications() {
    final email = AuthStore.currentUserEmail;
    return BookingStore.allBookings
        .where((booking) => booking['customerEmail'] == email)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notifications();
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        foregroundColor: AppTheme.onSurfaceDark,
        title: Text(
          'Notifications',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'You have no notifications yet.',
                style: GoogleFonts.dmSans(color: AppTheme.mutedText),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = notifications[index];
                final status = booking['status'] as String;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariantDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your ${booking['service']} booking on ${booking['date']} at ${booking['time']} is $status.',
                          style: GoogleFonts.dmSans(
                            color: AppTheme.onSurfaceDark,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}