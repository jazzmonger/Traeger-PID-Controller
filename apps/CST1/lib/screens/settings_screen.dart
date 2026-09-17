import 'package:flutter/material.dart';

import '../ble/ble_protocol.dart';
import '../models/app_settings.dart';
import '../services/smoker_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final SmokerController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _smokerId;
  late final TextEditingController _mqttHost;
  late final TextEditingController _mqttPort;
  late final TextEditingController _mqttUser;
  late final TextEditingController _mqttPass;
  late final TextEditingController _haIp;
  TransportMode _transport = TransportMode.bluetooth;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    final s = widget.controller.settings;
    _smokerId = TextEditingController(text: s.smokerId);
    _mqttHost = TextEditingController(text: s.mqttHost);
    _mqttPort = TextEditingController(text: s.mqttPort.toString());
    _mqttUser = TextEditingController(text: s.mqttUsername);
    _mqttPass = TextEditingController(text: s.mqttPassword);
    _haIp = TextEditingController(text: s.homeAssistantIp);
    _transport = s.transport;
    widget.controller.addListener(_onController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _smokerId.dispose();
    _mqttHost.dispose();
    _mqttPort.dispose();
    _mqttUser.dispose();
    _mqttPass.dispose();
    _haIp.dispose();
    super.dispose();
  }

  void _onController() => setState(() {});

  Future<void> _save() async {
    final settings = AppSettings(
      smokerId: _smokerId.text.trim(),
      transport: _transport,
      mqttHost: _mqttHost.text.trim(),
      mqttPort: int.tryParse(_mqttPort.text.trim()) ?? 8883,
      mqttUsername: _mqttUser.text.trim(),
      mqttPassword: _mqttPass.text,
      homeAssistantIp: _haIp.text.trim(),
      lastBleDeviceId: widget.controller.settings.lastBleDeviceId,
      lastBleDeviceName: widget.controller.settings.lastBleDeviceName,
    );
    await widget.controller.updateSettings(settings);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    try {
      await widget.controller.scanBle();
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  String _linkLabel(LinkStatus status) {
    return switch (status) {
      LinkStatus.connected => 'Connected',
      LinkStatus.connecting => 'Connecting…',
      LinkStatus.scanning => 'Scanning…',
      LinkStatus.error => 'Error',
      LinkStatus.disconnected => 'Disconnected',
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final settings = c.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _smokerId,
            decoration: const InputDecoration(
              labelText: 'Smoker / Device ID',
              hintText: 'CST########',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Transport', style: TextStyle(fontWeight: FontWeight.w600)),
          RadioListTile<TransportMode>(
            title: const Text('Bluetooth (default)'),
            value: TransportMode.bluetooth,
            groupValue: _transport,
            onChanged: (v) => setState(() => _transport = v!),
          ),
          RadioListTile<TransportMode>(
            title: const Text('MQTT (Phase 2 stub)'),
            value: TransportMode.mqtt,
            groupValue: _transport,
            onChanged: (v) => setState(() => _transport = v!),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _mqttHost,
            decoration: const InputDecoration(
              labelText: 'MQTT broker host',
              hintText: 'millennial-mollusk.metalseed.net',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mqttPort,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'MQTT port',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mqttUser,
            decoration: const InputDecoration(
              labelText: 'MQTT username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mqttPass,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'MQTT password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _haIp,
            decoration: const InputDecoration(
              labelText: 'Home Assistant instance IP',
              hintText: '192.168.1.100',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BLE: ${_linkLabel(c.linkStatus)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (settings.lastBleDeviceName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Last device: ${settings.lastBleDeviceName}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  if (c.linkError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        c.linkError!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _scanning ? null : _scan,
                          icon: _scanning
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.bluetooth_searching),
                          label: Text(_scanning ? 'Scanning…' : 'Scan'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => c.connectTransport(),
                          icon: const Icon(Icons.bluetooth_connected),
                          label: const Text('Connect'),
                        ),
                      ),
                    ],
                  ),
                  if (c.scanResults.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Found devices:'),
                    ...c.scanResults.map(
                      (r) => ListTile(
                        dense: true,
                        title: Text(r.name),
                        subtitle: Text('${r.rssi} dBm'),
                        trailing: FilledButton(
                          onPressed: () => c.connectBle(r.device, r.name),
                          child: const Text('Pair'),
                        ),
                      ),
                    ),
                  ],
                  if (c.isConnected)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () => c.disconnect(),
                        child: const Text('Disconnect'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('Save settings'),
          ),
        ],
      ),
    );
  }
}
