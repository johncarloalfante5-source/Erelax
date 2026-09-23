import 'package:flutter/material.dart';

import '../presentation/admin_dashboard/admin_dashboard_screen.dart';
import '../presentation/admin_dashboard/admin_login_screen.dart';
import '../presentation/booking_screen/booking_screen.dart';
import '../presentation/service_screen/service_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';
import '../widgets/app_scaffold.dart';

class AppRoutes {
  static const String initial = '/';
  static const String signUpLogin = '/sign-up-login-screen';
  static const String services = '/services-screen';
  static const String booking = '/booking-screen';
  static const String admin = '/admin-login';
  static const String adminDashboard = '/admin-dashboard';

  static bool isAdminAuthenticated = false;
}

extension AppNavigationCompat on BuildContext {
  void go(String route) => Navigator.pushReplacementNamed(this, route);

  void goNamed(String route) => go(route);
}

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.initial: (_) => const SignUpLoginScreen(),
  AppRoutes.signUpLogin: (_) => const SignUpLoginScreen(),
  AppRoutes.admin: (_) => const AdminLoginScreen(),
  AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
  AppRoutes.services: (_) => const AppScaffold(child: ServicesScreen()),
  AppRoutes.booking: (_) => const AppScaffold(child: BookingScreen()),
};
