#pragma once

#include "cs1pot_temp_history.h"
#include "esphome/components/display/display_buffer.h"
#include <cmath>
#include <cstring>

namespace cs1pot {

// Main-cook home layout (240x320) — neon cyan mock (Jeff v2)
static constexpr int kPad = 8;
static constexpr int kStatusY = 298;
static constexpr int kStatusH = 22;

static constexpr int kModeY = 8;
static constexpr int kModeOffX = 16;
static constexpr int kModeHeatX = 64;
static constexpr int kModeSmokeX = 118;
static constexpr int kGearX = 208;
static constexpr int kGearY = 6;

static constexpr int kArcCx = 120;
static constexpr int kArcCy = 102;
static constexpr int kArcR = 74;
static constexpr float kArcStart = 0.22f;
static constexpr float kArcEnd = 0.78f;

static constexpr int kChamberTempY = 54;
static constexpr int kChamberLblY = 82;
static constexpr int kFirepotY = 98;

static constexpr int kSetRowCy = 122;
static constexpr int kSetCircleR = 18;
static constexpr int kSetMinusCx = 32;
static constexpr int kSetPlusCx = 208;

static constexpr int kSmokeLabelY = 136;
static constexpr int kSmokeRowY = 152;
static constexpr int kSmokePillW = 40;
static constexpr int kSmokePillH = 28;
static constexpr int kSmokeGap = 2;
static constexpr int kSmokeStartX = 20;

static constexpr int kCardX = 12;
static constexpr int kCardY = 184;
static constexpr int kCardW = 216;
static constexpr int kCardH = 84;
static constexpr int kGraphPlotX = 18;
static constexpr int kGraphPlotY = 198;
static constexpr int kGraphPlotW = 204;
static constexpr int kGraphPlotH = 28;
static constexpr int kPelletBarY = 244;
static constexpr int kPelletBarH = 10;

static constexpr int kManY = 272;
static constexpr int kManH = 24;
static constexpr int kManW = 72;
static constexpr int kAugerX = 8;
static constexpr int kHotrodX = 84;
static constexpr int kPrimeX = 160;

static constexpr int kHomeGraphWindowMin = 120;

inline Color cook_bg_top() { return Color(8, 10, 12); }
inline Color cook_bg_bot() { return Color(16, 18, 22); }
inline Color cook_card() { return Color(12, 14, 18); }
inline Color cook_muted() { return Color(90, 98, 108); }
inline Color neon_cyan() { return Color(0, 255, 255); }
inline Color neon_glow() { return Color(0, 90, 100); }
inline Color neon_glow_soft() { return Color(0, 45, 52); }
inline Color cook_firepot() { return Color(255, 95, 60); }
inline Color cook_white() { return Color(255, 255, 255); }
inline Color track_grey() { return Color(42, 48, 54); }

inline void cook_fill_bg_gradient(esphome::display::Display &it) {
  it.filled_rectangle(0, 0, 240, 160, cook_bg_top());
  it.filled_rectangle(0, 160, 240, 160, cook_bg_bot());
}

inline void cook_arc_point_(int cx, int cy, int r, float t, int &x, int &y) {
  const float a = 3.14159265f * t;
  x = cx + (int) (r * cosf(a));
  y = cy - (int) (r * sinf(a));
}

inline void cook_draw_semi_arc(esphome::display::Display &it, int cx, int cy, int r, float t0, float t1,
                               Color c, bool glow) {
  const int steps = 24;
  int px = -1, py = -1;
  const int gr = glow ? r + 2 : r;
  for (int i = 0; i <= steps; i++) {
    const float t = t0 + (t1 - t0) * i / steps;
    int x, y;
    cook_arc_point_(cx, cy, gr, t, x, y);
    if (px >= 0) {
      it.line(px, py, x, y, c);
      if (glow) it.line(px, py + 1, x, y + 1, neon_glow_soft());
    }
    px = x;
    py = y;
  }
}

inline void cook_draw_chamber_gauge(esphome::display::Display &it, float chamber_f, float set_f) {
  float frac = 0.35f;
  if (!isnan(chamber_f) && !isnan(set_f) && set_f > 50.0f) {
    frac = chamber_f / set_f;
    if (frac < 0.05f) frac = 0.05f;
    if (frac > 1.0f) frac = 1.0f;
  }
  cook_draw_semi_arc(it, kArcCx, kArcCy, kArcR, kArcStart, kArcEnd, track_grey(), false);
  const float t_fill = kArcStart + (kArcEnd - kArcStart) * frac;
  cook_draw_semi_arc(it, kArcCx, kArcCy, kArcR + 1, kArcStart, t_fill, neon_glow(), true);
  cook_draw_semi_arc(it, kArcCx, kArcCy, kArcR, kArcStart, t_fill, neon_cyan(), false);
}

inline void cook_draw_mode_tab(esphome::display::Display &it, esphome::font::Font *font14, int x, int y,
                               const char *label, bool active) {
  const Color c = active ? neon_cyan() : cook_muted();
  it.print(x, y, font14, c, label);
  if (active) {
    const int w = (int) strlen(label) * 8;
    it.filled_rectangle(x - 1, y + 15, w + 2, 3, neon_glow_soft());
    it.filled_rectangle(x, y + 16, w, 2, neon_cyan());
  }
}

inline void cook_draw_circle_btn(esphome::display::Display &it, int cx, int cy, int r, bool minus) {
  it.circle(cx, cy, r + 2, neon_glow_soft());
  it.circle(cx, cy, r, neon_cyan());
  if (minus) {
    it.line(cx - 7, cy, cx + 7, cy, cook_white());
    it.line(cx - 7, cy + 1, cx + 7, cy + 1, cook_white());
  } else {
    it.line(cx - 7, cy, cx + 7, cy, cook_white());
    it.line(cx, cy - 7, cx, cy + 7, cook_white());
  }
}

inline void cook_draw_gear(esphome::display::Display &it, int cx, int cy, Color c) {
  it.circle(cx, cy, 10, c);
  it.filled_circle(cx, cy, 4, cook_bg_top());
  for (int i = 0; i < 8; i++) {
    const float a = i * 3.14159265f / 4.0f;
    const int x1 = cx + (int) (6 * cosf(a));
    const int y1 = cy + (int) (6 * sinf(a));
    const int x2 = cx + (int) (10 * cosf(a));
    const int y2 = cy + (int) (10 * sinf(a));
    it.line(x1, y1, x2, y2, c);
  }
}

inline void cook_draw_smoke_pill(esphome::display::Display &it, esphome::font::Font *font14, int x, int y, int w,
                                 int h, int digit, bool active) {
  if (active) {
    it.filled_rectangle(x, y, w, h, neon_cyan());
    it.rectangle(x, y, w, h, neon_cyan());
    char d[2] = {(char) ('0' + digit), '\0'};
    it.print(x + w / 2 - 4, y + 7, font14, Color(0, 0, 0), d);
  } else {
    it.filled_rectangle(x, y, w, h, cook_card());
    it.rectangle(x, y, w, h, neon_cyan());
    char d[2] = {(char) ('0' + digit), '\0'};
    it.print(x + w / 2 - 4, y + 7, font14, neon_cyan(), d);
  }
}

inline void cook_draw_pill_manual(esphome::display::Display &it, esphome::font::Font *font14, int x, int y, int w,
                                  int h, bool on, const char *label, int pad) {
  if (on) {
    it.filled_rectangle(x, y, w, h, neon_cyan());
    it.rectangle(x - 1, y - 1, w + 2, h + 2, neon_glow_soft());
    it.print(x + pad, y + (h - 14) / 2, font14, Color(0, 0, 0), label);
  } else {
    it.filled_rectangle(x, y, w, h, cook_card());
    it.rectangle(x, y, w, h, neon_cyan());
    it.print(x + pad, y + (h - 14) / 2, font14, neon_cyan(), label);
  }
}

inline int cook_smoke_pill_x(int pill_one_based) {
  return kSmokeStartX + (pill_one_based - 1) * (kSmokePillW + kSmokeGap);
}

inline int cook_status_center_x(const char *msg, int char_w) {
  int len = (int) strlen(msg);
  int w = len * char_w;
  int x = (240 - w) / 2;
  if (x < kPad)
    x = kPad;
  return x;
}

// Touch helpers (rect bounds)
static constexpr int kTouchModeY0 = 4;
static constexpr int kTouchModeY1 = 28;
static constexpr int kTouchSetPad = 4;

}  // namespace cs1pot
