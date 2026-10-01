import 'package:flutter/material.dart';

import '../../core/booking_store.dart';
import 'sales_analytics_screen.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Admin Dashboard — tabbed management views
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _salesAnalyticsKey = GlobalKey<SalesAnalyticsScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabChanged);
  }

  void _handleTabChanged() {
    if (!mounted) return;
    setState(() {});
    if (!_tabController.indexIsChanging && _tabController.index == 1) {
      _salesAnalyticsKey.currentState?.refresh();
    }
  }

  Future<void> _confirmAdminLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Are you sure you want to log out of the admin dashboard?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      AppRoutes.isAdminAuthenticated = false;
      context.go(AppRoutes.admin);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            //── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Log out',
                    onPressed: _confirmAdminLogout,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surfaceVariantDark,
                      foregroundColor: AppTheme.onSurfaceDark,
                      fixedSize: const Size(40, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurfaceDark,
                        ),
                      ),
                      Text(
                        'E-RELAX Management',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Walk-in dashboard',
                    onPressed: () => _tabController.animateTo(3),
                    icon: const Icon(
                      Icons.directions_walk_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {}),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariantDark,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            //── Tab Bar ─────────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: AppTheme.mutedText,
                labelStyle: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Sales'),
                  Tab(text: 'Bookings'),
                  Tab(text: 'Walk-Ins'),
                  Tab(text: 'Therapists'),
                  Tab(text: 'Customers'),
                  Tab(text: 'Services'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // ── Tab Views ───────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(onRefresh: () => setState(() {})),
                  SalesAnalyticsScreen(key: _salesAnalyticsKey),
                  _BookingsTab(onRefresh: () => setState(() {})),
                  _WalkInsTab(onRefresh: () => setState(() {})),
                  _TherapistsTab(onRefresh: () => setState(() {})),
                  _CustomersTab(onRefresh: () => setState(() {})),
                  _ServicesTab(onRefresh: () => setState(() {})),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OVERVIEW TAB
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final VoidCallback onRefresh;
  const _OverviewTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final popular = BookingStore.mostPopularService;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats grid ──────────────────────────────────────────────────
          _SectionLabel('Key Statistics'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _StatTile(
                label: 'Total Bookings',
                value: BookingStore.totalBookings.toString(),
                icon: 'calendar_today',
                color: AppTheme.primary,
              ),
              _StatTile(
                label: 'Total Revenue',
                value: '₱${BookingStore.totalRevenue.toStringAsFixed(0)}',
                icon: 'payments',
                color: const Color(0xFF10B981),
              ),
              _StatTile(
                label: 'Customers',
                value: BookingStore.totalCustomers.toString(),
                icon: 'people',
                color: const Color(0xFF3B82F6),
              ),
              _StatTile(
                label: 'Active Services',
                value: BookingStore.activeServices.toString(),
                icon: 'spa',
                color: const Color(0xFFA855F7),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // ── Booking status breakdown ─────────────────────────────────────
          _SectionLabel('Booking Status'),
          const SizedBox(height: 12),
          _StatusBreakdownCard(),
          const SizedBox(height: 24),
          // ── Popular service ──────────────────────────────────────────────
          if (popular != null) ...[
            _SectionLabel('Most Popular Service'),
            const SizedBox(height: 12),
            _PopularServiceCard(service: popular),
            const SizedBox(height: 24),
          ],
          // ── Recent bookings ──────────────────────────────────────────────
          _SectionLabel('Recent Bookings'),
          const SizedBox(height: 12),
          if (BookingStore.allBookings.isEmpty)
            _EmptyState(
              icon: 'calendar_today_outlined',
              message: 'No bookings yet',
            )
          else
            ...BookingStore.allBookings
                .take(5)
                .map((b) => _MiniBookingRow(booking: b)),
        ],
      ),
    );
  }
}

class _StatusBreakdownCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final total = BookingStore.totalBookings;
    final items = [
      ('Pending', BookingStore.pendingCount, const Color(0xFFF59E0B)),
      ('Confirmed', BookingStore.confirmedCount, const Color(0xFF3B82F6)),
      ('Completed', BookingStore.completedCount, const Color(0xFF10B981)),
      ('Cancelled', BookingStore.cancelledCount, AppTheme.errorColor),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        children: items.map((item) {
          final pct = total == 0 ? 0.0 : item.$2 / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item.$3,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.$1,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppTheme.onSurfaceDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${item.$2}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: item.$3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: item.$3.withAlpha(30),
                    valueColor: AlwaysStoppedAnimation<Color>(item.$3),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PopularServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  const _PopularServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withAlpha(30),
            AppTheme.primary.withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.primary.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(40),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${service['durationMinutes']} min  •  ₱${(service['price'] as double).toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${service['bookingCount']}',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                'bookings',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBookingRow extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _MiniBookingRow({required this.booking});

  Color _statusColor(String s) {
    switch (s) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Confirmed':
        return const Color(0xFF3B82F6);
      case 'Completed':
        return const Color(0xFF10B981);
      case 'Cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.mutedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['service'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking['date']}  •  ${booking['time']}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(status).withAlpha(30),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              status,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _statusColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOKINGS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _BookingsTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const _BookingsTab({required this.onRefresh});

  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> {
  String _filterStatus = 'All';
  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  List<Map<String, dynamic>> get _filtered {
    final all = BookingStore.allBookings;
    if (_filterStatus == 'All') return all;
    return all.where((b) => b['status'] == _filterStatus).toList();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Confirmed':
        return const Color(0xFF3B82F6);
      case 'Completed':
        return const Color(0xFF10B981);
      case 'Cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.mutedText;
    }
  }

  void _updateStatus(String id, String newStatus) {
    BookingStore.updateStatus(id, newStatus);
    setState(() {});
    widget.onRefresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking updated to $newStatus',
          style: GoogleFonts.dmSans(color: Colors.black),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _recordPayment(Map<String, dynamic> booking) async {
    final amountController = TextEditingController();
    final price = (booking['price'] as num?)?.toDouble() ?? 0;
    final paid = (booking['amountPaid'] as num?)?.toDouble() ?? 0;
    final balance = (price - paid).clamp(0, price).toDouble();
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Record payment'),
        content: TextField(
          controller: amountController,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount received',
            prefixText: '₱ ',
            helperText: 'Remaining balance: ₱${balance.toStringAsFixed(2)}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              double.tryParse(amountController.text.trim()),
            ),
            child: const Text('Record'),
          ),
        ],
      ),
    );
    amountController.dispose();
    if (amount == null || !mounted) return;
    try {
      final receipt = BookingStore.recordPayment(
        reservationId: booking['id'] as String,
        amount: amount,
      );
      setState(() {});
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt ${receipt['receiptNumber']} recorded.'),
        ),
      );
    } on ArgumentError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message?.toString() ?? 'Invalid payment amount.'),
        ),
      );
    }
  }

  Future<void> _refundPayment(Map<String, dynamic> booking) async {
    final shouldRefund = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Record refund'),
        content: Text(
          'Refund ₱${((booking['amountPaid'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} to ${booking['customerName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep payment'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Record refund'),
          ),
        ],
      ),
    );
    if (shouldRefund != true || !mounted) return;
    try {
      final receipt = BookingStore.refundPayment(booking['id'] as String);
      setState(() {});
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Refund receipt ${receipt['receiptNumber']} recorded.'),
        ),
      );
    } on StateError catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _showStatusDialog(Map<String, dynamic> booking) {
    final current = booking['status'] as String;
    final available = <String>[];
    if (current == 'Pending') {
      available.addAll(['Confirmed', 'Cancelled', 'No-Show']);
    } else if (current == 'Confirmed')
      available.addAll(['Ongoing', 'Cancelled', 'No-Show']);
    else if (current == 'Ongoing')
      available.addAll(['Completed', 'Cancelled']);
    if (available.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Booking Status',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              booking['service'] as String,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.mutedText,
              ),
            ),
            const SizedBox(height: 20),
            ...available.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _updateStatus(booking['id'] as String, s);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _statusColor(s).withAlpha(38),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: _statusColor(s).withAlpha(128)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Mark as $s',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(s),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            itemCount: _statusFilters.length,
            itemBuilder: (_, i) {
              final f = _statusFilters[i];
              final sel = _filterStatus == f;
              return GestureDetector(
                onTap: () => setState(() => _filterStatus = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.surfaceVariantDark,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: sel ? AppTheme.primary : const Color(0xFF3A3A3C),
                    ),
                  ),
                  child: Text(
                    f,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.black : AppTheme.mutedText,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _filtered.isEmpty
              ? _EmptyState(
                  icon: 'calendar_today_outlined',
                  message: _filterStatus == 'All'
                      ? 'No bookings yet'
                      : 'No $_filterStatus bookings',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final b = _filtered[i];
                    return _BookingCard(
                      booking: b,
                      statusColor: _statusColor(b['status'] as String),
                      onUpdateStatus: () => _showStatusDialog(b),
                      onRecordPayment: () => _recordPayment(b),
                      onRecordRefund: () => _refundPayment(b),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Color statusColor;
  final VoidCallback onUpdateStatus;
  final VoidCallback onRecordPayment;
  final VoidCallback onRecordRefund;

  const _BookingCard({
    required this.booking,
    required this.statusColor,
    required this.onUpdateStatus,
    required this.onRecordPayment,
    required this.onRecordRefund,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String;
    final canUpdate =
        status == 'Pending' || status == 'Confirmed' || status == 'Ongoing';
    final isWalkIn = booking['reservationType'] == 'Walk-In';
    final paymentStatus = booking['paymentStatus'] as String? ?? 'Unpaid';
    final price = (booking['price'] as num?)?.toDouble() ?? 0;
    final amountPaid = (booking['amountPaid'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking['service'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isWalkIn) ...[
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Walk-In',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ] else
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariantDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Online',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: statusColor.withAlpha(100)),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (booking['customerName'] != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 13,
                  color: AppTheme.mutedText,
                ),
                const SizedBox(width: 5),
                Text(
                  booking['customerName'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppTheme.mutedText,
              ),
              const SizedBox(width: 5),
              Text(
                '${booking['date']}  •  ${booking['time']}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppTheme.mutedText,
                ),
              ),
              const Spacer(),
              Text(
                '₱${(booking['price'] as double).toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 13,
                color: AppTheme.mutedText,
              ),
              const SizedBox(width: 5),
              Text(
                '${booking['durationMinutes']} min  •  ${booking['therapist'] ?? 'Any Therapist'}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
          if (canUpdate) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onUpdateStatus,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primary.withAlpha(128)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  'Update Status',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ],
          if (isWalkIn && amountPaid < price) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$paymentStatus • Balance ₱${(price - amountPaid).toStringAsFixed(2)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onRecordPayment,
                  icon: const Icon(Icons.payments_outlined, size: 16),
                  label: const Text('Record payment'),
                ),
              ],
            ),
          ],
          if (isWalkIn && amountPaid > 0 && paymentStatus != 'Refunded')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRecordRefund,
                icon: const Icon(Icons.undo_rounded, size: 16),
                label: const Text('Record refund'),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMERS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _CustomersTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const _CustomersTab({required this.onRefresh});

  @override
  State<_CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<_CustomersTab> {
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> get _filtered {
    final q = _search.toLowerCase();
    return BookingStore.allCustomers.where((c) {
      if (q.isEmpty) return true;
      return (c['name'] as String).toLowerCase().contains(q) ||
          (c['email'] as String).toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleStatus(String id) {
    BookingStore.toggleCustomerStatus(id);
    setState(() {});
    widget.onRefresh();
  }

  void _showCustomerDetail(Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primary.withAlpha(40),
                  child: Text(
                    (customer['name'] as String)[0].toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer['name'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurfaceDark,
                        ),
                      ),
                      Text(
                        customer['email'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: customer['phone'] as String,
            ),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Joined',
              value: customer['joinedAt'] as String,
            ),
            _DetailRow(
              icon: Icons.bookmark_outline_rounded,
              label: 'Total Bookings',
              value: '${customer['totalBookings']}',
            ),
            _DetailRow(
              icon: customer['isActive'] as bool
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              label: 'Status',
              value: customer['isActive'] as bool ? 'Active' : 'Disabled',
              valueColor: customer['isActive'] as bool
                  ? const Color(0xFF10B981)
                  : AppTheme.errorColor,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _toggleStatus(customer['id'] as String);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: customer['isActive'] as bool
                      ? AppTheme.errorColor.withAlpha(38)
                      : const Color(0xFF10B981).withAlpha(38),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: customer['isActive'] as bool
                          ? AppTheme.errorColor.withAlpha(128)
                          : const Color(0xFF10B981).withAlpha(128),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  customer['isActive'] as bool
                      ? 'Disable Account'
                      : 'Reactivate Account',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: customer['isActive'] as bool
                        ? AppTheme.errorColor
                        : const Color(0xFF10B981),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v),
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.onSurfaceDark,
            ),
            decoration: InputDecoration(
              hintText: 'Search customers…',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.mutedText,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppTheme.mutedText,
                size: 20,
              ),
              suffixIcon: _search.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.mutedText,
                        size: 18,
                      ),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: AppTheme.surfaceVariantDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? _EmptyState(
                  icon: 'people_outline',
                  message: 'No customers found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final c = _filtered[i];
                    final isActive = c['isActive'] as bool;
                    return GestureDetector(
                      onTap: () => _showCustomerDetail(c),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(color: const Color(0xFF2C2C2E)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isActive
                                  ? AppTheme.primary.withAlpha(40)
                                  : AppTheme.mutedText.withAlpha(40),
                              child: Text(
                                (c['name'] as String)[0].toUpperCase(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? AppTheme.primary
                                      : AppTheme.mutedText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['name'] as String,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.onSurfaceDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c['email'] as String,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: AppTheme.mutedText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFF10B981).withAlpha(30)
                                        : AppTheme.errorColor.withAlpha(30),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    isActive ? 'Active' : 'Disabled',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? const Color(0xFF10B981)
                                          : AppTheme.errorColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${c['totalBookings']} bookings',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: AppTheme.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WALK-INS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _WalkInsTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const _WalkInsTab({required this.onRefresh});

  @override
  State<_WalkInsTab> createState() => _WalkInsTabState();
}

class _WalkInsTabState extends State<_WalkInsTab> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String? _serviceId;
  String? _therapist;
  String? _error;

  List<Map<String, dynamic>> get _services => BookingStore.allServices
      .where((service) => service['isActive'] == true)
      .toList(growable: false);

  Map<String, dynamic>? get _selectedService {
    for (final service in _services) {
      if (service['id'] == _serviceId) return service;
    }
    return null;
  }

  List<String> get _availableTherapists =>
      BookingStore.therapistsAvailableOn(DateTime.now());

  List<Map<String, dynamic>> get _todayEntries => BookingStore.walkInEntries
      .where((entry) => entry['date'] == BookingStore.dateKey(DateTime.now()))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    final firstService = _services.firstOrNull;
    if (firstService != null) {
      _serviceId = firstService['id'] as String;
      _amountController.text = (firstService['price'] as num).toStringAsFixed(
        2,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectService(String? serviceId) {
    final service = _services.where((item) => item['id'] == serviceId);
    setState(() {
      _serviceId = serviceId;
      _amountController.text = service.isEmpty
          ? ''
          : (service.first['price'] as num).toStringAsFixed(2);
      _error = null;
    });
  }

  void _addWalkIn() {
    final service = _selectedService;
    final amount = double.tryParse(_amountController.text.trim());
    if (_nameController.text.trim().isEmpty ||
        service == null ||
        _therapist == null ||
        amount == null) {
      setState(
        () =>
            _error = 'Enter a name, service, available therapist, and amount.',
      );
      return;
    }

    try {
      final entry = BookingStore.addWalkInEntry(
        customerName: _nameController.text,
        serviceId: service['id'] as String,
        therapist: _therapist!,
        amountReceived: amount,
      );
      setState(() {
        _nameController.clear();
        _therapist = null;
        _error = null;
      });
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Walk-in recorded for ${entry['customerName']}.'),
        ),
      );
    } on ArgumentError catch (error) {
      setState(
        () =>
            _error = error.message?.toString() ?? 'Check the entered details.',
      );
    } on StateError catch (error) {
      setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _todayEntries;
    final received = entries.fold<double>(
      0,
      (total, entry) => total + (entry['amountReceived'] as num).toDouble(),
    );
    final balance = entries.fold<double>(
      0,
      (total, entry) => total + (entry['remainingBalance'] as num).toDouble(),
    );
    final available = _availableTherapists;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          'Walk-in dashboard',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceDark,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: [
            _walkInMetric(
              'Visits today',
              '${entries.length}',
              AppTheme.primary,
            ),
            _walkInMetric(
              'Received',
              '₱${received.toStringAsFixed(2)}',
              AppTheme.success,
            ),
            _walkInMetric(
              'Balance due',
              '₱${balance.toStringAsFixed(2)}',
              AppTheme.warning,
            ),
            _walkInMetric(
              'Therapists available',
              '${available.length}',
              AppTheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2C2C2E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New walk-in',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Customer name'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue:
                    _services.any((service) => service['id'] == _serviceId)
                    ? _serviceId
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Service'),
                items: _services
                    .map(
                      (service) => DropdownMenuItem(
                        value: service['id'] as String,
                        child: Text(
                          '${service['name']}  •  ₱${(service['price'] as num).toStringAsFixed(2)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _selectService,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: available.contains(_therapist)
                    ? _therapist
                    : null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: available.isEmpty
                      ? 'No therapists scheduled today'
                      : 'Available therapist',
                ),
                items: available
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: available.isEmpty
                    ? null
                    : (value) => setState(() => _therapist = value),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount received',
                  prefixText: '₱ ',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: available.isEmpty || _services.isEmpty
                      ? null
                      : _addWalkIn,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Record walk-in'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Today’s visits',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceDark,
          ),
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          const _EmptyState(
            icon: 'directions_walk_outlined',
            message: 'No walk-ins recorded today',
          )
        else
          ...entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2C2C2E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry['customerName'] as String,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurfaceDark,
                          ),
                        ),
                      ),
                      Text(
                        '₱${(entry['amountReceived'] as num).toStringAsFixed(2)}',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${entry['service']}  •  ${entry['therapist']}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${entry['paymentStatus']}  •  Balance ₱${(entry['remainingBalance'] as num).toStringAsFixed(2)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _walkInMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.mutedText),
          ),
        ],
      ),
    );
  }
}

class _TherapistsTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const _TherapistsTab({required this.onRefresh});

  @override
  State<_TherapistsTab> createState() => _TherapistsTabState();
}

class _TherapistsTabState extends State<_TherapistsTab> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _chooseDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (selected != null) setState(() => _selectedDate = selected);
  }

  @override
  Widget build(BuildContext context) {
    final available = BookingStore.therapistsAvailableOn(_selectedDate);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          'Daily therapist roster',
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Only selected therapists can be requested for bookings on this date.',
          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.mutedText),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _chooseDate,
          icon: const Icon(Icons.calendar_month_rounded, size: 18),
          label: Text(
            'Work date: ${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${available.length} of ${BookingStore.therapists.length} therapists working',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: available.isEmpty ? AppTheme.warning : AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...BookingStore.therapists.map((therapist) {
          final isAvailable = available.contains(therapist);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2C2C2E)),
              ),
              child: CheckboxListTile(
                value: isAvailable,
                onChanged: (_) {
                  BookingStore.toggleTherapistAvailability(
                    _selectedDate,
                    therapist,
                  );
                  setState(() {});
                  widget.onRefresh();
                },
                title: Text(
                  therapist,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceDark,
                  ),
                ),
                activeColor: AppTheme.primary,
                checkColor: Colors.black,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICES TAB
// ─────────────────────────────────────────────────────────────────────────────

class _ServicesTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const _ServicesTab({required this.onRefresh});

  @override
  State<_ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<_ServicesTab> {
  void _toggleService(String id) {
    BookingStore.toggleServiceStatus(id);
    setState(() {});
    widget.onRefresh();
  }

  void _showEditDialog(Map<String, dynamic> service) {
    final nameCtrl = TextEditingController(text: service['name'] as String);
    final priceCtrl = TextEditingController(
      text: (service['price'] as double).toStringAsFixed(0),
    );
    final descCtrl = TextEditingController(
      text: service['description'] as String,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 +
              MediaQuery.of(ctx).viewInsets.bottom +
              MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Service',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 16),
            _SheetTextField(controller: nameCtrl, label: 'Service Name'),
            const SizedBox(height: 12),
            _SheetTextField(
              controller: priceCtrl,
              label: 'Price (₱)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _SheetTextField(
              controller: descCtrl,
              label: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final newPrice = double.tryParse(priceCtrl.text.trim());
                  if (newPrice == null) return;
                  BookingStore.updateService(service['id'] as String, {
                    'name': nameCtrl.text.trim(),
                    'price': newPrice,
                    'description': descCtrl.text.trim(),
                  });
                  Navigator.pop(ctx);
                  setState(() {});
                  widget.onRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Service updated',
                        style: GoogleFonts.dmSans(color: Colors.black),
                      ),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = BookingStore.allServices;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: services.length,
      itemBuilder: (_, i) {
        final s = services[i];
        final isActive = s['isActive'] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF2C2C2E)
                  : AppTheme.errorColor.withAlpha(60),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primary.withAlpha(30)
                          : AppTheme.mutedText.withAlpha(20),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      Icons.spa_rounded,
                      color: isActive ? AppTheme.primary : AppTheme.mutedText,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['name'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? AppTheme.onSurfaceDark
                                : AppTheme.mutedText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${s['durationMinutes']} min  •  ₱${(s['price'] as double).toStringAsFixed(0)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF10B981).withAlpha(30)
                          : AppTheme.errorColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? const Color(0xFF10B981)
                            : AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                s['description'] as String,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppTheme.mutedText,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${s['bookingCount']} total bookings',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppTheme.primary.withAlpha(180),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditDialog(s),
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: BorderSide(
                          color: AppTheme.primary.withAlpha(128),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleService(s['id'] as String),
                      icon: Icon(
                        isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 14,
                      ),
                      label: Text(
                        isActive ? 'Deactivate' : 'Activate',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isActive
                            ? AppTheme.errorColor
                            : const Color(0xFF10B981),
                        side: BorderSide(
                          color: isActive
                              ? AppTheme.errorColor.withAlpha(128)
                              : const Color(0xFF10B981).withAlpha(128),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.onSurfaceDark,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomIconWidget(iconName: icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.mutedText),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(iconName: icon, color: AppTheme.mutedText, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.dmSans(fontSize: 15, color: AppTheme.mutedText),
          ),
          const SizedBox(height: 6),
          Text(
            'Data will appear here',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppTheme.mutedText.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.mutedText),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.mutedText),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.onSurfaceDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  const _SheetTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.onSurfaceDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.mutedText),
        filled: true,
        fillColor: AppTheme.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
