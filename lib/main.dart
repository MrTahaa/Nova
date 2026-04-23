import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';

import 'app.dart';
import 'data/repositories/device_repository.dart';
import 'data/services/wol_service.dart';
import 'data/services/network_service.dart';
import 'data/services/ping_service.dart';
import 'presentation/providers/device_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register iOS ping plugin
  if (Platform.isIOS) {
    DartPingIOS.register();
  }

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D12),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Create services
  final deviceRepository = DeviceRepository(prefs);
  final wolService = WolService();
  final networkService = NetworkService();
  final pingService = PingService();

  runApp(
    ChangeNotifierProvider(
      create: (_) => DeviceProvider(
        repository: deviceRepository,
        wolService: wolService,
        networkService: networkService,
        pingService: pingService,
      ),
      child: const NovaApp(),
    ),
  );
}
