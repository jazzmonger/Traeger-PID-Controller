# CST1 BLE firmware (1-Pot Traeger)

ESP32-S3 firmware exposes a BLE GATT server so the **CST1** / **CST1Pot** iPhone apps can monitor and control the smoker without Wi‑Fi.

Canonical app-side profile: `apps/CST1/docs/CST1_BLE.md` (CST1 repo).

## GATT profile

| Item | UUID / value |
|------|----------------|
| Advertising name | `CS1Pot` |
| Service | `7c3f0001-8b4a-4e9f-9c1d-2a6b0e5f4d3c` |
| Ping (read) | `7c3f0002-…` → `CST 1-Pot` |
| Status (read + notify) | `7c3f0003-…` → CSV (see below) |
| Command (write) | `7c3f0004-…` → ASCII commands |

Status notifications are sent every **2 s** and **~40 ms** after each command.

### Status CSV (fields 0–13 + message)

`chamber°C,firepot°C,chamber°F,firepot°F,setpoint°F,go,smoke_mode,P,auger,hotrod,prime,pellet%,lighting,priming,status_msg`

Pellet level is `-` (VL53L0X sensor not enabled on this build). `status_msg` may contain commas.

### Commands

| Command | Maps to |
|---------|---------|
| `SPF <°F>` | `smoker_set_temp` |
| `UI 1` | Heat mode (`smoke_mode` off) |
| `UI 2` | Smoke mode (`smoke_mode` on) |
| `UI 50` | Toggle `go` (system power) |
| `UI 40` / `UI 41` | Temp up / down (same steps as rotary) |
| `UI 42` / `UI 43` | P level up / down |
| `UI 31` | Toggle `auger_1_sw` |
| `UI 11` | Toggle `hotrod_1_sw` |
| `PRIME` | `sc_prime_auger` (auger on for `pot_lighting_on_time`) |

BLE handlers call the same switches and scripts as the touchscreen and physical buttons.

## Config layout

- `1Traeger-S3.yaml` — main device config (includes BLE package)
- `common/1pot_ble.yaml` — `esp32_ble`, `esp32_ble_server`, status notify, command parser

Framework remains **Arduino** on ESP32-S3; no framework change required for BLE.

## Flash

1. Install tooling (from repo root):

   ```bash
   uv sync
   ```

2. Create `secrets.yaml` with `wifi_ssid` and `wifi_password` (standard ESPHome).

3. Build and upload:

   ```bash
   uv run esphome run 1Traeger-S3.yaml
   ```

   Or compile only:

   ```bash
   ./scripts/esphome-compile.sh compile
   ```

4. After boot, scan for **`CS1Pot`** in the CST1 app or a BLE scanner (nRF Connect). Service UUID `7c3f0001-…` should appear in advertising.

## Verify

1. Connect from CST1 / CST1Pot app (or subscribe to Status characteristic notifications).
2. Confirm CSV temps track RTD / firepot readings on the display.
3. Send `UI 50` or setpoint via app; confirm touchscreen / HA entities match.
4. Wi‑Fi, API, and OTA should remain functional alongside BLE.

## Notes

- BLE uses extra RAM on the ESP32-S3; the board already has octal PSRAM configured in the main YAML.
- If the device is tight on memory, reduce logger verbosity or disable unused features before adding more BLE characteristics.
