import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/all_services_list_widgets.dart';
import './widgets/category_chips_widget.dart';
import './widgets/home_app_bar_widgets.dart';
import './widgets/service_offer_card_widgets.dart';

// TODO: Replace with Riverpod for production state management
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Body', 'Foot', 'Back'];

  // TODO: Replace with Riverpod/Firestore for production data
  final List<Map<String, dynamic>> _servicesMaps = [
    {
      'id': 'svc_001',
      'name': 'Whole Body Massage',
      'description':
          'Full relaxation from head to toe. Relieves muscle tension, improves circulation, and promotes deep stress relief.',
      'durationMinutes': 60,
      'price': 350.0,
      'category': 'Body',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_13f957847-1772520779967.png',
      'semanticLabel':
          'Therapist performing a full body massage on a client lying face down',
      'isActive': true,
      'isPopular': true,
      'rating': 4.9,
      'reviewCount': 142,
    },
    {
      'id': 'svc_002',
      'name': 'Laying/Back Massage',
      'description':
          'Targeted relief for the back and spine. Perfect for office workers and those with chronic back pain.',
      'durationMinutes': 30,
      'price': 180.0,
      'category': 'Back',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1a4b51536-1767719499335.png',
      'semanticLabel':
          'Therapist applying pressure to upper back and shoulder muscles',
      'isActive': true,
      'isPopular': false,
      'rating': 4.7,
      'reviewCount': 98,
    },
    {
      'id': 'svc_003',
      'name': 'Foot Massage',
      'description':
          'Deep pressure reflexology targeting key foot zones to relieve whole-body tension and fatigue.',
      'durationMinutes': 60,
      'price': 350.0,
      'category': 'Foot',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_16fa33031-1764808876713.png',
      'semanticLabel':
          'Therapist performing reflexology foot massage on client in spa',
      'isActive': true,
      'isPopular': true,
      'rating': 4.8,
      'reviewCount': 117,
    },
    {
      'id': 'svc_004',
      'name': 'Foot Massage',
      'description':
          'Express foot relief session — ideal for a quick refresh between meetings or after a long day.',
      'durationMinutes': 30,
      'price': 180.0,
      'category': 'Foot',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1f63b9b27-1770904209285.png',
      'semanticLabel':
          'Close-up of foot massage being performed with aromatic oils',
      'isActive': true,
      'isPopular': false,
      'rating': 4.6,
      'reviewCount': 73,
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    final category = _categories[_selectedCategoryIndex];
    return _servicesMaps.where((s) {
      final matchesCategory = category == 'All' || s['category'] == category;
      final matchesSearch =
          _searchQuery.isEmpty ||
          (s['name'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesCategory && matchesSearch && (s['isActive'] as bool);
    }).toList();
  }

  List<Map<String, dynamic>> get _popularServices =>
      _servicesMaps.where((s) => s['isPopular'] as bool).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HomeAppBarWidget(
                onNotificationTap: () {
                  // TODO: Navigate to notifications
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildSearchBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: CategoryChipsWidget(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onSelected: (i) => setState(() => _selectedCategoryIndex = i),
                ),
              ),
            ),
            // Special Offers section
            if (_popularServices.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Special Offers',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurfaceDark,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategoryIndex = 0),
                        child: Text(
                          'See All',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    itemCount: _popularServices.length,
                    itemBuilder: (context, index) {
                      return ServiceOfferCardWidget(
                        service: _popularServices[index],
                        onTap: () => context.go(AppRoutes.booking),
                      );
                    },
                  ),
                ),
              ),
            ],
            // All Services section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text(
                  _selectedCategoryIndex == 0
                      ? 'All Services'
                      : '${_categories[_selectedCategoryIndex]} Services',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceDark,
                  ),
                ),
              ),
            ),
            if (_filteredServices.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'spa',
                          color: AppTheme.mutedText,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No services found',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            color: AppTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: AllServicesListWidget(
                      service: _filteredServices[index],
                      onBook: () => context.go(AppRoutes.booking),
                      animationIndex: index,
                    ),
                  );
                }, childCount: _filteredServices.length),
              ),
            // Bottom padding for floating nav
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariantDark,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFF3A3A3C)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          CustomIconWidget(
            iconName: 'search',
            color: AppTheme.mutedText,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.dmSans(
                color: AppTheme.onSurfaceDark,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search massage services...',
                hintStyle: GoogleFonts.dmSans(
                  color: AppTheme.mutedText,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.mutedText,
                  size: 18,
                ),
              ),
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}
