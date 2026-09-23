import 'package:flutter/material.dart';
import '../core/app_fonts.dart';

enum ReservationStatus { pending, confirmed, inProgress, completed, cancelled }

class StatusBadgeWidget extends StatelessWidget {
  final ReservationStatus status;
  final double fontSize;

  const StatusBadgeWidget({
    required this.status,
    this.fontSize = 11,
    super.key,
  });

  Color get _backgroundColor {
    switch (status) {
      case ReservationStatus.pending:
        return const Color(0xFFFF9F0A).withAlpha(46);
      case ReservationStatus.confirmed:
        return const Color(0xFF30D158).withAlpha(46);
      case ReservationStatus.inProgress:
        return const Color(0xFFF5C518).withAlpha(46);
      case ReservationStatus.completed:
        return const Color(0xFF636366).withAlpha(46);
      case ReservationStatus.cancelled:
        return const Color(0xFFFF453A).withAlpha(46);
    }
  }

  Color get _textColor {
    switch (status) {
      case ReservationStatus.pending:
        return const Color(0xFFFF9F0A);
      case ReservationStatus.confirmed:
        return const Color(0xFF30D158);
      case ReservationStatus.inProgress:
        return const Color(0xFFF5C518);
      case ReservationStatus.completed:
        return const Color(0xFF8A8A8E);
      case ReservationStatus.cancelled:
        return const Color(0xFFFF453A);
    }
  }

  String get _label {
    switch (status) {
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.confirmed:
        return 'Confirmed';
      case ReservationStatus.inProgress:
        return 'In Progress';
      case ReservationStatus.completed:
        return 'Completed';
      case ReservationStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _textColor.withAlpha(77), width: 1),
      ),
      child: Text(
        _label,
        style: GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
