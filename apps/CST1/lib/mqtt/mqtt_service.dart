import '../ble/ble_protocol.dart';
import '../models/app_settings.dart';

/// Phase 2 MQTT transport stub. Settings are persisted; connect is not yet implemented.
class MqttService {
  LinkStatus _status = LinkStatus.disconnected;
  String? _error;

  LinkStatus get status => _status;
  String? get error => _error;

  Future<void> connect(AppSettings settings) async {
    _status = LinkStatus.error;
    _error = 'MQTT transport is not available yet (Phase 2). '
        'Smoker ID ${settings.smokerId.isEmpty ? "(not set)" : settings.smokerId} '
        'will use broker ${settings.mqttHost}:${settings.mqttPort} when enabled.';
  }

  Future<void> disconnect() async {
    _status = LinkStatus.disconnected;
    _error = null;
  }

  Future<void> sendCommand(String command) async {
    throw UnsupportedError('MQTT commands are not available yet.');
  }
}
