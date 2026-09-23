import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class DateSelectorWidget extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateSelectorWidget({
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late ScrollController _scrollController;

  static const List<String> _dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  List<DateTime> _generateDates() {
    final now = DateTime.now();
    return List.generate(21, (i) => now.add(Duration(days: i)));
  }

  String _dayName(DateTime d) => _dayNames[d.weekday - 1];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dates = _generateDates();

    return SizedBox(
      height: 74,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              date.day == widget.selectedDate.day &&
              date.month == widget.selectedDate.month &&
              date.year == widget.selectedDate.year;
          final isToday =
              date.day == DateTime.now().day &&
              date.month == DateTime.now().month;

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 10),
              width: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : isToday
                      ? AppTheme.primary.withAlpha(102)
                      : const Color(0xFF3A3A3C),
                  width: isSelected ? 0 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayName(date),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black : AppTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.black : AppTheme.onSurfaceDark,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
