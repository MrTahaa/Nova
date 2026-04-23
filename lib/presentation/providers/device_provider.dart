import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/device_model.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/services/wol_service.dart';
import '../../data/services/network_service.dart';
import '../../data/services/ping_service.dart';

enum DeviceStatus { unknown, online, offline, waking, pinging }

class DeviceProvider extends ChangeNotifier {
  final DeviceRepository _repository;
  final WolService _wolService;
  final NetworkService _networkService;
  final PingService _pingService;
  final Uuid _uuid = const Uuid();

  List<DeviceModel> _devices = [];
  final Map<String, DeviceStatus> _deviceStatuses = {};

  List<DeviceModel> get devices => List.unmodifiable(_devices);

  DeviceStatus getDeviceStatus(String deviceId) {
    return _deviceStatuses[deviceId] ?? DeviceStatus.unknown;
  }

  DeviceProvider({
    required DeviceRepository repository,
    required WolService wolService,
    required NetworkService networkService,
    required PingService pingService,
  })  : _repository = repository,
        _wolService = wolService,
        _networkService = networkService,
        _pingService = pingService;

  /// Load devices from local storage.
  void loadDevices() {
    _devices = _repository.getDevices();
    notifyListeners();

    // Ping all devices on load
    pingAllDevices();
  }

  /// Add a new device.
  Future<void> addDevice({
    required String name,
    required String macAddress,
    required String ipAddress,
    String icon = 'desktop',
  }) async {
    final device = DeviceModel(
      id: _uuid.v4(),
      name: name,
      macAddress: macAddress.toUpperCase(),
      ipAddress: ipAddress,
      icon: icon,
    );

    await _repository.saveDevice(device);
    _devices = _repository.getDevices();
    _deviceStatuses[device.id] = DeviceStatus.unknown;
    notifyListeners();

    // Ping the newly added device
    pingDevice(device.id);
  }

  /// Delete a device by ID.
  Future<void> deleteDevice(String id) async {
    await _repository.deleteDevice(id);
    _devices = _repository.getDevices();
    _deviceStatuses.remove(id);
    notifyListeners();
  }

  /// Wake a device using Wake-on-LAN.
  Future<bool> wakeDevice(String deviceId) async {
    final device = _devices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => throw Exception('Device not found'),
    );

    // Set waking state
    _deviceStatuses[deviceId] = DeviceStatus.waking;
    notifyListeners();

    // Get broadcast address
    final broadcastIp = await _networkService.getBroadcastAddress();

    // Send magic packet
    final success = await _wolService.sendMagicPacket(
      macAddress: device.macAddress,
      broadcastIp: broadcastIp,
    );

    if (!success) {
      _deviceStatuses[deviceId] = DeviceStatus.offline;
      notifyListeners();
      return false;
    }

    // Wait then ping to check status
    Timer(Duration(seconds: AppConstants.pingAfterWakeDelaySeconds), () {
      pingDevice(deviceId);
    });

    return true;
  }

  /// Ping a single device to check status.
  Future<void> pingDevice(String deviceId) async {
    final device = _devices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => throw Exception('Device not found'),
    );

    // Don't override waking status with pinging
    if (_deviceStatuses[deviceId] != DeviceStatus.waking) {
      _deviceStatuses[deviceId] = DeviceStatus.pinging;
      notifyListeners();
    }

    final isOnline = await _pingService.pingDevice(device.ipAddress);

    _deviceStatuses[deviceId] =
        isOnline ? DeviceStatus.online : DeviceStatus.offline;
    notifyListeners();
  }

  /// Ping all devices.
  Future<void> pingAllDevices() async {
    final futures = _devices.map((d) => pingDevice(d.id));
    await Future.wait(futures);
  }
}
