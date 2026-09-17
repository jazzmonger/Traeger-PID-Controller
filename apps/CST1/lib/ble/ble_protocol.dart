/// GATT profile for CST 1-Pot (CS1Pot) — distinct UUID namespace from CST 5-Pot (`7c2f000*`).
///
/// Firmware reference: future `esp32_ble_server` on `1Traeger-S3.yaml` should match these UUIDs
/// and the CSV status layout below. See `docs/CST1_BLE.md` in the app README.
library;

class Cst1BleUuids {
  static const service = '7c3f0001-8b4a-4e9f-9c1d-2a6b0e5f4d3c';
  static const ping = '7c3f0002-8b4a-4e9f-9c1d-2a6b0e5f4d3c';
  static const status = '7c3f0003-8b4a-4e9f-9c1d-2a6b0e5f4d3c';
  static const command = '7c3f0004-8b4a-4e9f-9c1d-2a6b0e5f4d3c';
}

/// Preferred BLE advertising / local name for 1-pot hardware.
const kCst1PreferredAdvName = 'CS1Pot';

/// Accepted advertising name prefixes (case-insensitive).
const kCst1AdvNamePrefixes = ['CS1Pot', 'CST-1Pot', 'CST1'];

/// ASCII command helpers written to the Command characteristic.
class Cst1BleCommands {
  static String setpointF(int f) => 'SPF $f';
  static const heatMode = 'UI 1';
  static const smokeMode = 'UI 2';
  static const powerToggle = 'UI 50';
  static const tempUp = 'UI 40';
  static const tempDown = 'UI 41';
  static const pUp = 'UI 42';
  static const pDown = 'UI 43';
  static const augerToggle = 'UI 31';
  static const hotrodToggle = 'UI 11';
  static const prime = 'PRIME';
}

/// Parsed status notify payload (CSV).
///
/// | Index | Field |
/// |-------|-------|
/// | 0 | Chamber temp °C |
/// | 1 | Firepot temp °C |
/// | 2 | Chamber temp °F |
/// | 3 | Firepot temp °F |
/// | 4 | Setpoint °F |
/// | 5 | go / power (0/1) |
/// | 6 | smoke_mode (0=heat, 1=smoke) |
/// | 7 | P index (0–5) |
/// | 8 | auger (0/1) |
/// | 9 | hotrod (0/1) |
/// | 10 | prime (0/1) |
/// | 11 | pellet % (0–100 or `-`) |
/// | 12 | lighting (0/1) |
/// | 13 | priming (0/1) |
/// | 14+ | status_msg (remainder, may contain commas) |
class SmokerState {
  const SmokerState({
    this.chamberC = 0,
    this.firepotC = 0,
    this.chamberF = 0,
    this.firepotF = 0,
    this.setpointF = 225,
    this.powerOn = false,
    this.smokeMode = false,
    this.pIndex = 0,
    this.augerOn = false,
    this.hotrodOn = false,
    this.primeOn = false,
    this.pelletPercent,
    this.lighting = false,
    this.priming = false,
    this.statusMessage = 'Disconnected',
    this.lastUpdated,
  });

  final double chamberC;
  final double firepotC;
  final double chamberF;
  final double firepotF;
  final int setpointF;
  final bool powerOn;
  final bool smokeMode;
  final int pIndex;
  final bool augerOn;
  final bool hotrodOn;
  final bool primeOn;
  final int? pelletPercent;
  final bool lighting;
  final bool priming;
  final String statusMessage;
  final DateTime? lastUpdated;

  static const disconnected = SmokerState(statusMessage: 'Disconnected');

  String get pLabel => 'P$pIndex';

  CookMode get cookMode =>
      !powerOn ? CookMode.off : (smokeMode ? CookMode.smoke : CookMode.heat);

  static SmokerState parse(String raw) {
    final parts = raw.split(',');
    if (parts.length < 14) return disconnected;

    double d(int i) => double.tryParse(parts[i].trim()) ?? 0;
    int i(int idx) => int.tryParse(parts[idx].trim()) ?? 0;
    bool b(int idx) => parts[idx].trim() == '1';

    int? pellet;
    final pelletRaw = parts[11].trim();
    if (pelletRaw != '-' && pelletRaw.isNotEmpty) {
      pellet = int.tryParse(pelletRaw);
    }

    final msg = parts.length > 14 ? parts.sublist(14).join(',').trim() : '';

    return SmokerState(
      chamberC: d(0),
      firepotC: d(1),
      chamberF: d(2),
      firepotF: d(3),
      setpointF: i(4),
      powerOn: b(5),
      smokeMode: b(6),
      pIndex: i(7).clamp(0, 5),
      augerOn: b(8),
      hotrodOn: b(9),
      primeOn: b(10),
      pelletPercent: pellet,
      lighting: b(12),
      priming: b(13),
      statusMessage: msg.isEmpty ? 'OK' : msg,
      lastUpdated: DateTime.now(),
    );
  }

  SmokerState copyWith({
    double? chamberC,
    double? firepotC,
    double? chamberF,
    double? firepotF,
    int? setpointF,
    bool? powerOn,
    bool? smokeMode,
    int? pIndex,
    bool? augerOn,
    bool? hotrodOn,
    bool? primeOn,
    int? pelletPercent,
    bool? lighting,
    bool? priming,
    String? statusMessage,
    DateTime? lastUpdated,
  }) {
    return SmokerState(
      chamberC: chamberC ?? this.chamberC,
      firepotC: firepotC ?? this.firepotC,
      chamberF: chamberF ?? this.chamberF,
      firepotF: firepotF ?? this.firepotF,
      setpointF: setpointF ?? this.setpointF,
      powerOn: powerOn ?? this.powerOn,
      smokeMode: smokeMode ?? this.smokeMode,
      pIndex: pIndex ?? this.pIndex,
      augerOn: augerOn ?? this.augerOn,
      hotrodOn: hotrodOn ?? this.hotrodOn,
      primeOn: primeOn ?? this.primeOn,
      pelletPercent: pelletPercent ?? this.pelletPercent,
      lighting: lighting ?? this.lighting,
      priming: priming ?? this.priming,
      statusMessage: statusMessage ?? this.statusMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

enum CookMode { off, heat, smoke }

enum LinkStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

enum TransportMode { bluetooth, mqtt }
