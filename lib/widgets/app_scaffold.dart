import 'package:flutter/material.dart';

import './app_navigation.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // V2 Floating Pill requires extendBody: true
      backgroundColor: const Color(0xFF0F0F0F),
      body: child,
      bottomNavigationBar: const AppNavigation(),
    );
  }
}
