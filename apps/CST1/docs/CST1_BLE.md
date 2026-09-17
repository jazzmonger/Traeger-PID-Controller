# CST1 BLE GATT Profile

Chain Smoker **1-Pot** Bluetooth Low Energy profile. UUID namespace `7c3f000*` is intentionally distinct from the CST 5-Pot family (`7c2f000*`).

## Advertising

| Field | Value |
|-------|-------|
| Local name | `CS1Pot` (preferred) |
| Service UUID | `7c3f0001-8b4a-4e9f-9c1d-2a6b0e5f4d3c` |

## Characteristics

### Ping (`7c3f0002-…`)

Read-only ASCII: `CST 1-Pot`

### Status (`7c3f0003-…`)

Read + Notify. CSV payload, notify every ~2 s and immediately after command (~40 ms settle).

| Idx | Field | Type |
|-----|-------|------|
| 0 | Chamber temp °C | float |
| 1 | Firepot temp °C | float |
| 2 | Chamber temp °F | float |
| 3 | Firepot temp °F | float |
| 4 | Setpoint °F | int |
| 5 | go (power) | 0/1 |
| 6 | smoke_mode | 0=heat, 1=smoke |
| 7 | P index | 0–5 |
| 8 | auger | 0/1 |
| 9 | hotrod | 0/1 |
| 10 | prime | 0/1 |
| 11 | pellet % | 0–100 or `-` |
| 12 | lighting | 0/1 |
| 13 | priming | 0/1 |
| 14+ | status_msg | string (may contain commas) |

Example:

```
107.2,148.9,225,300,225,1,0,2,1,0,0,75,0,0,Pot Lit
```

### Command (`7c3f0004-…`)

Write / Write Without Response. ASCII commands:

| Command | Action |
|---------|--------|
| `SPF <°F>` | Set setpoint |
| `UI 1` | Heat mode |
| `UI 2` | Smoke mode |
| `UI 50` | Toggle power |
| `UI 40` / `UI 41` | Temp up / down |
| `UI 42` / `UI 43` | P up / down |
| `UI 31` | Toggle auger |
| `UI 11` | Toggle hotrod |
| `PRIME` | Prime auger |

## Firmware integration

Add `esp32_ble_server` (or equivalent) to `1Traeger-S3.yaml` mapping ESPHome entities:

- `rtd_temperature_f` / `firepot_temperature_f` → status fields
- `smoker_set_temp` → setpoint
- `go`, `smoke_mode`, `p_select`, `auger_1_sw`, `hotrod_1_sw` → status bits
- `status_msg` → trailing text field

Command handler should mirror UART/UI actions already used on the touchscreen.
