#pragma once

#include "cs1pot_temp_history.h"
#include "esphome/components/display/display_buffer.h"

namespace cs1pot {

// Main-cook home layout (240x320 portrait) — Jeff mock 05-pellets-firepot
static constexpr int kPad = 8;
static constexpr int kStatusY = 286;
static constexpr int kStatusH = 34;

static constexpr int kModeY = 4;
static constexpr int kModeH = 28;
static constexpr int kModeW = 50;
static constexpr int kModeGap = 4;
static constexpr int kModeOffX = 8;
static constexpr int kModeHeatX = 62;
static constexpr int kModeSmokeX = 116;
static constexpr int kGearX = 178;
static constexpr int kGearW = 54;

static constexpr int kChamberNumY = 40;
static constexpr int kChamberLblY = 72;
static constexpr int kFirepotY = 92;

static constexpr int kSetRowY = 108;
static constexpr int kSetRowH = 34;
static constexpr int kSetBtnW = 44;
static constexpr int kSetMinusX = 8;
static constexpr int kSetCenterX = 56;
static constexpr int kSetCenterW = 128;
static constexpr int kSetPlusX = 188;

static constexpr int kSmokeRowY = 146;
static constexpr int kSmokeRowH = 28;
static constexpr int kSmokePillW = 38;
static constexpr int kSmokeGap = 3;
static constexpr int kSmokeStartX = 21;

static constexpr int kGraphCardX = 8;
static constexpr int kGraphCardY = 178;
static constexpr int kGraphCardW = 224;
static constexpr int kGraphCardH = 46;
static constexpr int kGraphPlotX = 12;
static constexpr int kGraphPlotY = 194;
static constexpr int kGraphPlotW = 216;
static constexpr int kGraphPlotH = 26;

static constexpr int kPelletY = 228;
static constexpr int kPelletH = 24;
static constexpr int kPelletBarX = 8;
static constexpr int kPelletBarW = 224;

static constexpr int kManY = 256;
static constexpr int kManH = 28;
static constexpr int kManW = 72;
static constexpr int kAugerX = 8;
static constexpr int kHotrodX = 84;
static constexpr int kPrimeX = 160;

static constexpr int kHomeGraphWindowMin = 120;

inline Color cook_bg() { return Color(18, 18, 18); }
inline Color cook_card() { return Color(38, 38, 38); }
inline Color cook_muted() { return Color(140, 140, 140); }
inline Color cook_amber() { return Color(248, 164, 55); }
inline Color cook_cyan() { return Color(78, 205, 196); }
inline Color cook_firepot() { return Color(255, 90, 70); }
inline Color cook_white() { return Color(250, 250, 250); }

inline void cook_draw_round_btn(esphome::display::Display &it, int x, int y, int w, int h, bool active,
                                Color active_fill, Color border, Color fg, Color fg_active) {
  it.filled_rectangle(x, y, w, h, active ? active_fill : cook_card());
  it.rectangle(x, y, w, h, active ? active_fill : border);
}

inline void cook_draw_minus(esphome::display::Display &it, int cx, int cy, Color c) {
  it.line(cx - 8, cy, cx + 8, cy, c);
  it.line(cx - 8, cy + 1, cx + 8, cy + 1, c);
}

inline void cook_draw_plus(esphome::display::Display &it, int cx, int cy, Color c) {
  cook_draw_minus(it, cx, cy, c);
  it.line(cx, cy - 8, cx, cy + 8, c);
  it.line(cx + 1, cy - 8, cx + 1, cy + 8, c);
}

inline void cook_draw_gear(esphome::display::Display &it, int cx, int cy, Color c) {
  it.circle(cx, cy, 9, c);
  it.filled_circle(cx, cy, 4, cook_card());
  for (int i = 0; i < 8; i++) {
    float a = i * 3.14159265f / 4.0f;
    int x1 = cx + (int) (7 * cosf(a));
    int y1 = cy + (int) (7 * sinf(a));
    int x2 = cx + (int) (11 * cosf(a));
    int y2 = cy + (int) (11 * sinf(a));
    it.line(x1, y1, x2, y2, c);
  }
}

inline void cook_draw_manual(esphome::display::Display &it, esphome::font::Font *font14, int x, int y, int w, int h,
                             bool on, Color on_color, const char *label, int label_pad) {
  if (on) {
    it.filled_rectangle(x, y, w, h, on_color);
    it.rectangle(x, y, w, h, cook_white());
    it.print(x + label_pad, y + (h - 14) / 2, font14, cook_white(), label);
  } else {
    it.filled_rectangle(x, y, w, h, cook_card());
    it.rectangle(x, y, w, h, cook_muted());
    it.print(x + label_pad, y + (h - 14) / 2, font14, cook_cyan(), label);
  }
}

inline int cook_smoke_pill_x(int pill_one_based) {
  return kSmokeStartX + (pill_one_based - 1) * (kSmokePillW + kSmokeGap);
}

inline int cook_status_center_x(const char *msg, int char_w) {
  int len = 0;
  while (msg[len] != '\0')
    len++;
  int w = len * char_w;
  int x = (240 - w) / 2;
  if (x < kPad)
    x = kPad;
  return x;
}

}  // namespace cs1pot
