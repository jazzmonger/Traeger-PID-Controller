# Traeger Smoker Controller — Operation Summary

**Device:** `1-traeger-smoker` (ESP32-S3)  
**Config:** `1Traeger-S3.yaml`  
**Platform:** ESPHome firmware with local touchscreen UI, WiFi, API, and OTA

This controller replaces stock Traeger electronics. It manages pellet ignition, auger feed, hot rod, fans, and chamber temperature using a custom Smith-predictor PID loop tuned for pellet smokers.

---

## System Overview

The smoker runs as a **state machine** driven by the **System ON/OFF** (`go`) switch. When turned on, it lights the fire pot (temperature-gated), then enters either **Heating Mode** (PID temperature control) or **Smoking Mode** (low-temp auger cycling). A **Firepot Monitor** watches firepot temperature after lighting and can re-ignite the hot rod if the flame dies.

```
Power ON → Light Fire Pot → Heating Mode (default)
                              ↓ toggle Smoke Mode
                           Smoking Mode
Power OFF → Stop all → Cooldown fans (if chamber > 175°F)
```

---

## Hardware & Sensors

| Component | Purpose |
|-----------|---------|
| **MAX31865 RTD** (GPIO17) | Primary chamber temperature — drives PID control |
| **MAX6675 thermocouple** (GPIO15) | Firepot temperature — ignition & flame monitoring |
| **ADS1115 + thermistor** (A1) | Secondary temperature probe (A1) |
| **Rotary encoder** (GPIO8/18) | Adjust set temp or P-level |
| **ILI9341 touchscreen** (240×320) | Local display and touch controls |
| **GPIO outputs** | Fans (GPIO11), Auger (GPIO12), Hot Rod (GPIO13) |
| **GPIO inputs** | Power (GPIO10), Smoke (GPIO14), Temp Up/Down (GPIO45/38), Rotary push (GPIO3) |

**Temperature references (firepot, in °F equivalents):**

- Lighting complete: **300°F** (148.9°C)
- Heating mode hot rod on/off: **300°F / 325°F**
- Smoking mode hot rod on/off: **160°F / 200°F**
- Fan cooldown threshold: **175°F** (chamber RTD)

---

## Key Features

### 1. Automatic Fire Pot Lighting

On system start:

1. Hot rod and auger turn **ON**
2. Auger runs for **Pot lighting ON Time** (default 60s) to load pellets
3. Controller waits until firepot reaches **300°F**, up to **Pot lighting OFF Time** (default 600s)
4. If not lit in time: up to **3 retry** auger pulses (30s on / 30s off)
5. On success → **"Pot Lit"** → enters Heating Mode (hot rod stays on ~5 min, then firepot monitor takes over)
6. On failure → touchscreen dialog: *"Lighting failed, are pellets loaded?"* → system turns OFF; tap **OK** to dismiss

### 2. PID Temperature Control (Heating Mode)

- Runs during heating cycles when system is ON, smoke mode is OFF, and lighting is complete
- Uses chamber RTD vs. **Smoker Set Temperature** (140–550°F, default 225°F)
- Smith-predictor PID with:
  - Predictive error (rate-of-change + tau/theta lookahead)
  - Anti-windup and output clamping (5–80%)
  - Overshoot cutoff via **PID Stable Window**
- PID output maps to **auger ON/OFF duty cycle** within a 15s cycle
- All PID parameters exposed to Home Assistant for tuning

**Default PID tune (validated 2026-07-09 @ 225°F):** Pb=60, Ti=150, Td=40, tau=115, theta=25, center=0.001, stable_window=10

### 3. Smoking Mode

- Toggle via physical button, touchscreen, or HA switch (only effective when system ON)
- Turns **off** hot rod; stops lighting script
- Runs fixed **auger pulse cycle** instead of PID:
  - ON time: 10s (default)
  - OFF time: set by **P Select** (P0–P5 → 40–90s off times)
- Lower firepot hot-rod thresholds (160°F / 200°F) for gentle smoldering

### 4. P Select (Smoke Intensity)

Six presets (P0–P5) control smoke auger off-time:

| Level | Auger OFF time |
|-------|----------------|
| P0 | 40s |
| P1 | 50s |
| P2 | 60s |
| P3 | 70s |
| P4 | 80s |
| P5 | 90s |

Auger ON time stays at 10s for all levels. Adjust via rotary encoder (when in P-setting mode) or Home Assistant.

### 5. Firepot Flame Recovery

Every **10 seconds**, if system is running and lighting is complete (`lighting_flag_global` false):

- If firepot temp drops below threshold → hot rod **ON** (flame recovery)
- If firepot temp rises above upper threshold → hot rod **OFF**

Ignition owns the hot rod while lighting is in progress.

### 6. Fan Management

- Fans turn **ON** at system start and during smoking mode
- On system OFF, if chamber > **175°F**:
  - `sc_shutdown` keeps fans on for **20 minutes** (1200s), then rechecks
  - Repeats until chamber ≤ 175°F
- Manual fan off while system is still ON and hot also starts cooldown
- Boot: if chamber already hot, fans start immediately

### 7. Local Display

- **Heat** / **Smoke** virtual buttons (green/blue when active)
- Set temp vs. RTD temp (large digits)
- Animated fan icon when auger runs
- Hot rod indicator (red bar when on)
- Current P-level display
- Status bar at bottom (mode messages, errors)
- Lighting-failed modal with OK dismiss

### 8. Emergency Stop

`Emergency Stop` button (`sc_stop_all_smoking`):

- Stops all scripts (lighting, heating, smoking)
- Turns off hot rod and auger immediately

---

## User Controls

| Control | Action |
|---------|--------|
| **Power button** (GPIO10 / touchscreen) | Toggle System ON/OFF |
| **Smoke button** (GPIO14 / touchscreen) | Toggle Smoking Mode (only when system ON) |
| **Temp Up/Down** (GPIO45/38) | Adjust set temp or P-level (shared with rotary logic) |
| **Rotary encoder** | Adjust set temp (5°F fine ≤225°F; 25°F coarse above; 5°F if rotary pressed) or P-level |
| **Rotary click** | Toggle between adjusting **Temp** vs. **P Level** |
| **Touch Hot Rod** | Manual hot rod toggle (diagnostic/override) |
| **Touch OK** (lighting dialog) | Dismiss lighting-failed dialog |

---

## Operating Sequence (Typical Cook)

1. **Load pellets**, set desired temperature (default 225°F)
2. **Press Power** → status: *"Lighting Fire Pot"*
3. Hot rod + auger run until firepot hits 300°F (or failure dialog)
4. **Heating Mode** begins — PID modulates auger to reach setpoint
5. Optional: **Press Smoke** for low-and-slow smoldering (PID disabled)
6. **Press Power to stop** → auger/hot rod off → fans run cooldown if still hot

---

## Home Assistant Integration

Exposed entities include:

- **Switches:** System ON/OFF, Smoking Mode, Fans, Auger, Hot Rod
- **Sensors:** RTD Temp, Firepot Temp, A1 Temp, PID diagnostics, Lighting Flag
- **Numbers:** Set temp, all PID tuning params, auger timing, lighting times
- **Select:** P Select (P0–P5)
- **Text:** Status Message
- **Buttons:** Emergency Stop, Controller Restart

WiFi connects with fast_connect; OTA and 24h API reboot timeout enabled. Logger defaults to INFO (no unauthenticated web server).

---

## Safety Behaviors

- Hot rod and auger restore **ALWAYS_OFF** on reboot
- System OFF immediately stops auger and hot rod via `sc_stop_all_smoking`
- Lighting failure shows blocking dialog until user acknowledges
- Fan cooldown on system OFF when chamber is still hot
- Invalid RTD readings are filtered (NAN) and skipped by PID

---

## Configurable Parameters (Highlights)

| Parameter | Default | Range |
|-----------|---------|-------|
| Smoker Set Temperature | 225°F | 140–550°F |
| PID Cycle Time | 15s | fixed in firmware |
| Auger Heating ON/OFF | 15s / 1s | PID-adjusted in heating mode |
| Smoke ON/OFF | 10s / 40s | 5–20s / 5–90s |
| Pot Lighting ON Time | 60s | 1–120s |
| Pot Lighting OFF Time | 600s | 60–600s |
| Fan Shutdown Delay | 1200s (20 min) | fixed |

---

## Summary

Full-featured pellet smoker controller: temperature-gated ignition with failure dialog, predictive PID for stable cooks, dedicated smoke mode with P-level presets, flame recovery after lighting, and safe cooldown — controllable on the touchscreen or via Home Assistant.
