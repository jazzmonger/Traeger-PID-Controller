import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble/ble_protocol.dart';
import '../ble/ble_service.dart';
import '../models/app_settings.dart';
import '../mqtt/mqtt_service.dart';
import 'settings_storage.dart';

class SmokerController extends ChangeNotifier {
  SmokerController({
    SettingsStorage? storage,
    BleService? bleService,
    MqttService? mqttService,
  })  : _storage = storage ?? SettingsStorage(),
        _ble = bleService ?? BleService(),
        _mqtt = mqttService ?? MqttService();

  final SettingsStorage _storage;
  final BleService _ble;
  final MqttService _mqtt;

  AppSettings _settings = const AppSettings();
  SmokerState _state = SmokerState.disconnected;
  LinkStatus _linkStatus = LinkStatus.disconnected;
  String? _linkError;
  List<BleScanResult> _scanResults = [];
  final List<double> _chamberHistory = [];
  double _graphZoom = 1.0;
  StreamSubscription<SmokerState>? _bleSub;

  AppSettings get settings => _settings;
  SmokerState get state => _state;
  LinkStatus get linkStatus => _linkStatus;
  String? get linkError => _linkError;
  List<BleScanResult> get scanResults => _scanResults;
  List<double> get chamberHistory => List.unmodifiable(_chamberHistory);
  double get graphZoom => _graphZoom;

  bool get isBleTransport => _settings.transport == TransportMode.bluetooth;
  bool get isConnected => _linkStatus == LinkStatus.connected;

  Future<void> initialize({bool autoReconnect = true}) async {
    _settings = await _storage.load();
    _bleSub = _ble.stateStream.listen(_onBleState);
    notifyListeners();

    if (autoReconnect &&
        _settings.transport == TransportMode.bluetooth &&
        _settings.lastBleDeviceId.isNotEmpty) {
      await _ble.autoReconnectLast(
        _settings.lastBleDeviceId,
        name: _settings.lastBleDeviceName,
      );
      _syncLinkFromServices();
    }
  }

  void _onBleState(SmokerState s) {
    _state = s;
    if (s.chamberF > 0) {
      _chamberHistory.add(s.chamberF);
      if (_chamberHistory.length > 120) {
        _chamberHistory.removeAt(0);
      }
    }
    notifyListeners();
  }

  void _syncLinkFromServices() {
    if (_settings.transport == TransportMode.bluetooth) {
      _linkStatus = _ble.status;
      _linkError = _ble.error;
    } else {
      _linkStatus = _mqtt.status;
      _linkError = _mqtt.error;
    }
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    final transportChanged = settings.transport != _settings.transport;
    _settings = settings;
    await _storage.save(settings);
    notifyListeners();

    if (transportChanged) {
      await disconnect();
      if (settings.transport == TransportMode.bluetooth &&
          settings.lastBleDeviceId.isNotEmpty) {
        await _ble.autoReconnectLast(
          settings.lastBleDeviceId,
          name: settings.lastBleDeviceName,
        );
      }
      _syncLinkFromServices();
    }
  }

  Future<void> scanBle() async {
    _scanResults = await _ble.scan();
    _syncLinkFromServices();
    notifyListeners();
  }

  Future<void> connectBle(BluetoothDevice device, String name) async {
    await _ble.connect(device, displayName: name);
    _settings = _settings.copyWith(
      lastBleDeviceId: device.remoteId.str,
      lastBleDeviceName: name,
    );
    await _storage.save(_settings);
    _syncLinkFromServices();
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _ble.disconnect();
    await _mqtt.disconnect();
    _linkStatus = LinkStatus.disconnected;
    _state = SmokerState.disconnected;
    notifyListeners();
  }

  Future<void> connectTransport() async {
    _linkError = null;
    if (_settings.transport == TransportMode.bluetooth) {
      if (_settings.lastBleDeviceId.isNotEmpty) {
        try {
          await _ble.connectById(
            _settings.lastBleDeviceId,
            name: _settings.lastBleDeviceName,
          );
        } catch (e) {
          _linkError = e.toString();
        }
      } else {
        _linkError = 'No saved BLE device. Scan and connect in Settings.';
      }
    } else {
      await _mqtt.connect(_settings);
      _linkError = _mqtt.error;
    }
    _syncLinkFromServices();
    notifyListeners();
  }

  Future<void> sendCommand(String command) async {
    if (_settings.transport == TransportMode.bluetooth) {
      await _ble.sendCommand(command);
    } else {
      await _mqtt.sendCommand(command);
    }
  }

  Future<void> setSetpointF(int f) => sendCommand(Cst1BleCommands.setpointF(f));
  Future<void> togglePower() => sendCommand(Cst1BleCommands.powerToggle);
  Future<void> setHeatMode() => sendCommand(Cst1BleCommands.heatMode);
  Future<void> setSmokeMode() => sendCommand(Cst1BleCommands.smokeMode);
  Future<void> tempUp() => sendCommand(Cst1BleCommands.tempUp);
  Future<void> tempDown() => sendCommand(Cst1BleCommands.tempDown);
  Future<void> pUp() => sendCommand(Cst1BleCommands.pUp);
  Future<void> pDown() => sendCommand(Cst1BleCommands.pDown);
  Future<void> toggleAuger() => sendCommand(Cst1BleCommands.augerToggle);
  Future<void> toggleHotrod() => sendCommand(Cst1BleCommands.hotrodToggle);
  Future<void> prime() => sendCommand(Cst1BleCommands.prime);

  void zoomGraphIn() {
    _graphZoom = (_graphZoom * 1.25).clamp(0.5, 4.0);
    notifyListeners();
  }

  void zoomGraphOut() {
    _graphZoom = (_graphZoom / 1.25).clamp(0.5, 4.0);
    notifyListeners();
  }

  @override
  void dispose() {
    _bleSub?.cancel();
    _ble.dispose();
    super.dispose();
  }
}
