import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class BookNowBarWidget extends StatelessWidget {
  final String? selectedTime;
  final bool isLoading;
  final VoidCallback onBook;
  final bool isInline;

  const BookNowBarWidget({
    required this.selectedTime,
    required this.isLoading,
    required this.onBook,
    this.isInline = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedTime != null;

    if (isInline) {
      return _buildInlineButton(hasSelection);
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(color: const Color(0xFF2A2A2C), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Yellow circle arrow button
          GestureDetector(
            onTap: isLoading ? null : onBook,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: hasSelection
                    ? AppTheme.primary
                    : AppTheme.primary.withAlpha(102),
                shape: BoxShape.circle,
                boxShadow: hasSelection
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(89),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // "Book Now" center text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Book Now',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceDark,
                  ),
                ),
                if (selectedTime != null)
                  Text(
                    'Selected: $selectedTime',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    'Select a time slot first',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.mutedText,
                    ),
                  ),
              ],
            ),
          ),
          // Chevron indicators
          Row(
            children: [
              Icon(
                Icons.chevron_right_rounded,
                color: hasSelection
                    ? AppTheme.primary
                    : AppTheme.mutedText.withAlpha(102),
                size: 20,
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: hasSelection
                    ? AppTheme.primary.withAlpha(153)
                    : AppTheme.mutedText.withAlpha(64),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineButton(bool hasSelection) {
    return GestureDetector(
      onTap: isLoading ? null : onBook,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: hasSelection
              ? AppTheme.primary
              : AppTheme.primary.withAlpha(102),
          borderRadius: BorderRadius.circular(14),
          boxShadow: hasSelection
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(77),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Book Now',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
