# On-grill ILI9341 main-cook UI (240×320 portrait)

Jeff’s approved **neon cyan** main-cook mock is implemented in:

- `packages/cs1pot_display_ui.yaml` — draw lambda + fonts
- `packages/cs1pot_display_touch.yaml` — touch zones
- `packages/cs1pot_display_scripts.yaml` — cook mode, prime, smoke pills
- `packages/cs1pot_history.yaml` — chamber sparkline buffer (120m @ 30s)
- `includes/cs1pot_main_cook_ui.h` — layout constants (keep in sync with touch YAML)

`1Traeger-S3.yaml` includes these packages instead of `common/1Traeger-S3_display.yaml`.

## Flash / OTA (1-pot ESP32-S3)

1. Install ESPHome (repo: `./scripts/esphome-compile.sh` or `uv run esphome`).
2. Copy `secrets.yaml` from your existing deploy (Wi‑Fi + API keys); do not commit secrets.
3. **USB (first flash or recovery)**  
   ```bash
   ./scripts/esphome-compile.sh run
   ```  
   Select the ESP32-S3 serial port when prompted.
4. **OTA (after device is on Wi‑Fi)**  
   ```bash
   ./scripts/esphome-compile.sh run 1Traeger-S3.yaml --device <smoker-hostname>.local
   ```  
   Or use the ESPHome Dashboard → **Install** → **Wirelessly** on `1-traeger-smoker`.
5. Confirm the panel shows OFF | Heat | Smoke, chamber hero, setpoint row, smoke pills 1–5, **Chamber 120m** graph, **PELLETS** bar, Auger/Hotrod/Prime, and cyan status footer.

Pellet **%** reads `pellet_level_pct` (NaN until VL53L0X hopper sensor is enabled in YAML). Cook controls use existing `go`, `cook_mode`, `smoker_set_temp`, `p_select`, auger/hotrod GPIO, and prime scripts—same paths as the new touch map.
