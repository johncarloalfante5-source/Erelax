import 'package:flutter/material.dart';

import '../../core/booking_store.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Admin Dashboard — tabbed: Overview · Bookings · Customers · Services
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
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
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.services),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariantDark,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.onSurfaceDark,
                        size: 20,
                      ),
                    ),
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
            // ── Tab Bar ─────────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TabBar(
                controller: _tabController,
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
                  Tab(text: 'Bookings'),
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
                  _BookingsTab(onRefresh: () => setState(() {})),
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
            ...BookingStore.allBookings.take(5).map(
              (b) => _MiniBookingRow(booking: b),
            ),
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
            child: const Icon(Icons.spa_rounded, color: AppTheme.primary, size: 24),
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
      case 'Pending': return const Color(0xFFF59E0B);
      case 'Confirmed': return const Color(0xFF3B82F6);
      case 'Completed': return const Color(0xFF10B981);
      case 'Cancelled': return AppTheme.errorColor;
      default: return AppTheme.mutedText;
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
    'All', 'Pending', 'Confirmed', 'Completed', 'Cancelled',
  ];

  List<Map<String, dynamic>> get _filtered {
    final all = BookingStore.allBookings;
    if (_filterStatus == 'All') return all;
    return all.where((b) => b['status'] == _filterStatus).toList();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Pending': return const Color(0xFFF59E0B);
      case 'Confirmed': return const Color(0xFF3B82F6);
      case 'Completed': return const Color(0xFF10B981);
      case 'Cancelled': return AppTheme.errorColor;
      default: return AppTheme.mutedText;
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

  void _showStatusDialog(Map<String, dynamic> booking) {
    final current = booking['status'] as String;
    final available = <String>[];
    if (current == 'Pending') {
      available.addAll(['Confirmed', 'Cancelled']);
    } else if (current == 'Confirmed') available.addAll(['Completed', 'Cancelled']);
    if (available.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.of(ctx).padding.bottom,
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
              style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.mutedText),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

  const _BookingCard({
    required this.booking,
    required this.statusColor,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String;
    final canUpdate = status == 'Pending' || status == 'Confirmed';

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: statusColor.withAlpha(100)),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
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
                const Icon(Icons.person_outline_rounded, size: 13, color: AppTheme.mutedText),
                const SizedBox(width: 5),
                Text(
                  booking['customerName'] as String,
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.mutedText),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.mutedText),
              const SizedBox(width: 5),
              Text(
                '${booking['date']}  •  ${booking['time']}',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.mutedText),
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
              const Icon(Icons.access_time_rounded, size: 13, color: AppTheme.mutedText),
              const SizedBox(width: 5),
              Text(
                '${booking['durationMinutes']} min  •  ${booking['therapist'] ?? 'Any Therapist'}',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.mutedText),
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
          24, 24, 24, 24 + MediaQuery.of(ctx).padding.bottom,
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
            _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: customer['phone'] as String),
            _DetailRow(icon: Icons.calendar_today_outlined, label: 'Joined', value: customer['joinedAt'] as String),
            _DetailRow(icon: Icons.bookmark_outline_rounded, label: 'Total Bookings', value: '${customer['totalBookings']}'),
            _DetailRow(
              icon: customer['isActive'] as bool ? Icons.check_circle_outline : Icons.cancel_outlined,
              label: 'Status',
              value: customer['isActive'] as bool ? 'Active' : 'Disabled',
              valueColor: customer['isActive'] as bool ? const Color(0xFF10B981) : AppTheme.errorColor,
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
                  customer['isActive'] as bool ? 'Disable Account' : 'Reactivate Account',
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
              ? _EmptyState(icon: 'people_outline', message: 'No customers found')
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
          24 + MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom,
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
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppTheme.mutedText,
            ),
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