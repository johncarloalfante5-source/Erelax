import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/auth_panel_widget.dart';
import './widgets/onboarding_hero_widget.dart';

class SignUpLoginScreen extends StatefulWidget {
  const SignUpLoginScreen({super.key});

  @override
  State<SignUpLoginScreen> createState() => _SignUpLoginScreenState();
}

class _SignUpLoginScreenState extends State<SignUpLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _panelController;
  late Animation<Offset> _panelSlide;
  late Animation<double> _panelFade;

  bool _showAuth = false;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _panelSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _panelController, curve: Curves.easeOutCubic),
        );
    _panelFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _panelController, curve: Curves.easeOut));

    // Auto-show auth after brief delay
    Future.microtask(() async {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _showAuth = true);
        _panelController.forward();
      }
    });
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    if (!_showAuth) {
      setState(() => _showAuth = true);
      _panelController.forward();
    }
  }

  void _onAuthSuccess() {
    context.go(AppRoutes.services);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Hero background — full screen
          OnboardingHeroWidget(
            onGetStarted: _onGetStarted,
            showCta: !_showAuth,
          ),
          // Auth panel
          if (_showAuth)
            SlideTransition(
              position: _panelSlide,
              child: FadeTransition(
                opacity: _panelFade,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: isTablet
                      ? _buildTabletAuthCard(context)
                      : AuthPanelWidget(
                          onAuthSuccess: _onAuthSuccess,
                          onAdminAccess: () => context.go(AppRoutes.admin),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabletAuthCard(BuildContext context) {
    return Center(
      child: Container(
        width: 480,
        margin: const EdgeInsets.all(32),
        child: AuthPanelWidget(
          onAuthSuccess: _onAuthSuccess,
          onAdminAccess: () => context.go(AppRoutes.admin),
        ),
      ),
    );
  }
}
