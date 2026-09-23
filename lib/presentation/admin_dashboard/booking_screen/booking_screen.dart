import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/booking_store.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';
import './widget/book_now-bar_widget.dart';
import './widget/booking_hero_widget.dart';
import './widget/date_selector_widget.dart';
import './widget/therapist_header_widget.dart';
import './widget/time_grid_widget.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  bool _isBooking = false;

  final Map<String, dynamic> _selectedService = {
    'id': 'svc_001',
    'name': 'Whole Body Massage',
    'durationMinutes': 60,
    'price': 350.0,
    'therapist': 'Allen Markel',
    'location': 'Gmall Bajada, Davao City',
    'rating': 4.3,
    'imageUrl':
        'https://img.rocket.new/generatedImages/rocket_gen_img_1c82a71d2-1774563152133.png',
    'semanticLabel':
        'Professional massage therapist performing back massage technique in modern spa',
  };

  final List<String> _availableTimeSlots = [
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
  ];

  List<String> get _bookedSlots => BookingStore.allBookings
      .where(
        (b) =>
            b['date'] == _formatDateKey(_selectedDate) &&
            b['status'] != 'Cancelled',
      )
      .map((b) => b['time'] as String)
      .toList();

  String _formatDateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get _selectedMonth {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  Future<void> _handleBookNow() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a time slot to continue.',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isBooking = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isBooking = false);
      _showBookingConfirmation();
    }
  }

  void _showBookingConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _BookingConfirmationSheet(
        service: _selectedService,
        date: _selectedDate,
        time: _selectedTime!,
        onConfirm: () {
          // Save booking to shared store
          final bookingId =
              'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
          BookingStore.addBooking({
            'id': bookingId,
            'service': _selectedService['name'],
            'durationMinutes': _selectedService['durationMinutes'],
            'price': _selectedService['price'],
            'therapist': _selectedService['therapist'],
            'date': _formatDateKey(_selectedDate),
            'time': _selectedTime,
            'status': 'Pending',
            'createdAt': DateTime.now().toIso8601String(),
          });
          Navigator.pop(ctx);
          _showSuccessDialog();
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Booking Confirmed!',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your reservation has been submitted. The admin will confirm your booking shortly.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.mutedText,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go(AppRoutes.services);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Services',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    if (isTablet) {
      return _buildTabletLayout();
    }
    return _buildPhoneLayout();
  }

  Widget _buildPhoneLayout() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Column(
            children: [
              BookingHeroWidget(
                imageUrl: _selectedService['imageUrl'] as String,
                semanticLabel: _selectedService['semanticLabel'] as String,
                onBack: () => context.go(AppRoutes.services),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TherapistHeaderWidget(
                                name: _selectedService['therapist'] as String,
                                location:
                                    _selectedService['location'] as String,
                                rating: _selectedService['rating'] as double,
                                serviceName: _selectedService['name'] as String,
                                price: _selectedService['price'] as double,
                                durationMinutes:
                                    _selectedService['durationMinutes'] as int,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Text(
                                    'Date & Time',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.onSurfaceDark,
                                    ),
                                  ),
                                  const Spacer(),
                                  _MonthDropdown(
                                    month: _selectedMonth,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DateSelectorWidget(
                                selectedDate: _selectedDate,
                                onDateSelected: (d) {
                                  setState(() {
                                    _selectedDate = d;
                                    _selectedTime = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Available Times',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.mutedText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TimeGridWidget(
                                timeSlots: _availableTimeSlots,
                                bookedSlots: _bookedSlots,
                                selectedTime: _selectedTime,
                                onTimeSelected: (t) =>
                                    setState(() => _selectedTime = t),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BookNowBarWidget(
              selectedTime: _selectedTime,
              isLoading: _isBooking,
              onBook: _handleBookNow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomImageWidget(
                    imageUrl: _selectedService['imageUrl'] as String,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    semanticLabel: _selectedService['semanticLabel'] as String,
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.services),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(128),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                color: AppTheme.surfaceDark,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TherapistHeaderWidget(
                        name: _selectedService['therapist'] as String,
                        location: _selectedService['location'] as String,
                        rating: _selectedService['rating'] as double,
                        serviceName: _selectedService['name'] as String,
                        price: _selectedService['price'] as double,
                        durationMinutes:
                            _selectedService['durationMinutes'] as int,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Date & Time',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurfaceDark,
                            ),
                          ),
                          const Spacer(),
                          _MonthDropdown(month: _selectedMonth, onTap: () {}),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DateSelectorWidget(
                        selectedDate: _selectedDate,
                        onDateSelected: (d) => setState(() {
                          _selectedDate = d;
                          _selectedTime = null;
                        }),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Available Times',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mutedText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TimeGridWidget(
                        timeSlots: _availableTimeSlots,
                        bookedSlots: _bookedSlots,
                        selectedTime: _selectedTime,
                        onTimeSelected: (t) =>
                            setState(() => _selectedTime = t),
                      ),
                      const SizedBox(height: 24),
                      BookNowBarWidget(
                        selectedTime: _selectedTime,
                        isLoading: _isBooking,
                        onBook: _handleBookNow,
                        isInline: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthDropdown extends StatelessWidget {
  final String month;
  final VoidCallback onTap;

  const _MonthDropdown({required this.month, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariantDark,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFF3A3A3C)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              month,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.onSurfaceDark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.mutedText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingConfirmationSheet extends StatelessWidget {
  final Map<String, dynamic> service;
  final DateTime date;
  final String time;
  final VoidCallback onConfirm;

  const _BookingConfirmationSheet({
    required this.service,
    required this.date,
    required this.time,
    required this.onConfirm,
  });

  String _formatDate(DateTime d) {
    const months = [
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final price = (service['price'] as double).toStringAsFixed(0);
    final duration = service['durationMinutes'] as int;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.mutedText.withAlpha(102),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppTheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Summary',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurfaceDark,
                    ),
                  ),
                  Text(
                    'Review your reservation details',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSummaryRow('Service', service['name'] as String),
          _buildSummaryRow('Duration', '$duration minutes'),
          _buildSummaryRow('Date', _formatDate(date)),
          _buildSummaryRow('Time', time),
          _buildSummaryRow('Therapist', service['therapist'] as String),
          _buildSummaryRow('Location', service['location'] as String),
          const Divider(color: Color(0xFF3A3A3C), height: 24),
          Row(
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
              const Spacer(),
              Text(
                '₱$price',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Confirm Reservation',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Go Back',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.mutedText,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.mutedText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.onSurfaceDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
