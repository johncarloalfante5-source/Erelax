// Shared booking store — simulates a real backend booking database
// In production, replace with Supabase/Firebase Firestore

import 'booking_time.dart';

class BookingStore {
  BookingStore._();

  static final List<Map<String, dynamic>> _bookings = [];

  static const List<String> therapists = [
    'Alex Rivera',
    'Jamie Santos',
    'Morgan Reyes',
    'Taylor Cruz',
    'Casey Mendoza',
    'Jordan Flores',
    'Riley Garcia',
    'Avery Dela Cruz',
    'Cameron Lopez',
    'Drew Castillo',
    'Parker Ramos',
    'Quinn Navarro',
    'Reese Bautista',
    'Skyler Torres',
    'Rowan Villanueva',
    'Emerson Aquino',
  ];

  static final Map<String, Set<String>> _therapistAvailability = {};

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static List<String> therapistsAvailableOn(DateTime date) =>
      List.unmodifiable(_therapistAvailability[dateKey(date)] ?? <String>{});

  static List<String> bookedTimesFor({
    required DateTime date,
    required String therapist,
  }) => List.unmodifiable(
    _bookings
        .where(
          (booking) =>
              booking['date'] == dateKey(date) &&
              booking['therapist'] == therapist &&
              booking['status'] != 'Cancelled',
        )
        .map((booking) => booking['time'] as String),
  );

  static bool isTimeBooked({
    required DateTime date,
    required String therapist,
    required String startTime,
    required int durationMinutes,
  }) {
    final normalizedTime = BookingTime.normalize(startTime);
    final requestedStart = normalizedTime == null
        ? null
        : _minutesFromTime(normalizedTime);
    if (requestedStart == null || durationMinutes <= 0) return false;
    final requestedEnd = requestedStart + durationMinutes;
    final dateString = dateKey(date);

    return _bookings.any((booking) {
      if (booking['date'] != dateString ||
          booking['therapist'] != therapist ||
          const {
            'Cancelled',
            'Completed',
            'No-Show',
            'Waiting',
          }.contains(booking['status'])) {
        return false;
      }

      final bookedStart = _minutesFromTime(booking['time'] as String? ?? '');
      if (bookedStart == null) return false;
      final bookedDuration = booking['durationMinutes'] as int? ?? 60;
      final bookedEnd = bookedStart + bookedDuration;
      return requestedStart < bookedEnd && bookedStart < requestedEnd;
    });
  }

  static bool isTherapistAvailable({
    required DateTime date,
    required String therapist,
    required String startTime,
    required int durationMinutes,
    String? excludingBookingId,
  }) {
    final normalizedTime = BookingTime.normalize(startTime);
    final requestedStart = normalizedTime == null
        ? null
        : _minutesFromTime(normalizedTime);
    if (requestedStart == null || durationMinutes <= 0) return false;
    final today = DateTime.now();
    final requestedDate = DateTime(date.year, date.month, date.day);
    final currentDate = DateTime(today.year, today.month, today.day);
    if (requestedDate.isBefore(currentDate)) return false;
    if (requestedDate == currentDate &&
        requestedStart <= today.hour * 60 + today.minute) {
      return false;
    }
    final requestedEnd = requestedStart + durationMinutes;
    if (requestedEnd > 20 * 60) return false;
    final dateString = dateKey(date);

    return !_bookings.any((booking) {
      if (booking['id'] == excludingBookingId ||
          booking['date'] != dateString ||
          booking['therapist'] != therapist ||
          const {
            'Cancelled',
            'Completed',
            'No-Show',
            'Waiting',
          }.contains(booking['status'])) {
        return false;
      }

      final bookedStart = _minutesFromTime(booking['time'] as String? ?? '');
      if (bookedStart == null) return false;
      final bookedDuration = booking['durationMinutes'] as int? ?? 60;
      final bookedEnd = bookedStart + bookedDuration;
      return requestedStart < bookedEnd && bookedStart < requestedEnd;
    });
  }

  static int? _minutesFromTime(String value) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null ||
        minute == null ||
        hour < 1 ||
        hour > 12 ||
        minute > 59) {
      return null;
    }
    return (hour % 12) * 60 +
        minute +
        (match.group(3)!.toUpperCase() == 'PM' ? 12 * 60 : 0);
  }

  static void toggleTherapistAvailability(DateTime date, String therapist) {
    if (!therapists.contains(therapist)) return;
    final available = _therapistAvailability.putIfAbsent(
      dateKey(date),
      () => <String>{},
    );
    if (!available.add(therapist)) available.remove(therapist);
    if (available.isEmpty) _therapistAvailability.remove(dateKey(date));
  }

  // ── Customers ──────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _customers = [];
  static final List<Map<String, dynamic>> _walkInQueue = [];
  static final List<Map<String, dynamic>> _walkInEntries = [];
  static final List<Map<String, dynamic>> _receipts = [];

  static List<Map<String, dynamic>> get walkInQueue =>
      List.unmodifiable(_walkInQueue);

  static List<Map<String, dynamic>> get walkInEntries =>
      List.unmodifiable(_walkInEntries);

  static List<Map<String, dynamic>> get receipts =>
      List.unmodifiable(_receipts);

  // ── Services ───────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _services = [
    {
      'id': 'svc_001',
      'name': 'Whole Body Massage',
      'description': 'Full relaxation from head to toe. Relieves muscle tension, improves circulation, and promotes deep stress relief.',
      'durationMinutes': 60,
      'price': 350.0,
      'category': 'Body',
      'isActive': true,
      'bookingCount': 42,
    },
    {
      'id': 'svc_002',
      'name': 'Laying/Back Massage',
      'description': 'Targeted relief for the back and spine. Perfect for office workers and those with chronic back pain.',
      'durationMinutes': 30,
      'price': 180.0,
      'category': 'Back',
      'isActive': true,
      'bookingCount': 28,
    },
    {
      'id': 'svc_003',
      'name': 'Foot Massage (60 min)',
      'description': 'Deep pressure reflexology targeting key foot zones to relieve whole-body tension and fatigue.',
      'durationMinutes': 60,
      'price': 350.0,
      'category': 'Foot',
      'isActive': true,
      'bookingCount': 35,
    },
    {
      'id': 'svc_004',
      'name': 'Foot Massage (30 min)',
      'description': 'Express foot relief session — ideal for a quick refresh between meetings or after a long day.',
      'durationMinutes': 30,
      'price': 180.0,
      'category': 'Foot',
      'isActive': true,
      'bookingCount': 19,
    },
  ];

  // ── Bookings ───────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> get allBookings =>
      List.unmodifiable(_bookings);

  static void addBooking(Map<String, dynamic> booking) {
    final therapist = booking['therapist'];
    final date = booking['date'];
    final time = booking['time'];
    if (therapist is! String || date is! String || time is! String) {
      throw StateError(
        'Reservation requires a therapist, date, and start time.',
      );
    }
    final parsedDate = DateTime.tryParse(date);
    final duration = booking['durationMinutes'] as int? ?? 60;
    final normalizedTime = BookingTime.normalize(time);
    final startMinute = normalizedTime == null
        ? null
        : _minutesFromTime(normalizedTime);
    if (parsedDate == null ||
        normalizedTime == null ||
        duration <= 0 ||
        startMinute == null ||
        startMinute + duration > 20 * 60) {
      throw StateError('Enter a valid reservation date, time, and duration.');
    }
    if (!therapistsAvailableOn(parsedDate).contains(therapist)) {
      throw StateError('The selected therapist is not scheduled on this date.');
    }
    if (isTimeBooked(
      date: parsedDate,
      therapist: therapist,
      startTime: normalizedTime,
      durationMinutes: duration,
    )) {
      throw StateError(
        'The selected therapist already has a booking during this time.',
      );
    }

    booking.putIfAbsent('reservationType', () => 'Online');
    booking.putIfAbsent('paymentStatus', () => 'Unpaid');
    _bookings.insert(0, Map<String, dynamic>.from(booking));
    // Increment customer booking count if customer exists
    final bookingCustomerId = booking['customerId'];
    final custIndex = _customers.indexWhere((customer) {
      if (bookingCustomerId != null) return customer['id'] == bookingCustomerId;
      return customer['name'] == booking['customerName'];
    });
    if (custIndex != -1) {
      _customers[custIndex] = Map<String, dynamic>.from(_customers[custIndex])
        ..['totalBookings'] =
            (_customers[custIndex]['totalBookings'] as int) + 1;
    }
    // Increment service booking count
    final svcIndex = _services.indexWhere(
      (s) => s['name'] == booking['service'],
    );
    if (svcIndex != -1) {
      _services[svcIndex] = Map<String, dynamic>.from(_services[svcIndex])
        ..['bookingCount'] = (_services[svcIndex]['bookingCount'] as int) + 1;
    }
  }

  static void updateStatus(String bookingId, String newStatus) {
    final index = _bookings.indexWhere((b) => b['id'] == bookingId);
    if (index != -1) {
      _bookings[index] = Map<String, dynamic>.from(_bookings[index])
        ..['status'] = newStatus;
      final queueIndex = _walkInQueue.indexWhere(
        (item) => item['reservationId'] == bookingId,
      );
      if (queueIndex != -1) {
        final queueStatus = switch (newStatus) {
          'Ongoing' => 'In Service',
          'Completed' => 'Completed',
          'Cancelled' => 'Cancelled',
          'No-Show' => 'Cancelled',
          _ => null,
        };
        if (queueStatus != null) {
          _walkInQueue[queueIndex] = Map<String, dynamic>.from(
            _walkInQueue[queueIndex],
          )..['status'] = queueStatus;
        }
      }
    }
  }

  // ── Customers ──────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> get allCustomers =>
      List.unmodifiable(_customers);

  static void addCustomer({
    required String name,
    required String email,
    required String phone,
    String notes = '',
  }) {
    _customers.add({
      'id': 'cust_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'email': email,
      'phone': phone,
      'notes': notes,
      'joinedAt': DateTime.now().toIso8601String().substring(0, 10),
      'totalBookings': 0,
      'isActive': true,
    });
  }

  static List<Map<String, dynamic>> findCustomers(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return const [];
    return List.unmodifiable(
      _customers.where((customer) {
        final name = (customer['name'] as String? ?? '').toLowerCase();
        final phone = (customer['phone'] as String? ?? '').toLowerCase();
        return name.contains(normalizedQuery) ||
            phone.contains(normalizedQuery);
      }),
    );
  }

  static Map<String, dynamic> registerWalkInCustomer({
    required String name,
    required String phone,
    String email = '',
    String notes = '',
  }) {
    final normalizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    final duplicate = _customers.where((customer) {
      final existingPhone = (customer['phone'] as String? ?? '').replaceAll(
        RegExp(r'\D'),
        '',
      );
      final existingEmail = (customer['email'] as String? ?? '')
          .trim()
          .toLowerCase();
      return normalizedPhone.isNotEmpty && existingPhone == normalizedPhone ||
          email.trim().isNotEmpty &&
              existingEmail == email.trim().toLowerCase();
    });
    if (duplicate.isNotEmpty) return Map.unmodifiable(duplicate.first);

    final customer = <String, dynamic>{
      'id': 'cust_${DateTime.now().microsecondsSinceEpoch}',
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'notes': notes.trim(),
      'joinedAt': DateTime.now().toIso8601String().substring(0, 10),
      'totalBookings': 0,
      'isActive': true,
    };
    _customers.add(customer);
    return Map.unmodifiable(customer);
  }

  static List<Map<String, dynamic>> reservationHistory(
    Map<String, dynamic> customer,
  ) {
    final customerId = customer['id'];
    final customerEmail = customer['email'];
    final customerName = customer['name'];
    final customerPhone = customer['phone'];
    return List.unmodifiable(
      _bookings.where((booking) {
        return customerId != null && booking['customerId'] == customerId ||
            customerEmail != null &&
                customerEmail.toString().isNotEmpty &&
                booking['customerEmail'] == customerEmail ||
            customerName != null &&
                booking['customerName'] == customerName &&
                (customerPhone == null ||
                    booking['customerPhone'] == customerPhone);
      }),
    );
  }

  static List<String> availableTherapistsFor({
    required DateTime date,
    required String time,
    required int durationMinutes,
  }) => therapistsAvailableOn(date)
      .where(
        (therapist) => isTherapistAvailable(
          date: date,
          therapist: therapist,
          startTime: time,
          durationMinutes: durationMinutes,
        ),
      )
      .toList(growable: false);

  static void createWalkInReservation({
    required Map<String, dynamic> customer,
    required Map<String, dynamic> service,
    required String therapist,
    required DateTime date,
    required String time,
    String notes = '',
  }) {
    final reservationId =
        'WI${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    addBooking({
      'id': reservationId,
      'customerId': customer['id'],
      'customerName': customer['name'],
      'customerEmail': customer['email'],
      'customerPhone': customer['phone'],
      'serviceId': service['id'],
      'service': service['name'],
      'durationMinutes': service['durationMinutes'],
      'price': service['price'],
      'therapist': therapist,
      'therapistPreference': therapist,
      'date': dateKey(date),
      'time': time,
      'status': 'Confirmed',
      'reservationType': 'Walk-In',
      'paymentStatus': 'Unpaid',
      'amountPaid': 0.0,
      'remainingBalance': service['price'],
      'notes': notes.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static Map<String, dynamic> addWalkInToQueue({
    required Map<String, dynamic> customer,
    required Map<String, dynamic> service,
    String? preferredTherapist,
    String notes = '',
  }) {
    final date = dateKey(DateTime.now());
    final queueNumber =
        _walkInQueue.where((item) => item['date'] == date).length + 1;
    final entry = <String, dynamic>{
      'id': 'WQ${DateTime.now().microsecondsSinceEpoch}',
      'customerId': customer['id'],
      'customerName': customer['name'],
      'customerPhone': customer['phone'],
      'serviceId': service['id'],
      'service': service['name'],
      'durationMinutes': service['durationMinutes'],
      'price': service['price'],
      'preferredTherapist': preferredTherapist,
      'queueNumber': queueNumber,
      'date': date,
      'addedAt': DateTime.now().toIso8601String(),
      'status': 'Waiting',
      'notes': notes.trim(),
    };
    _walkInQueue.add(entry);
    return Map.unmodifiable(entry);
  }

  static Map<String, dynamic> addWalkInEntry({
    required String customerName,
    required String serviceId,
    required String therapist,
    required double amountReceived,
  }) {
    final name = customerName.trim();
    if (name.isEmpty) throw ArgumentError('Enter the customer name.');
    final serviceIndex = _services.indexWhere(
      (service) => service['id'] == serviceId && service['isActive'] == true,
    );
    if (serviceIndex == -1) throw ArgumentError('Choose an active service.');
    final today = DateTime.now();
    if (!therapistsAvailableOn(today).contains(therapist)) {
      throw StateError('Choose a therapist scheduled to work today.');
    }

    final service = _services[serviceIndex];
    final price = (service['price'] as num).toDouble();
    if (!amountReceived.isFinite ||
        amountReceived < 0 ||
        amountReceived > price) {
      throw ArgumentError(
        'Amount received must be between ₱0 and the service price.',
      );
    }
    final balance = price - amountReceived;
    final entry = <String, dynamic>{
      'id': 'WI${DateTime.now().microsecondsSinceEpoch}',
      'customerName': name,
      'serviceId': serviceId,
      'service': service['name'],
      'therapist': therapist,
      'servicePrice': price,
      'amountReceived': amountReceived,
      'remainingBalance': balance,
      'paymentStatus': balance == 0
          ? 'Fully Paid'
          : amountReceived == 0
          ? 'Unpaid'
          : 'Down Payment',
      'date': dateKey(today),
      'createdAt': DateTime.now().toIso8601String(),
    };
    _walkInEntries.insert(0, entry);
    return Map.unmodifiable(entry);
  }

  static void updateWalkInQueueStatus({
    required String queueId,
    required String status,
  }) {
    const allowedStatuses = {
      'Waiting',
      'Assigned',
      'In Service',
      'Completed',
      'Cancelled',
    };
    if (!allowedStatuses.contains(status)) {
      throw ArgumentError.value(status, 'status', 'Unsupported queue status.');
    }
    final index = _walkInQueue.indexWhere((item) => item['id'] == queueId);
    if (index == -1) throw StateError('Queue entry not found.');
    if (_walkInQueue[index]['status'] != 'Waiting' && status == 'Waiting') {
      throw StateError('An assigned queue entry cannot return to Waiting.');
    }
    _walkInQueue[index] = Map<String, dynamic>.from(_walkInQueue[index])
      ..['status'] = status;
  }

  static void assignQueuedWalkIn({
    required String queueId,
    required String therapist,
    required DateTime date,
    required String time,
  }) {
    final index = _walkInQueue.indexWhere((item) => item['id'] == queueId);
    if (index == -1 || _walkInQueue[index]['status'] != 'Waiting') {
      throw StateError('This customer is no longer waiting in the queue.');
    }
    final item = _walkInQueue[index];
    final customer = _customers.firstWhere(
      (entry) => entry['id'] == item['customerId'],
    );
    final service = _services.firstWhere(
      (entry) => entry['id'] == item['serviceId'],
    );
    createWalkInReservation(
      customer: customer,
      service: service,
      therapist: therapist,
      date: date,
      time: time,
      notes: item['notes'] as String? ?? '',
    );
    _walkInQueue[index] = Map<String, dynamic>.from(item)
      ..['status'] = 'Assigned'
      ..['therapist'] = therapist
      ..['reservationId'] = _bookings.first['id'];
  }

  static Map<String, dynamic> recordPayment({
    required String reservationId,
    required double amount,
  }) {
    final index = _bookings.indexWhere((item) => item['id'] == reservationId);
    if (index == -1) throw StateError('Reservation not found.');
    final booking = Map<String, dynamic>.from(_bookings[index]);
    final total = (booking['price'] as num?)?.toDouble() ?? 0;
    final previouslyPaid = (booking['amountPaid'] as num?)?.toDouble() ?? 0;
    if (amount <= 0 || previouslyPaid + amount > total) {
      throw ArgumentError(
        'Enter an amount greater than zero up to the balance.',
      );
    }
    final totalPaid = previouslyPaid + amount;
    final balance = (total - totalPaid).clamp(0, total).toDouble();
    final paymentStatus = balance == 0 ? 'Fully Paid' : 'Down Payment';
    final transactionTime = DateTime.now().toIso8601String();
    booking
      ..['amountPaid'] = totalPaid
      ..['remainingBalance'] = balance
      ..['paymentStatus'] = paymentStatus
      ..['paymentRecordedAt'] = transactionTime;
    _bookings[index] = booking;

    final receipt = <String, dynamic>{
      'receiptNumber': 'RC${DateTime.now().millisecondsSinceEpoch}',
      'customerName': booking['customerName'],
      'reservationNumber': booking['id'],
      'service': booking['service'],
      'therapist': booking['therapist'],
      'date': booking['date'],
      'time': booking['time'],
      'servicePrice': total,
      'amountPaid': amount,
      'remainingBalance': balance,
      'paymentStatus': paymentStatus,
      'reservationType': booking['reservationType'] ?? 'Online',
      'transactionAt': transactionTime,
    };
    _receipts.insert(0, receipt);
    return Map.unmodifiable(receipt);
  }

  static Map<String, dynamic> refundPayment(String reservationId) {
    final index = _bookings.indexWhere((item) => item['id'] == reservationId);
    if (index == -1) throw StateError('Reservation not found.');
    final booking = Map<String, dynamic>.from(_bookings[index]);
    final paid = (booking['amountPaid'] as num?)?.toDouble() ?? 0;
    if (paid <= 0) throw StateError('There is no recorded payment to refund.');
    final transactionTime = DateTime.now().toIso8601String();
    booking
      ..['amountPaid'] = 0.0
      ..['remainingBalance'] = (booking['price'] as num).toDouble()
      ..['paymentStatus'] = 'Refunded'
      ..['refundedAt'] = transactionTime;
    _bookings[index] = booking;

    final receipt = <String, dynamic>{
      'receiptNumber': 'RF${DateTime.now().microsecondsSinceEpoch}',
      'customerName': booking['customerName'],
      'reservationNumber': booking['id'],
      'service': booking['service'],
      'therapist': booking['therapist'],
      'date': booking['date'],
      'time': booking['time'],
      'servicePrice': booking['price'],
      'amountPaid': -paid,
      'remainingBalance': booking['remainingBalance'],
      'paymentStatus': 'Refunded',
      'reservationType': booking['reservationType'] ?? 'Online',
      'transactionAt': transactionTime,
    };
    _receipts.insert(0, receipt);
    return Map.unmodifiable(receipt);
  }

  static List<Map<String, dynamic>> bookingsForDate(DateTime date) =>
      List.unmodifiable(
        _bookings.where((booking) {
          return booking['date'] == dateKey(date);
        }),
      );

  static List<Map<String, dynamic>> get todayWalkIns => List.unmodifiable(
    bookingsForDate(DateTime.now()).where((booking) {
      return booking['reservationType'] == 'Walk-In';
    }),
  );

  static void toggleCustomerStatus(String customerId) {
    final index = _customers.indexWhere((c) => c['id'] == customerId);
    if (index != -1) {
      final current = _customers[index]['isActive'] as bool;
      _customers[index] = Map<String, dynamic>.from(_customers[index])
        ..['isActive'] = !current;
    }
  }

  // ── Services ───────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> get allServices =>
      List.unmodifiable(_services);

  static void updateService(String serviceId, Map<String, dynamic> updates) {
    final index = _services.indexWhere((s) => s['id'] == serviceId);
    if (index != -1) {
      _services[index] = Map<String, dynamic>.from(_services[index])
        ..addAll(updates);
    }
  }

  static void addService(Map<String, dynamic> service) {
    _services.add(Map<String, dynamic>.from(service));
  }

  static void toggleServiceStatus(String serviceId) {
    final index = _services.indexWhere((s) => s['id'] == serviceId);
    if (index != -1) {
      final current = _services[index]['isActive'] as bool;
      _services[index] = Map<String, dynamic>.from(_services[index])
        ..['isActive'] = !current;
    }
  }

  // ── Stats ──────────────────────────────────────────────────────────────────
  static int get totalBookings => _bookings.length;
  static int get pendingCount =>
      _bookings.where((b) => b['status'] == 'Pending').length;
  static int get confirmedCount =>
      _bookings.where((b) => b['status'] == 'Confirmed').length;
  static int get completedCount =>
      _bookings.where((b) => b['status'] == 'Completed').length;
  static int get cancelledCount =>
      _bookings.where((b) => b['status'] == 'Cancelled').length;
  static int get totalCustomers => _customers.length;
  static int get activeCustomers =>
      _customers.where((c) => c['isActive'] as bool).length;
  static int get activeServices =>
      _services.where((s) => s['isActive'] as bool).length;

  static double get totalRevenue => _bookings
      .where((b) => b['status'] == 'Completed')
      .fold(0.0, (sum, b) => sum + (b['price'] as double));

  static Map<String, dynamic>? get mostPopularService {
    if (_services.isEmpty) return null;
    return _services.reduce(
      (a, b) =>
          (a['bookingCount'] as int) >= (b['bookingCount'] as int) ? a : b,
    );
  }
}
