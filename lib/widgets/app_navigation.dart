import 'package:flutter/material.dart';

import '../core/app_export.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import './custom_icon_widget.dart';

class _TabSpec {
  final String label;
  final String iconName;
  final String selectedIconName;
  final int? branchIndex;
  final String? route;

  const _TabSpec({
    required this.label,
    required this.iconName,
    required this.selectedIconName,
    this.branchIndex,
    this.route,
  });
}

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation>
    with SingleTickerProviderStateMixin {
  int _selectedVisualIndex = 0;

  late AnimationController _controller;

  static const List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'Services',
      iconName: 'spa_outlined',
      selectedIconName: 'spa',
      branchIndex: 0,
    ),
    _TabSpec(
      label: 'Book',
      iconName: 'calendar_today_outlined',
      selectedIconName: 'calendar_today',
      branchIndex: 1,
    ),
    _TabSpec(
      label: 'Profile',
      iconName: 'person_outline',
      selectedIconName: 'person',
      route: AppRoutes.signUpLogin,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabTap(int visualIndex) {
    final tab = _tabs[visualIndex];

    if (tab.route != null) {
      Navigator.pushReplacementNamed(context, tab.route!);
      return;
    }

    if (tab.branchIndex == null) return;

    setState(() {
      _selectedVisualIndex = visualIndex;
    });
    Navigator.pushReplacementNamed(
      context,
      tab.branchIndex == 0 ? AppRoutes.services : AppRoutes.booking,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(89),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.primary.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final isActive = _selectedVisualIndex == index;

          return GestureDetector(
            onTap: () => _onTabTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 16 : 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary.withAlpha(38)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: isActive ? tab.selectedIconName : tab.iconName,
                    color: isActive ? AppTheme.primary : AppTheme.mutedText,
                    size: 22,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        tab.label,
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
