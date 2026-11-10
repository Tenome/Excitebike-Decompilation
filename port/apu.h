/* Sound layer for the PC port: turns the game's APU register writes ($4000-$4017) into samples
 * (two pulse channels, triangle, noise and the direct DMC level). */
#pragma once
#include <stdint.h>

typedef struct { int enabled, len, duty, step, timer_period, timer, const_vol, vol, loop, env_start, env_div, env_decay;
                 int sweep_en, sweep_period, sweep_neg, sweep_shift, sweep_reload, sweep_div, ones_complement; } Pulse;
typedef struct { int enabled, len, ctrl, lin_reload_val, lin, lin_reload, timer_period, timer, step; } Triangle;
typedef struct { int enabled, len, const_vol, vol, loop, env_start, env_div, env_decay, mode, period, timer; uint16_t shift; } Noise;
typedef struct {
    Pulse p[2]; Triangle tri; Noise noise; int dmc_level;
    int pal_region, five_step; double seq_cycles; int seq_next; double cpu_clock; double hp_in, hp_out;
} Apu;

void apu_init(Apu *a, int pal_region);
void apu_write(Apu *a, uint16_t reg, uint8_t v);
void apu_run(Apu *a, int16_t *out, int samples, int sample_rate);   /* mono, 16-bit */
