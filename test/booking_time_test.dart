import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_e_relax/core/booking_time.dart';

void main() {
  group('BookingTime', () {
    test('provides quarter-hour options from 11:00 AM through 8:00 PM', () {
      expect(BookingTime.options, hasLength(37));
      expect(BookingTime.options.first, '11:00 AM');
      expect(BookingTime.options.last, '8:00 PM');
      expect(BookingTime.options, contains('1:15 PM'));
      expect(BookingTime.options, isNot(contains('10:45 AM')));
      expect(BookingTime.options, isNot(contains('8:15 PM')));
    });

    test('accepts and normalizes times within the inclusive work window', () {
      expect(BookingTime.normalize('11:00 AM'), '11:00 AM');
      expect(BookingTime.normalize('1:05 pm'), '1:05 PM');
      expect(BookingTime.normalize('8:00 PM'), '8:00 PM');
    });

    test('rejects times outside 11:00 AM through 8:00 PM', () {
      expect(BookingTime.normalize('10:59 AM'), isNull);
      expect(BookingTime.normalize('8:01 PM'), isNull);
      expect(BookingTime.normalize('9:00 AM'), isNull);
      expect(BookingTime.normalize('9:00 PM'), isNull);
    });

    test('rejects malformed and impossible times', () {
      expect(BookingTime.normalize('11 AM'), isNull);
      expect(BookingTime.normalize('13:00 PM'), isNull);
      expect(BookingTime.normalize('11:60 AM'), isNull);
    });

    test('rejects an already booked time', () {
      expect(
        BookingTime.validationMessage('1:00 PM', bookedTimes: ['1:00 PM']),
        'That time is already booked. Choose another time.',
      );
    });
  });
}
