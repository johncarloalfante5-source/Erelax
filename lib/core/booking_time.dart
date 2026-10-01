class BookingTime {
  BookingTime._();

  static List<String> get options => List.generate(37, (index) {
    final minuteOfDay = 11 * 60 + index * 15;
    final hour24 = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final period = hour24 < 12 ? 'AM' : 'PM';
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  });

  static final RegExp _inputPattern = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    caseSensitive: false,
  );

  static String? normalize(String input) {
    final match = _inputPattern.firstMatch(input.trim());
    if (match == null) return null;

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();
    if (hour < 1 || hour > 12 || minute > 59) return null;

    final minuteOfDay =
        (hour % 12) * 60 + minute + (period == 'PM' ? 12 * 60 : 0);
    if (minuteOfDay < 11 * 60 || minuteOfDay > 20 * 60) {
      return null;
    }

    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  static String? validationMessage(
    String input, {
    List<String> bookedTimes = const [],
  }) {
    if (input.trim().isEmpty) {
      return null;
    }

    final match = _inputPattern.firstMatch(input.trim());
    if (match == null) {
      return 'Use the format h:mm AM/PM, for example 11:30 AM.';
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour < 1 || hour > 12 || minute > 59) {
      return 'Enter a valid hour and minute.';
    }

    final normalized = normalize(input);
    if (normalized == null) {
      return 'Enter a time between 11:00 AM and 8:00 PM.';
    }
    if (bookedTimes.contains(normalized)) {
      return 'That time is already booked. Choose another time.';
    }
    return null;
  }
}
