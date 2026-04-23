import 'dart:convert';

class DeviceModel {
  final String id;
  final String name;
  final String macAddress;
  final String ipAddress;
  final String icon;
  final DateTime createdAt;

  DeviceModel({
    required this.id,
    required this.name,
    required this.macAddress,
    required this.ipAddress,
    this.icon = 'desktop',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  DeviceModel copyWith({
    String? id,
    String? name,
    String? macAddress,
    String? ipAddress,
    String? icon,
    DateTime? createdAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      ipAddress: ipAddress ?? this.ipAddress,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'macAddress': macAddress,
      'ipAddress': ipAddress,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      macAddress: json['macAddress'] as String,
      ipAddress: json['ipAddress'] as String,
      icon: json['icon'] as String? ?? 'desktop',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory DeviceModel.fromJsonString(String jsonString) {
    return DeviceModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() => 'DeviceModel(id: $id, name: $name, mac: $macAddress)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
