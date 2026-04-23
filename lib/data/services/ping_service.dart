import 'dart:async';
import 'package:dart_ping/dart_ping.dart';
import '../../core/constants/app_constants.dart';

class PingService {
  /// Pings the given IP address and returns whether the device is online.
  ///
  /// Sends a single ping and waits up to [AppConstants.pingTimeoutSeconds]
  /// seconds for a response. Returns `true` if a response is received.
  Future<bool> pingDevice(String ipAddress) async {
    try {
      final ping = Ping(
        ipAddress,
        count: 1,
        timeout: AppConstants.pingTimeoutSeconds,
      );

      final completer = Completer<bool>();
      late StreamSubscription<PingData> subscription;

      // Safety timeout
      final timer = Timer(
        Duration(seconds: AppConstants.pingTimeoutSeconds + 2),
        () {
          if (!completer.isCompleted) {
            completer.complete(false);
            subscription.cancel();
          }
        },
      );

      subscription = ping.stream.listen(
        (PingData event) {
          if (event.response != null && !completer.isCompleted) {
            completer.complete(true);
            timer.cancel();
            subscription.cancel();
          } else if (event.error != null && !completer.isCompleted) {
            completer.complete(false);
            timer.cancel();
            subscription.cancel();
          }
          // If we get summary, also complete
          if (event.summary != null && !completer.isCompleted) {
            final received = event.summary!.received;
            completer.complete(received > 0);
            timer.cancel();
            subscription.cancel();
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.complete(false);
            timer.cancel();
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(false);
            timer.cancel();
          }
        },
      );

      return completer.future;
    } catch (e) {
      return false;
    }
  }
}
