import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class TimeGridWidget extends StatelessWidget {
  final List<String> timeSlots;
  final List<String> bookedSlots;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;

  const TimeGridWidget({
    required this.timeSlots,
    required this.bookedSlots,
    required this.selectedTime,
    required this.onTimeSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3.2,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final time = timeSlots[index];
        final isSelected = selectedTime == time;
        final isBooked = bookedSlots.contains(time);

        return GestureDetector(
          onTap: isBooked ? null : () => onTimeSelected(time),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : isBooked
                  ? AppTheme.surfaceVariantDark.withAlpha(102)
                  : AppTheme.surfaceVariantDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : isBooked
                    ? const Color(0xFF2A2A2C)
                    : const Color(0xFF3A3A3C),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withAlpha(64),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isBooked)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.block_rounded,
                        size: 12,
                        color: AppTheme.mutedText.withAlpha(128),
                      ),
                    ),
                  Text(
                    time,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.black
                          : isBooked
                          ? AppTheme.mutedText.withAlpha(102)
                          : AppTheme.onSurfaceDark,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
