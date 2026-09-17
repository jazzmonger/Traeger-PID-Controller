# CST1 — Chain Smoker 1-Pot Controller

Flutter iOS app for Jeff Stevenson's **Chain Smoker 1-Pot** (Traeger / CST 1-Pot) pellet smoker controller.

Phase 1 uses **Bluetooth LE** (`flutter_blue_plus`). Phase 2 will add **MQTT** cloud transport (settings are saved now; connect returns "not available yet").

## Requirements

- macOS with Xcode (for building/running on a physical iPhone)
- Flutter SDK 3.24+ ([install guide](https://docs.flutter.dev/get-started/install))
- CocoaPods (`sudo gem install cocoapods`)
- iPhone with Bluetooth enabled, near the smoker controller

## Run on Jeff's iPhone

```bash
cd apps/CST1
flutter pub get
cd ios && pod install && cd ..
flutter devices          # confirm iPhone is listed
flutter run -d ios       # or: flutter run -d <device-id>
```

For release builds:

```bash
flutter build ios --release
```

Open `ios/Runner.xcworkspace` in Xcode, select your Team under **Signing & Capabilities**, then run on the device.

| Setting | Value |
|---------|-------|
| Display name | **CST1** |
| Bundle ID | `com.chainsmokers.cst1` |
| BLE advert name | **CS1Pot** (preferred) |

## BLE pairing

1. Power on the 1-pot controller with BLE firmware flashed (GATT profile below).
2. Open **CST1** → tap **SETTINGS** (or gear icon).
3. Under **BLE**, tap **Scan**. Look for **CS1Pot** (or `CST-1Pot`).
4. Tap **Pair** on the desired device. The app saves the last device and auto-reconnects on launch.
5. Return to the home screen — status bar shows live telemetry when connected.

### GATT profile (`7c3f000*` namespace — distinct from CST 5-Pot `7c2f000*`)

| Characteristic | UUID | Access |
|----------------|------|--------|
| Service | `7c3f0001-8b4a-4e9f-9c1d-2a6b0e5f4d3c` | — |
| Ping | `7c3f0002-8b4a-4e9f-9c1d-2a6b0e5f4d3c` | Read → `"CST 1-Pot"` |
| Status | `7c3f0003-8b4a-4e9f-9c1d-2a6b0e5f4d3c` | Read + Notify (CSV) |
| Command | `7c3f0004-8b4a-4e9f-9c1d-2a6b0e5f4d3c` | Write |

**Status CSV fields:** chamber °C/°F, firepot °C/°F, setpoint °F, go, smoke_mode, P index, auger, hotrod, prime, pellet %, lighting, priming, status text.

**Commands (ASCII):** `SPF <°F>`, `UI 1` (Heat), `UI 2` (Smoke), `UI 50` (power), `UI 40/41` (temp ±), `UI 42/43` (P ±), `UI 31` (auger), `UI 11` (hotrod), `PRIME`.

> **Note:** Current `1Traeger-S3.yaml` firmware uses WiFi/ESPHome API only — BLE GATT must be added to firmware to pair with this app. See `docs/CST1_BLE.md`.

## Settings fields

| Field | Purpose |
|-------|---------|
| **Smoker / Device ID** | Unique unit ID for MQTT fleet (e.g. `CSTg6wz77`) |
| **Transport** | Bluetooth (default) or MQTT (stub) |
| **MQTT broker host** | e.g. `millennial-mollusk.metalseed.net` |
| **MQTT port** | `8883` (TLS) |
| **MQTT username / password** | Per-device credentials when Phase 2 ships |
| **Home Assistant IP** | Local HA instance for integrations (e.g. `192.168.1.50`) |
| **BLE scan / connect** | Pair and manage Bluetooth link |

## Home screen layout

Mirrors the on-device 240×320 UI:

- **ON | Heat | Smoke | SETTINGS** mode row
- **SET / CHAMBER** temperature heroes with ± controls
- **Smoke P** row (P0–P5)
- Chamber temperature graph with zoom +/−
- Firepot strip (lighting / priming indicators)
- Smoker chamber diagram (animated fan, hotrod bar)
- **Auger / Hotrod / Prime** actuator buttons
- Status bar (link indicator, message, pellet %)

## Development

```bash
cd apps/CST1
flutter analyze
flutter test
```

## Related repos

- **Traeger-PID-Controller** — ESPHome firmware for the 1-pot hardware (`1Traeger-S3.yaml`)
- **CST_5Pot** — 5-pot Flutter app and BLE/MQTT reference (do not mix UUID namespaces)
