import 'booking_store.dart';

enum SalesPeriod { daily, weekly, monthly, yearly, custom }

class SalesBucket {
  final String label;
  final double sales;
  final int reservations;
  final int completed;
  final int walkIns;
  final int online;

  const SalesBucket({
    required this.label,
    required this.sales,
    required this.reservations,
    required this.completed,
    required this.walkIns,
    required this.online,
  });
}

class SalesBreakdown {
  final String name;
  final int reservations;
  final double sales;
  final double amount;

  const SalesBreakdown({
    required this.name,
    required this.reservations,
    required this.sales,
    required this.amount,
  });
}

class SalesAnalytics {
  final DateTime startDate;
  final DateTime endDate;
  final List<SalesBucket> trend;
  final Map<String, int> statuses;
  final List<SalesBreakdown> services;
  final List<SalesBreakdown> sources;
  final List<SalesBreakdown> payments;
  final int reservations;
  final int completed;
  final int cancelled;
  final int noShow;
  final int uniqueCustomers;
  final int walkIns;
  final int online;
  final double totalSales;
  final double totalServiceValue;
  final double totalPaid;
  final double totalRefunded;
  final double totalUnpaid;
  final double downPayments;

  const SalesAnalytics({
    required this.startDate,
    required this.endDate,
    required this.trend,
    required this.statuses,
    required this.services,
    required this.sources,
    required this.payments,
    required this.reservations,
    required this.completed,
    required this.cancelled,
    required this.noShow,
    required this.uniqueCustomers,
    required this.walkIns,
    required this.online,
    required this.totalSales,
    required this.totalServiceValue,
    required this.totalPaid,
    required this.totalRefunded,
    required this.totalUnpaid,
    required this.downPayments,
  });

  bool get hasReservationData => reservations > 0;
  bool get hasSalesData =>
      totalSales != 0 || totalPaid != 0 || totalRefunded > 0;
}

class SalesAnalyticsService {
  SalesAnalyticsService._();

  static SalesAnalytics calculate({
    required SalesPeriod period,
    required DateTime anchor,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final range = _range(period, anchor, customStart, customEnd);
    final start = range.$1;
    final end = range.$2;
    final allBookings = BookingStore.allBookings;
    final bookings = allBookings
        .where((booking) {
          final date = _parseDate(booking['date']);
          return date != null && _inRange(date, start, end);
        })
        .toList(growable: false);

    final receiptKeys = <String>{};
    final receiptReservationIds = <String>{};
    final paidByReservation = <String, double>{};
    final refundedByReservation = <String, double>{};
    var totalPaid = 0.0;
    var totalRefunded = 0.0;
    final bucketMap = _makeBuckets(period, start, end);
    final transactionServiceSales = <String, double>{};
    final transactionSourceSales = <String, double>{'Walk-In': 0, 'Online': 0};

    Map<String, dynamic>? findBooking(String? id) {
      if (id == null) return null;
      for (final booking in allBookings) {
        if (booking['id']?.toString() == id) return booking;
      }
      return null;
    }

    for (final receipt in BookingStore.receipts) {
      final key = receipt['receiptNumber']?.toString();
      final fallbackKey =
          '${receipt['reservationNumber']}|${receipt['transactionAt']}|${receipt['amountPaid']}';
      if (!receiptKeys.add(key == null || key.isEmpty ? fallbackKey : key)) {
        continue;
      }
      final id = receipt['reservationNumber']?.toString();
      if (id != null) receiptReservationIds.add(id);
      final date = DateTime.tryParse(
        receipt['transactionAt']?.toString() ?? '',
      );
      final amount = (receipt['amountPaid'] as num?)?.toDouble() ?? 0;
      if (id != null) {
        paidByReservation.update(
          id,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
        if (amount < 0) {
          refundedByReservation.update(
            id,
            (value) => value - amount,
            ifAbsent: () => -amount,
          );
        }
      }
      if (date != null && _inRange(date, start, end)) {
        if (amount < 0) {
          totalRefunded -= amount;
        } else {
          totalPaid += amount;
        }
        final bucket = _bucketFor(bucketMap, period, start, end, date);
        if (bucket != null) bucket.sales += amount;

        final booking = findBooking(id);
        final serviceName =
            booking?['service']?.toString() ??
            receipt['service']?.toString() ??
            'Unknown service';
        transactionServiceSales.update(
          serviceName,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
        final source =
            (booking?['reservationType'] ?? receipt['reservationType']) ==
                'Walk-In'
            ? 'Walk-In'
            : 'Online';
        transactionSourceSales.update(
          source,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      }
    }

    for (final booking in bookings) {
      final id = booking['id']?.toString();
      if (id == null || receiptReservationIds.contains(id)) continue;
      final recordedDate = DateTime.tryParse(
        booking['paymentRecordedAt']?.toString() ?? '',
      );
      if (recordedDate == null || !_inRange(recordedDate, start, end)) continue;
      final legacyPaid = (booking['amountPaid'] as num?)?.toDouble() ?? 0;
      totalPaid += legacyPaid;
      paidByReservation[id] = legacyPaid;
      final bucket = _bucketFor(bucketMap, period, start, end, recordedDate);
      if (bucket != null) bucket.sales += legacyPaid;
      final serviceName = booking['service']?.toString() ?? 'Unknown service';
      transactionServiceSales.update(
        serviceName,
        (value) => value + legacyPaid,
        ifAbsent: () => legacyPaid,
      );
      final source = booking['reservationType'] == 'Walk-In'
          ? 'Walk-In'
          : 'Online';
      transactionSourceSales.update(
        source,
        (value) => value + legacyPaid,
        ifAbsent: () => legacyPaid,
      );
    }

    final walkInEntries = BookingStore.walkInEntries
        .where((entry) {
          final date = _parseDate(entry['date']);
          return date != null && _inRange(date, start, end);
        })
        .toList(growable: false);
    for (final entry in walkInEntries) {
      final amount = (entry['amountReceived'] as num?)?.toDouble() ?? 0;
      final createdAt = DateTime.tryParse(entry['createdAt']?.toString() ?? '');
      final transactionDate = createdAt ?? _parseDate(entry['date']);
      totalPaid += amount;
      if (transactionDate != null) {
        final bucket = _bucketFor(
          bucketMap,
          period,
          start,
          end,
          transactionDate,
        );
        if (bucket != null) bucket.sales += amount;
      }
      final serviceName = entry['service']?.toString() ?? 'Unknown service';
      transactionServiceSales.update(
        serviceName,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
      transactionSourceSales.update(
        'Walk-In',
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    final statuses = <String, int>{
      'Confirmed': 0,
      'Completed': 0,
      'Cancelled': 0,
      'No-Show': 0,
      'Pending': 0,
      'Ongoing': 0,
      'Waiting': 0,
    };
    final serviceData = <String, _Accumulator>{};
    final sourceData = <String, _Accumulator>{
      'Walk-In': _Accumulator(),
      'Online': _Accumulator(),
    };
    final paymentData = <String, _Accumulator>{
      'Fully Paid': _Accumulator(),
      'Down Payment': _Accumulator(),
      'Unpaid': _Accumulator(),
      'Refunded': _Accumulator(),
    };
    final uniqueCustomers = <String>{};
    var totalServiceValue = 0.0;
    var totalUnpaid = 0.0;
    var downPayments = 0.0;
    var completed = 0;
    var cancelled = 0;
    var noShow = 0;
    var walkIns = 0;
    var online = 0;

    for (final booking in bookings) {
      final status = booking['status']?.toString() ?? 'Pending';
      statuses[status] = (statuses[status] ?? 0) + 1;
      final customerKey =
          booking['customerId']?.toString().trim().isNotEmpty == true
          ? booking['customerId'].toString()
          : (booking['customerEmail']?.toString().trim().isNotEmpty == true
                ? booking['customerEmail'].toString().toLowerCase()
                : booking['customerName']?.toString());
      if (customerKey != null && customerKey.isNotEmpty) {
        uniqueCustomers.add(customerKey);
      }

      final price = (booking['price'] as num?)?.toDouble() ?? 0;
      final bookingId = booking['id']?.toString();
      final bookingPaid = bookingId == null
          ? (booking['amountPaid'] as num?)?.toDouble() ?? 0
          : paidByReservation[bookingId] ??
                (booking['amountPaid'] as num?)?.toDouble() ??
                0;
      final storedPaymentStatus = booking['paymentStatus']?.toString();
      final paymentStatus =
          storedPaymentStatus ??
          (bookingPaid >= price && price > 0
              ? 'Fully Paid'
              : bookingPaid > 0
              ? 'Down Payment'
              : 'Unpaid');
      final eligibleForSales = status != 'Cancelled' && status != 'No-Show';
      if (status == 'Completed') {
        completed++;
        totalServiceValue += price;
      }
      if (status == 'Cancelled') cancelled++;
      if (status == 'No-Show') noShow++;

      final source = booking['reservationType'] == 'Walk-In'
          ? 'Walk-In'
          : 'Online';
      if (source == 'Walk-In') {
        walkIns++;
      } else {
        online++;
      }
      final serviceName = booking['service']?.toString() ?? 'Unknown service';
      final serviceAccumulator = serviceData.putIfAbsent(
        serviceName,
        _Accumulator.new,
      );
      serviceAccumulator.reservations++;
      serviceAccumulator.sales = transactionServiceSales[serviceName] ?? 0;
      final sourceAccumulator = sourceData[source]!;
      sourceAccumulator.reservations++;
      sourceAccumulator.sales = transactionSourceSales[source] ?? 0;

      if (eligibleForSales) {
        final remaining = (price - bookingPaid).clamp(0, price).toDouble();
        totalUnpaid += remaining;
      }
      if (paymentStatus == 'Down Payment') {
        downPayments += bookingPaid;
      }
      final displayPaymentStatus = paymentStatus;
      final paymentAccumulator = paymentData.putIfAbsent(
        displayPaymentStatus,
        _Accumulator.new,
      );
      paymentAccumulator.reservations++;
      paymentAccumulator.amount += switch (displayPaymentStatus) {
        'Refunded' => refundedByReservation[bookingId] ?? 0,
        'Unpaid' =>
          eligibleForSales
              ? (price - bookingPaid).clamp(0, price).toDouble()
              : 0,
        _ => bookingPaid,
      };

      final bookingDate = _parseDate(booking['date']);
      final appointmentDateTime = bookingDate == null
          ? null
          : _appointmentDateTime(bookingDate, booking['time']?.toString());
      final bucketDate = period == SalesPeriod.daily
          ? appointmentDateTime
          : bookingDate;
      final bucket = bucketDate == null
          ? null
          : _bucketFor(bucketMap, period, start, end, bucketDate);
      if (bucket != null) {
        bucket.reservations++;
        if (status == 'Completed') {
          bucket.completed++;
        }
        if (source == 'Walk-In') {
          bucket.walkIns++;
        } else {
          bucket.online++;
        }
      }
    }

    for (final entry in walkInEntries) {
      final customerName = entry['customerName']?.toString();
      if (customerName != null && customerName.isNotEmpty) {
        uniqueCustomers.add(customerName);
      }
      walkIns++;
      final serviceName = entry['service']?.toString() ?? 'Unknown service';
      serviceData.putIfAbsent(serviceName, _Accumulator.new).reservations++;
      sourceData['Walk-In']!.reservations++;

      final amount = (entry['amountReceived'] as num?)?.toDouble() ?? 0;
      final remaining = (entry['remainingBalance'] as num?)?.toDouble() ?? 0;
      totalUnpaid += remaining;
      final paymentStatus = entry['paymentStatus']?.toString() ?? 'Unpaid';
      if (paymentStatus == 'Down Payment') downPayments += amount;
      final paymentAccumulator = paymentData.putIfAbsent(
        paymentStatus,
        _Accumulator.new,
      );
      paymentAccumulator.reservations++;
      paymentAccumulator.amount += switch (paymentStatus) {
        'Refunded' => 0,
        'Unpaid' => remaining,
        _ => amount,
      };

      final visitDate = _parseDate(entry['date']);
      if (visitDate != null) {
        final bucket = _bucketFor(bucketMap, period, start, end, visitDate);
        if (bucket != null) {
          bucket.reservations++;
          bucket.walkIns++;
        }
      }
    }

    final waitingQueue = BookingStore.walkInQueue
        .where((entry) {
          final queueDate = _parseDate(entry['date']);
          return entry['status'] == 'Waiting' &&
              queueDate != null &&
              _inRange(queueDate, start, end);
        })
        .toList(growable: false);
    statuses['Waiting'] = waitingQueue.length;
    for (final entry in waitingQueue) {
      final customerId = entry['customerId']?.toString();
      final customerName = entry['customerName']?.toString();
      final key = customerId ?? customerName;
      if (key != null && key.isNotEmpty) uniqueCustomers.add(key);
      walkIns++;
      final name = entry['service']?.toString() ?? 'Unknown service';
      serviceData.putIfAbsent(name, _Accumulator.new).reservations++;
      sourceData['Walk-In']!.reservations++;
      final queueDate = _parseDate(entry['date']);
      if (queueDate != null) {
        final bucket = _bucketFor(bucketMap, period, start, end, queueDate);
        if (bucket != null) {
          bucket.reservations++;
          bucket.walkIns++;
        }
      }
    }

    for (final entry in transactionServiceSales.entries) {
      serviceData.putIfAbsent(entry.key, _Accumulator.new).sales = entry.value;
    }
    for (final entry in transactionSourceSales.entries) {
      sourceData[entry.key]!.sales = entry.value;
    }

    return SalesAnalytics(
      startDate: start,
      endDate: end,
      trend: bucketMap
          .map(
            (bucket) => SalesBucket(
              label: bucket.label,
              sales: bucket.sales,
              reservations: bucket.reservations,
              completed: bucket.completed,
              walkIns: bucket.walkIns,
              online: bucket.online,
            ),
          )
          .toList(growable: false),
      statuses: Map.unmodifiable(statuses),
      services: serviceData.entries
          .map(
            (entry) => SalesBreakdown(
              name: entry.key,
              reservations: entry.value.reservations,
              sales: entry.value.sales,
              amount: entry.value.amount,
            ),
          )
          .toList(growable: false),
      sources: sourceData.entries
          .map(
            (entry) => SalesBreakdown(
              name: entry.key,
              reservations: entry.value.reservations,
              sales: entry.value.sales,
              amount: entry.value.amount,
            ),
          )
          .toList(growable: false),
      payments: paymentData.entries
          .map(
            (entry) => SalesBreakdown(
              name: entry.key,
              reservations: entry.value.reservations,
              sales: 0,
              amount: entry.value.amount,
            ),
          )
          .toList(growable: false),
      reservations:
          bookings.length + waitingQueue.length + walkInEntries.length,
      completed: completed,
      cancelled: cancelled,
      noShow: noShow,
      uniqueCustomers: uniqueCustomers.length,
      walkIns: walkIns,
      online: online,
      totalSales: totalPaid - totalRefunded,
      totalServiceValue: totalServiceValue,
      totalPaid: totalPaid,
      totalRefunded: totalRefunded,
      totalUnpaid: totalUnpaid,
      downPayments: downPayments,
    );
  }

  static (DateTime, DateTime) _range(
    SalesPeriod period,
    DateTime anchor,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    switch (period) {
      case SalesPeriod.daily:
        return (
          day,
          day
              .add(const Duration(days: 1))
              .subtract(const Duration(microseconds: 1)),
        );
      case SalesPeriod.weekly:
        final start = day.subtract(
          Duration(days: day.weekday - DateTime.monday),
        );
        return (
          start,
          start
              .add(const Duration(days: 7))
              .subtract(const Duration(microseconds: 1)),
        );
      case SalesPeriod.monthly:
        final start = DateTime(anchor.year, anchor.month);
        return (
          start,
          DateTime(
            anchor.year,
            anchor.month + 1,
          ).subtract(const Duration(microseconds: 1)),
        );
      case SalesPeriod.yearly:
        return (
          DateTime(anchor.year),
          DateTime(anchor.year + 1).subtract(const Duration(microseconds: 1)),
        );
      case SalesPeriod.custom:
        final start = customStart ?? day;
        final finish = customEnd ?? start;
        final normalizedStart = DateTime(start.year, start.month, start.day);
        final normalizedEnd = DateTime(finish.year, finish.month, finish.day)
            .add(const Duration(days: 1))
            .subtract(const Duration(microseconds: 1));
        return normalizedStart.isAfter(normalizedEnd)
            ? (
                DateTime(finish.year, finish.month, finish.day),
                normalizedStart
                    .add(const Duration(days: 1))
                    .subtract(const Duration(microseconds: 1)),
              )
            : (normalizedStart, normalizedEnd);
    }
  }

  static bool _inRange(DateTime date, DateTime start, DateTime end) =>
      !date.isBefore(start) && !date.isAfter(end);

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static DateTime? _appointmentDateTime(DateTime date, String? time) {
    if (time == null) return date;
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(time.trim());
    if (match == null) return date;
    final parsedHour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (parsedHour == null ||
        minute == null ||
        parsedHour < 1 ||
        parsedHour > 12 ||
        minute > 59) {
      return date;
    }
    final hour =
        parsedHour % 12 + (match.group(3)!.toUpperCase() == 'PM' ? 12 : 0);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static List<_MutableBucket> _makeBuckets(
    SalesPeriod period,
    DateTime start,
    DateTime end,
  ) {
    if (period == SalesPeriod.daily) {
      return List.generate(
        24,
        (index) => _MutableBucket('${index.toString().padLeft(2, '0')}:00'),
      );
    }
    if (period == SalesPeriod.weekly) {
      const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return labels.map(_MutableBucket.new).toList();
    }
    if (period == SalesPeriod.yearly) {
      const labels = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return labels.map(_MutableBucket.new).toList();
    }
    final numberOfDays = end.difference(start).inDays + 1;
    if (numberOfDays <= 31) {
      return List.generate(
        numberOfDays,
        (index) => _MutableBucket('${index + 1}'),
      );
    }
    final weeks = (numberOfDays / 7).ceil();
    return List.generate(weeks, (index) => _MutableBucket('Week ${index + 1}'));
  }

  static _MutableBucket? _bucketFor(
    List<_MutableBucket> buckets,
    SalesPeriod period,
    DateTime start,
    DateTime end,
    DateTime date,
  ) {
    if (period == SalesPeriod.daily) {
      final hour = date.hour;
      return hour >= 0 && hour < buckets.length ? buckets[hour] : null;
    }
    if (period == SalesPeriod.weekly) {
      return buckets[date.weekday - 1];
    }
    if (period == SalesPeriod.yearly) {
      return buckets[date.month - 1];
    }
    final relativeDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(start.year, start.month, start.day)).inDays;
    if (buckets.isNotEmpty && buckets.first.label.startsWith('Week ')) {
      final index = relativeDay ~/ 7;
      return index < buckets.length ? buckets[index] : null;
    }
    final index = relativeDay;
    return index >= 0 && index < buckets.length ? buckets[index] : null;
  }
}

class _Accumulator {
  int reservations = 0;
  double sales = 0;
  double amount = 0;
}

class _MutableBucket {
  final String label;
  double sales = 0;
  int reservations = 0;
  int completed = 0;
  int walkIns = 0;
  int online = 0;

  _MutableBucket(this.label);
}
