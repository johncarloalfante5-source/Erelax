import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_e_relax/core/booking_store.dart';

void main() {
  group('therapist availability', () {
    final firstDate = DateTime(2030, 4, 12);
    final secondDate = DateTime(2030, 4, 13);

    test('is assigned independently for each date', () {
      expect(BookingStore.therapists, hasLength(16));
      expect(BookingStore.therapistsAvailableOn(firstDate), isEmpty);

      BookingStore.toggleTherapistAvailability(
        firstDate,
        BookingStore.therapists.first,
      );

      expect(BookingStore.therapistsAvailableOn(firstDate), [
        BookingStore.therapists.first,
      ]);
      expect(BookingStore.therapistsAvailableOn(secondDate), isEmpty);

      BookingStore.toggleTherapistAvailability(
        firstDate,
        BookingStore.therapists.first,
      );
      expect(BookingStore.therapistsAvailableOn(firstDate), isEmpty);
    });

    test('does not add names outside the predefined roster', () {
      BookingStore.toggleTherapistAvailability(firstDate, 'Unknown Therapist');

      expect(BookingStore.therapistsAvailableOn(firstDate), isEmpty);
    });

    test('booking time conflicts are scoped to the selected therapist', () {
      BookingStore.toggleTherapistAvailability(
        firstDate,
        BookingStore.therapists.first,
      );
      BookingStore.addBooking({
        'id': 'therapist-slot-conflict-test',
        'date': BookingStore.dateKey(firstDate),
        'time': '1:00 PM',
        'therapist': BookingStore.therapists.first,
        'status': 'Pending',
        'price': 0.0,
      });

      expect(
        BookingStore.bookedTimesFor(
          date: firstDate,
          therapist: BookingStore.therapists.first,
        ),
        ['1:00 PM'],
      );
      expect(
        BookingStore.bookedTimesFor(
          date: firstDate,
          therapist: BookingStore.therapists[1],
        ),
        isEmpty,
      );
    });

    test('rejects overlapping appointment intervals at save time', () {
      final date = DateTime(2031, 6, 8);
      final therapist = BookingStore.therapists.first;
      BookingStore.toggleTherapistAvailability(date, therapist);
      BookingStore.addBooking({
        'id': 'interval-conflict-online',
        'date': BookingStore.dateKey(date),
        'time': '11:00 AM',
        'durationMinutes': 60,
        'therapist': therapist,
        'status': 'Confirmed',
        'price': 0.0,
      });

      expect(
        BookingStore.isTherapistAvailable(
          date: date,
          therapist: therapist,
          startTime: '11:30 AM',
          durationMinutes: 60,
        ),
        isFalse,
      );
      expect(
        BookingStore.isTimeBooked(
          date: date,
          therapist: therapist,
          startTime: '11:00 AM',
          durationMinutes: 60,
        ),
        isTrue,
      );
      expect(
        BookingStore.isTimeBooked(
          date: date,
          therapist: therapist,
          startTime: '11:30 AM',
          durationMinutes: 60,
        ),
        isTrue,
      );
      expect(
        BookingStore.isTimeBooked(
          date: date,
          therapist: therapist,
          startTime: '12:00 PM',
          durationMinutes: 60,
        ),
        isFalse,
      );
      expect(
        BookingStore.isTimeBooked(
          date: date,
          therapist: BookingStore.therapists[1],
          startTime: '11:00 AM',
          durationMinutes: 60,
        ),
        isFalse,
      );
      expect(
        BookingStore.availableTherapistsFor(
          date: date,
          time: '11:30 AM',
          durationMinutes: 60,
        ),
        isEmpty,
      );
      expect(
        BookingStore.availableTherapistsFor(
          date: date,
          time: '12:00 PM',
          durationMinutes: 60,
        ),
        [therapist],
      );
      expect(
        BookingStore.isTherapistAvailable(
          date: date,
          therapist: therapist,
          startTime: '7:30 PM',
          durationMinutes: 60,
        ),
        isFalse,
      );
      expect(
        () => BookingStore.addBooking({
          'id': 'interval-conflict-walk-in',
          'date': BookingStore.dateKey(date),
          'time': '11:30 AM',
          'durationMinutes': 60,
          'therapist': therapist,
          'status': 'Confirmed',
          'price': 0.0,
        }),
        throwsA(isA<StateError>()),
      );
      expect(
        () => BookingStore.addBooking({'id': 'missing-schedule-fields'}),
        throwsA(isA<StateError>()),
      );
    });

    test('accepts a scheduled therapist slot when no booking conflicts', () {
      final date = DateTime(2020, 6, 8);
      final therapist = BookingStore.therapists.first;
      BookingStore.toggleTherapistAvailability(date, therapist);

      BookingStore.addBooking({
        'id': 'admin-selected-slot-no-conflict',
        'date': BookingStore.dateKey(date),
        'time': '11:00 AM',
        'durationMinutes': 60,
        'therapist': therapist,
        'status': 'Pending',
        'price': 0.0,
      });

      expect(
        BookingStore.allBookings.any(
          (booking) => booking['id'] == 'admin-selected-slot-no-conflict',
        ),
        isTrue,
      );
      BookingStore.toggleTherapistAvailability(date, therapist);
    });

    test(
      'deduplicates walk-in customers and records payment and refund receipts',
      () {
        final customer = BookingStore.registerWalkInCustomer(
          name: 'Walk-In Receipt Test',
          phone: '555-010-2030',
          email: 'receipt-test@example.com',
        );
        final duplicate = BookingStore.registerWalkInCustomer(
          name: 'Another Name',
          phone: '5550102030',
        );
        expect(duplicate['id'], customer['id']);

        final service = BookingStore.allServices.first;
        final date = DateTime(2033, 2, 4);
        final therapist = BookingStore.therapists.first;
        BookingStore.toggleTherapistAvailability(date, therapist);
        BookingStore.createWalkInReservation(
          customer: customer,
          service: service,
          therapist: therapist,
          date: date,
          time: '11:00 AM',
        );
        final reservation = BookingStore.allBookings.first;
        final paymentReceipt = BookingStore.recordPayment(
          reservationId: reservation['id'] as String,
          amount: 100,
        );
        expect(paymentReceipt['reservationType'], 'Walk-In');
        expect(paymentReceipt['paymentStatus'], 'Down Payment');
        expect(reservation['paymentStatus'], 'Unpaid');

        final refundReceipt = BookingStore.refundPayment(
          reservation['id'] as String,
        );
        expect(refundReceipt['paymentStatus'], 'Refunded');
        expect(refundReceipt['amountPaid'], -100.0);

        final queueEntry = BookingStore.addWalkInToQueue(
          customer: customer,
          service: service,
        );
        BookingStore.updateWalkInQueueStatus(
          queueId: queueEntry['id'] as String,
          status: 'Cancelled',
        );
        expect(
          BookingStore.walkInQueue.singleWhere(
            (entry) => entry['id'] == queueEntry['id'],
          )['status'],
          'Cancelled',
        );
      },
    );

    test('records walk-ins without creating reservations', () {
      final today = DateTime.now();
      final therapist = BookingStore.therapists.first;
      final wasAvailable = BookingStore.therapistsAvailableOn(today)
          .contains(therapist);
      if (!wasAvailable) {
        BookingStore.toggleTherapistAvailability(today, therapist);
      }
      final bookingCount = BookingStore.allBookings.length;
      final service = BookingStore.allServices.first;

      final entry = BookingStore.addWalkInEntry(
        customerName: 'Walk-In Ledger Test',
        serviceId: service['id'] as String,
        therapist: therapist,
        amountReceived: 125,
      );

      expect(entry['customerName'], 'Walk-In Ledger Test');
      expect(entry['service'], service['name']);
      expect(entry['therapist'], therapist);
      expect(entry['amountReceived'], 125.0);
      expect(entry['paymentStatus'], 'Down Payment');
      expect(BookingStore.allBookings, hasLength(bookingCount));
      expect(
        BookingStore.walkInEntries.any((item) => item['id'] == entry['id']),
        isTrue,
      );

      if (!wasAvailable) {
        BookingStore.toggleTherapistAvailability(today, therapist);
      }
    });
  });
}
