// Shared booking store — simulates a real backend booking database
// In production, replace with Supabase/Firebase Firestore

class BookingStore {
  BookingStore._();

  static final List<Map<String, dynamic>> _bookings = [];

  // ── Customers ──────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _customers = [
    {
      'id': 'cust_001',
      'name': 'Maria Santos',
      'email': 'maria.santos@email.com',
      'phone': '+63 912 345 6789',
      'joinedAt': '2026-01-15',
      'totalBookings': 5,
      'isActive': true,
    },
    {
      'id': 'cust_002',
      'name': 'Juan dela Cruz',
      'email': 'juan.delacruz@email.com',
      'phone': '+63 917 234 5678',
      'joinedAt': '2026-02-20',
      'totalBookings': 3,
      'isActive': true,
    },
    {
      'id': 'cust_003',
      'name': 'Ana Reyes',
      'email': 'ana.reyes@email.com',
      'phone': '+63 918 765 4321',
      'joinedAt': '2026-03-05',
      'totalBookings': 7,
      'isActive': true,
    },
    {
      'id': 'cust_004',
      'name': 'Carlos Mendoza',
      'email': 'carlos.mendoza@email.com',
      'phone': '+63 920 111 2233',
      'joinedAt': '2026-04-10',
      'totalBookings': 2,
      'isActive': false,
    },
    {
      'id': 'cust_005',
      'name': 'Liza Bautista',
      'email': 'liza.bautista@email.com',
      'phone': '+63 915 987 6543',
      'joinedAt': '2026-05-18',
      'totalBookings': 4,
      'isActive': true,
    },
  ];

  // ── Services ───────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _services = [
    {
      'id': 'svc_001',
      'name': 'Whole Body Massage',
      'description':
          'Full relaxation from head to toe. Relieves muscle tension, improves circulation, and promotes deep stress relief.',
      'durationMinutes': 60,
      'price': 350.0,
      'category': 'Body',
      'isActive': true,
      'bookingCount': 42,
    },
    {
      'id': 'svc_002',
      'name': 'Laying/Back Massage',
      'description':
          'Targeted relief for the back and spine. Perfect for office workers and those with chronic back pain.',
      'durationMinutes': 30,
      'price': 180.0,
      'category': 'Back',
      'isActive': true,
      'bookingCount': 28,
    },
    {
      'id': 'svc_003',
      'name': 'Foot Massage (60 min)',
      'description':
          'Deep pressure reflexology targeting key foot zones to relieve whole-body tension and fatigue.',
      'durationMinutes': 60,
      'price': 350.0,
      'category': 'Foot',
      'isActive': true,
      'bookingCount': 35,
    },
    {
      'id': 'svc_004',
      'name': 'Foot Massage (30 min)',
      'description':
          'Express foot relief session — ideal for a quick refresh between meetings or after a long day.',
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
    _bookings.insert(0, Map<String, dynamic>.from(booking));
    // Increment customer booking count if customer exists
    final custIndex = _customers.indexWhere(
      (c) => c['name'] == booking['customerName'],
    );
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
    }
  }

  // ── Customers ──────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> get allCustomers =>
      List.unmodifiable(_customers);

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
