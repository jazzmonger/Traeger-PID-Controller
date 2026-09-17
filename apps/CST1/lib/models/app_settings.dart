import '../ble/ble_protocol.dart';

class AppSettings {
  const AppSettings({
    this.smokerId = '',
    this.transport = TransportMode.bluetooth,
    this.mqttHost = 'millennial-mollusk.metalseed.net',
    this.mqttPort = 8883,
    this.mqttUsername = '',
    this.mqttPassword = '',
    this.homeAssistantIp = '',
    this.lastBleDeviceId = '',
    this.lastBleDeviceName = '',
  });

  final String smokerId;
  final TransportMode transport;
  final String mqttHost;
  final int mqttPort;
  final String mqttUsername;
  final String mqttPassword;
  final String homeAssistantIp;
  final String lastBleDeviceId;
  final String lastBleDeviceName;

  AppSettings copyWith({
    String? smokerId,
    TransportMode? transport,
    String? mqttHost,
    int? mqttPort,
    String? mqttUsername,
    String? mqttPassword,
    String? homeAssistantIp,
    String? lastBleDeviceId,
    String? lastBleDeviceName,
  }) {
    return AppSettings(
      smokerId: smokerId ?? this.smokerId,
      transport: transport ?? this.transport,
      mqttHost: mqttHost ?? this.mqttHost,
      mqttPort: mqttPort ?? this.mqttPort,
      mqttUsername: mqttUsername ?? this.mqttUsername,
      mqttPassword: mqttPassword ?? this.mqttPassword,
      homeAssistantIp: homeAssistantIp ?? this.homeAssistantIp,
      lastBleDeviceId: lastBleDeviceId ?? this.lastBleDeviceId,
      lastBleDeviceName: lastBleDeviceName ?? this.lastBleDeviceName,
    );
  }

  Map<String, Object?> toJson() => {
        'smokerId': smokerId,
        'transport': transport.name,
        'mqttHost': mqttHost,
        'mqttPort': mqttPort,
        'mqttUsername': mqttUsername,
        'mqttPassword': mqttPassword,
        'homeAssistantIp': homeAssistantIp,
        'lastBleDeviceId': lastBleDeviceId,
        'lastBleDeviceName': lastBleDeviceName,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final transportName = json['transport'] as String? ?? 'bluetooth';
    return AppSettings(
      smokerId: json['smokerId'] as String? ?? '',
      transport: TransportMode.values.firstWhere(
        (m) => m.name == transportName,
        orElse: () => TransportMode.bluetooth,
      ),
      mqttHost: json['mqttHost'] as String? ?? 'millennial-mollusk.metalseed.net',
      mqttPort: json['mqttPort'] as int? ?? 8883,
      mqttUsername: json['mqttUsername'] as String? ?? '',
      mqttPassword: json['mqttPassword'] as String? ?? '',
      homeAssistantIp: json['homeAssistantIp'] as String? ?? '',
      lastBleDeviceId: json['lastBleDeviceId'] as String? ?? '',
      lastBleDeviceName: json['lastBleDeviceName'] as String? ?? '',
    );
  }
}
