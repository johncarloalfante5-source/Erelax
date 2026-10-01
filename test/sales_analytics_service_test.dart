import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_e_relax/core/booking_store.dart';
import 'package:flutter_e_relax/core/sales_analytics_service.dart';

void main() {
  group('sales analytics', () {
    test('returns zeroed period buckets when the store has no records', () {
      final daily = SalesAnalyticsService.calculate(
        period: SalesPeriod.daily,
        anchor: DateTime(2025, 3, 12),
      );
      final weekly = SalesAnalyticsService.calculate(
        period: SalesPeriod.weekly,
        anchor: DateTime(2025, 3, 12),
      );
      final yearly = SalesAnalyticsService.calculate(
        period: SalesPeriod.yearly,
        anchor: DateTime(2025, 3, 12),
      );
      final custom = SalesAnalyticsService.calculate(
        period: SalesPeriod.custom,
        anchor: DateTime(2025, 3, 12),
        customStart: DateTime(2025, 3, 10),
        customEnd: DateTime(2025, 3, 13),
      );

      expect(daily.hasSalesData, isFalse);
      expect(daily.hasReservationData, isFalse);
      expect(daily.trend, hasLength(24));
      expect(weekly.trend.map((bucket) => bucket.label), [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ]);
      expect(yearly.trend, hasLength(12));
      expect(custom.trend, hasLength(4));
      expect(custom.startDate, DateTime(2025, 3, 10));
      expect(custom.endDate, DateTime(2025, 3, 13, 23, 59, 59, 999, 999));
      expect(daily.statuses['Completed'], 0);
    });

    test('counts payment receipts by transaction date, separate from service value', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final therapist = BookingStore.therapists.first;
      BookingStore.toggleTherapistAvailability(tomorrow, therapist);
      final customer = BookingStore.registerWalkInCustomer(
        name: 'Analytics Receipt Customer',
        phone: '555-010-4321',
      );
      final service = BookingStore.allServices.first;
      BookingStore.createWalkInReservation(
        customer: customer,
        service: service,
        therapist: therapist,
        date: tomorrow,
        time: '11:00 AM',
      );
      final reservation = BookingStore.allBookings.first;
      BookingStore.recordPayment(
        reservationId: reservation['id'] as String,
        amount: 100,
      );

      final todayAnalytics = SalesAnalyticsService.calculate(
        period: SalesPeriod.daily,
        anchor: DateTime.now(),
      );
      final paidAt = DateTime.now();

      expect(todayAnalytics.totalPaid, 100);
      expect(todayAnalytics.totalSales, 100);
      expect(todayAnalytics.totalServiceValue, 0);
      expect(todayAnalytics.reservations, 0);
      expect(todayAnalytics.trend[paidAt.hour].sales, 100);
      expect(
        todayAnalytics.sources
            .singleWhere((source) => source.name == 'Walk-In')
            .sales,
        100,
      );
    });

    test('includes independent walk-in sales in sales analytics', () {
      final today = DateTime.now();
      final therapist = BookingStore.therapists.first;
      final service = BookingStore.allServices.first;
      final wasAvailable = BookingStore.therapistsAvailableOn(today)
          .contains(therapist);
      if (!wasAvailable) {
        BookingStore.toggleTherapistAvailability(today, therapist);
      }
      final before = SalesAnalyticsService.calculate(
        period: SalesPeriod.daily,
        anchor: today,
      );

      BookingStore.addWalkInEntry(
        customerName: 'Standalone Walk-In Sales Test',
        serviceId: service['id'] as String,
        therapist: therapist,
        amountReceived: 125,
      );
      final after = SalesAnalyticsService.calculate(
        period: SalesPeriod.daily,
        anchor: today,
      );

      expect(after.totalPaid - before.totalPaid, 125);
      expect(after.totalSales - before.totalSales, 125);
      expect(after.walkIns - before.walkIns, 1);
      expect(after.reservations - before.reservations, 1);
      expect(
        after.trend[today.hour].sales - before.trend[today.hour].sales,
        125,
      );
      expect(
        after.sources.singleWhere((source) => source.name == 'Walk-In').sales -
            before.sources
                .singleWhere((source) => source.name == 'Walk-In')
                .sales,
        125,
      );
      expect(
        after.services
                .singleWhere((item) => item.name == service['name'])
                .sales -
            before.services
                .singleWhere((item) => item.name == service['name'])
                .sales,
        125,
      );
      if (!wasAvailable) {
        BookingStore.toggleTherapistAvailability(today, therapist);
      }
    });
  });
}
