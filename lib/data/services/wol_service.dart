import 'package:wake_on_lan/wake_on_lan.dart';
import '../../core/constants/app_constants.dart';

class WolService {
  /// Sends a Wake-on-LAN magic packet to the given MAC address
  /// via the specified broadcast IP.
  ///
  /// Returns `true` if the packet was sent successfully, `false` otherwise.
  Future<bool> sendMagicPacket({
    required String macAddress,
    required String broadcastIp,
    int port = AppConstants.wolPort,
  }) async {
    try {
      // Validate MAC address
      final macValidation = MACAddress.validate(macAddress);
      if (!macValidation.state) {
        return false;
      }

      // Validate broadcast IP
      final ipValidation = IPAddress.validate(broadcastIp);
      if (!ipValidation.state) {
        return false;
      }

      // Create instances
      final mac = MACAddress(macAddress);
      final ip = IPAddress(broadcastIp);

      // Create WakeOnLAN and send
      final wol = WakeOnLAN(ip, mac, port: port);
      await wol.wake(
        repeat: AppConstants.wolRepeatCount,
        repeatDelay: const Duration(milliseconds: 500),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates a MAC address string.
  bool isValidMac(String mac) {
    return MACAddress.validate(mac).state;
  }

  /// Validates an IP address string.
  bool isValidIp(String ip) {
    return IPAddress.validate(ip).state;
  }
}
