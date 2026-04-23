import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';

class NovaApp extends StatelessWidget {
  const NovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nova - Wake on LAN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
