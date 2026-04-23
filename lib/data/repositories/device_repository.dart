import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_model.dart';
import '../../core/constants/app_constants.dart';

class DeviceRepository {
  final SharedPreferences _prefs;

  DeviceRepository(this._prefs);

  List<DeviceModel> getDevices() {
    final jsonString = _prefs.getString(AppConstants.storageDevicesKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveDevice(DeviceModel device) async {
    final devices = getDevices();
    final existingIndex = devices.indexWhere((d) => d.id == device.id);

    if (existingIndex >= 0) {
      devices[existingIndex] = device;
    } else {
      devices.add(device);
    }

    return _saveAll(devices);
  }

  Future<bool> deleteDevice(String id) async {
    final devices = getDevices();
    devices.removeWhere((d) => d.id == id);
    return _saveAll(devices);
  }

  Future<bool> _saveAll(List<DeviceModel> devices) {
    final jsonString = jsonEncode(devices.map((d) => d.toJson()).toList());
    return _prefs.setString(AppConstants.storageDevicesKey, jsonString);
  }
}
