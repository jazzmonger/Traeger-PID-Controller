import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_protocol.dart';

class BleScanResult {
  BleScanResult({required this.device, required this.name, required this.rssi});

  final BluetoothDevice device;
  final String name;
  final int rssi;
}

class BleService {
  BleService();

  final _stateController = StreamController<SmokerState>.broadcast();
  Stream<SmokerState> get stateStream => _stateController.stream;

  LinkStatus _status = LinkStatus.disconnected;
  String? _error;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _commandChar;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  Timer? _reconnectTimer;
  String? _lastDeviceId;
  String? _lastDeviceName;

  LinkStatus get status => _status;
  String? get error => _error;
  String? get connectedDeviceName => _lastDeviceName;
  bool get isConnected => _status == LinkStatus.connected;

  static bool isCst1Device(String name) {
    if (name.isEmpty) return false;
    final upper = name.toUpperCase();
    return kCst1AdvNamePrefixes.any((p) => upper.startsWith(p.toUpperCase()));
  }

  Future<List<BleScanResult>> scan({Duration timeout = const Duration(seconds: 8)}) async {
    _setStatus(LinkStatus.scanning);
    _error = null;

    if (await FlutterBluePlus.isSupported == false) {
      _setStatus(LinkStatus.error);
      _error = 'Bluetooth not supported on this device.';
      return [];
    }

    final results = <String, BleScanResult>{};
    final sub = FlutterBluePlus.scanResults.listen((scanResults) {
      for (final r in scanResults) {
        final name = r.device.platformName.isNotEmpty
            ? r.device.platformName
            : r.advertisementData.advName;
        if (!isCst1Device(name)) continue;
        results[r.device.remoteId.str] = BleScanResult(
          device: r.device,
          name: name,
          rssi: r.rssi,
        );
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: timeout);
      await Future<void>.delayed(timeout);
      await FlutterBluePlus.stopScan();
    } finally {
      await sub.cancel();
    }

    _setStatus(LinkStatus.disconnected);
    return results.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
  }

  Future<void> connect(BluetoothDevice device, {String? displayName}) async {
    await disconnect();
    _setStatus(LinkStatus.connecting);
    _error = null;
    _lastDeviceId = device.remoteId.str;
    _lastDeviceName = displayName ?? device.platformName;

    try {
      await device.connect(autoConnect: false, timeout: const Duration(seconds: 15));
      _device = device;

      _connSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnect();
        }
      });

      final services = await device.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid.str.toLowerCase() == Cst1BleUuids.service.toLowerCase(),
        orElse: () => throw StateError('CST1 GATT service not found'),
      );

      final statusChar = service.characteristics.firstWhere(
        (c) => c.uuid.str.toLowerCase() == Cst1BleUuids.status.toLowerCase(),
      );
      _commandChar = service.characteristics.firstWhere(
        (c) => c.uuid.str.toLowerCase() == Cst1BleUuids.command.toLowerCase(),
      );

      await statusChar.setNotifyValue(true);
      _notifySub = statusChar.lastValueStream.listen(_onStatusBytes);

      final initial = await statusChar.read();
      _onStatusBytes(initial);

      _setStatus(LinkStatus.connected);
      _scheduleReconnect(enable: false);
    } catch (e) {
      _error = e.toString();
      _setStatus(LinkStatus.error);
      await disconnect();
      rethrow;
    }
  }

  Future<void> connectById(String deviceId, {String? name}) async {
    final device = BluetoothDevice.fromId(deviceId);
    await connect(device, displayName: name);
  }

  Future<void> autoReconnectLast(String? deviceId, {String? name}) async {
    if (deviceId == null || deviceId.isEmpty) return;
    try {
      await connectById(deviceId, name: name);
    } catch (_) {
      _scheduleReconnect(enable: true, deviceId: deviceId, name: name);
    }
  }

  void _scheduleReconnect({
    required bool enable,
    String? deviceId,
    String? name,
  }) {
    _reconnectTimer?.cancel();
    if (!enable) return;
    final id = deviceId ?? _lastDeviceId;
    final n = name ?? _lastDeviceName;
    if (id == null || id.isEmpty) return;

    _reconnectTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_status == LinkStatus.connected || _status == LinkStatus.connecting) {
        return;
      }
      try {
        await connectById(id, name: n);
      } catch (_) {
        // keep trying
      }
    });
  }

  void _handleDisconnect() {
    _notifySub?.cancel();
    _notifySub = null;
    _commandChar = null;
    _setStatus(LinkStatus.disconnected);
    _stateController.add(SmokerState.disconnected);
    _scheduleReconnect(enable: true);
  }

  void _onStatusBytes(List<int> bytes) {
    if (bytes.isEmpty) return;
    final raw = utf8.decode(bytes, allowMalformed: true).trim();
    if (raw.isEmpty) return;
    _stateController.add(SmokerState.parse(raw));
  }

  Future<void> sendCommand(String command) async {
    final char = _commandChar;
    if (char == null) throw StateError('Not connected');
    final data = utf8.encode(command);
    await char.write(data, withoutResponse: true);
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _notifySub?.cancel();
    _notifySub = null;
    await _connSub?.cancel();
    _connSub = null;
    _commandChar = null;

    final device = _device;
    _device = null;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (_) {}
    }
    if (_status != LinkStatus.scanning) {
      _setStatus(LinkStatus.disconnected);
    }
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _notifySub?.cancel();
    _connSub?.cancel();
    _stateController.close();
  }

  void _setStatus(LinkStatus s) {
    _status = s;
  }

  (String?, String?) get lastDevice => (_lastDeviceId, _lastDeviceName);
}
