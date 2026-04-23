class AppConstants {
  AppConstants._();

  // Layout
  static const double pagePadding = 20.0;
  static const double cardPadding = 20.0;
  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 16.0;
  static const double inputBorderRadius = 16.0;

  // WoL
  static const int wolPort = 9;
  static const int wolRepeatCount = 3;
  static const String defaultBroadcastIp = '255.255.255.255';

  // Ping
  static const int pingTimeoutSeconds = 3;
  static const int pingAfterWakeDelaySeconds = 10;

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 800);
  static const Duration animPulse = Duration(milliseconds: 1500);
  static const Duration animEntrance = Duration(milliseconds: 600);

  // Storage Keys
  static const String storageDevicesKey = 'nova_devices';

  // Power Button
  static const double powerButtonSize = 56.0;
  static const double powerButtonIconSize = 28.0;
}
