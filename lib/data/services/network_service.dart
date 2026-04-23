import 'package:network_info_plus/network_info_plus.dart';
import '../../core/constants/app_constants.dart';

class NetworkService {
  final NetworkInfo _networkInfo = NetworkInfo();

  /// Returns the current Wi-Fi broadcast address for the local network.
  /// Falls back to 255.255.255.255 if unavailable.
  Future<String> getBroadcastAddress() async {
    try {
      final broadcast = await _networkInfo.getWifiBroadcast();
      if (broadcast != null && broadcast.isNotEmpty) {
        return broadcast;
      }
    } catch (e) {
      // Fallback
    }
    return AppConstants.defaultBroadcastIp;
  }

  /// Returns the current Wi-Fi IP address if available.
  Future<String?> getWifiIp() async {
    try {
      return await _networkInfo.getWifiIP();
    } catch (e) {
      return null;
    }
  }

  /// Returns the current Wi-Fi network name (SSID).
  Future<String?> getWifiName() async {
    try {
      return await _networkInfo.getWifiName();
    } catch (e) {
      return null;
    }
  }
}
