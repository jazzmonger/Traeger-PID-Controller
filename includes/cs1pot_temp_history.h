#pragma once

#include <cmath>
#include <cstdint>

namespace cs1pot {

static constexpr int kHistIntervalSec = 30;
static constexpr int kHistLen = 480;  // 240 min @ 30 s (ring; lost on reboot)

static float g_hist[kHistLen];
static uint8_t g_hist_auger[kHistLen];
static int g_head = 0;
static int g_count = 0;

inline void hist_push(float temp_f, bool auger_on) {
  if (std::isnan(temp_f))
    return;
  g_hist[g_head] = temp_f;
  g_hist_auger[g_head] = auger_on ? 1u : 0u;
  g_head = (g_head + 1) % kHistLen;
  if (g_count < kHistLen)
    g_count++;
}

inline int hist_count() { return g_count; }

inline int hist_window_samples(int window_min) {
  if (window_min < 1)
    window_min = 1;
  int n = window_min * 60 / kHistIntervalSec;
  if (n < 2)
    n = 2;
  if (n > g_count)
    n = g_count;
  if (n > kHistLen)
    n = kHistLen;
  return n;
}

inline int hist_clamp_pan(int window_min, int time_pan) {
  const int want = hist_window_samples(window_min);
  const int max_pan = g_count - want;
  if (max_pan < 0)
    return 0;
  if (time_pan < 0)
    return 0;
  if (time_pan > max_pan)
    return max_pan;
  return time_pan;
}

inline int hist_age_for_slot(int pan, int window_samples, int slot) {
  return pan + (window_samples - 1 - slot);
}

inline float hist_get(int age_from_newest) {
  if (g_count == 0 || age_from_newest < 0 || age_from_newest >= g_count)
    return NAN;
  int idx = g_head - 1 - age_from_newest;
  while (idx < 0)
    idx += kHistLen;
  return g_hist[idx];
}

inline float hist_min_visible(int window_min, int time_pan) {
  const int pan = hist_clamp_pan(window_min, time_pan);
  const int n = hist_window_samples(window_min);
  float mn = NAN;
  for (int i = 0; i < n; i++) {
    const float v = hist_get(hist_age_for_slot(pan, n, i));
    if (std::isnan(v))
      continue;
    if (std::isnan(mn) || v < mn)
      mn = v;
  }
  return mn;
}

inline float hist_max_visible(int window_min, int time_pan) {
  const int pan = hist_clamp_pan(window_min, time_pan);
  const int n = hist_window_samples(window_min);
  float mx = NAN;
  for (int i = 0; i < n; i++) {
    const float v = hist_get(hist_age_for_slot(pan, n, i));
    if (std::isnan(v))
      continue;
    if (std::isnan(mx) || v > mx)
      mx = v;
  }
  return mx;
}

}  // namespace cs1pot
