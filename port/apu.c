#include "apu.h"
#include <string.h>
#include <math.h>

static const uint8_t LEN_TABLE[32] = { 10,254,20,2,40,4,80,6,160,8,60,10,14,12,26,14,12,16,24,18,48,20,96,22,192,24,72,26,16,28,32,30 };
static const uint8_t DUTY[4][8] = { {0,1,0,0,0,0,0,0}, {0,1,1,0,0,0,0,0}, {0,1,1,1,1,0,0,0}, {1,0,0,1,1,1,1,1} };
static const uint16_t NOISE_NTSC[16] = { 4,8,16,32,64,96,128,160,202,254,380,508,762,1016,2034,4068 };
static const uint16_t NOISE_PAL[16] = { 4,8,14,30,60,88,118,148,188,236,354,472,708,944,1890,3778 };

void apu_init(Apu *a, int pal_region) {
    memset(a, 0, sizeof *a);
    a->pal_region = pal_region; a->cpu_clock = pal_region ? 1662607.0 : 1789773.0;
    a->p[0].ones_complement = 1; a->noise.shift = 1;
}

void apu_write(Apu *a, uint16_t reg, uint8_t v) {
    if (reg >= 0x4000 && reg <= 0x4007) {
        Pulse *p = &a->p[(reg - 0x4000) >> 2];
        switch (reg & 3) {
        case 0: p->duty = v >> 6; p->loop = (v >> 5) & 1; p->const_vol = (v >> 4) & 1; p->vol = v & 15; break;
        case 1: p->sweep_en = v >> 7; p->sweep_period = (v >> 4) & 7; p->sweep_neg = (v >> 3) & 1; p->sweep_shift = v & 7; p->sweep_reload = 1; break;
        case 2: p->timer_period = (p->timer_period & 0x700) | v; break;
        case 3: p->timer_period = (p->timer_period & 0xFF) | ((v & 7) << 8);
                if (p->enabled) p->len = LEN_TABLE[v >> 3];
                p->step = 0; p->env_start = 1; break;
        }
        return;
    }
    switch (reg) {
    case 0x4008: a->tri.ctrl = v >> 7; a->tri.lin_reload_val = v & 0x7F; break;
    case 0x400A: a->tri.timer_period = (a->tri.timer_period & 0x700) | v; break;
    case 0x400B: a->tri.timer_period = (a->tri.timer_period & 0xFF) | ((v & 7) << 8);
                 if (a->tri.enabled) a->tri.len = LEN_TABLE[v >> 3];
                 a->tri.lin_reload = 1; break;
    case 0x400C: a->noise.loop = (v >> 5) & 1; a->noise.const_vol = (v >> 4) & 1; a->noise.vol = v & 15; break;
    case 0x400E: a->noise.mode = v >> 7; a->noise.period = (a->pal_region ? NOISE_PAL : NOISE_NTSC)[v & 15]; break;
    case 0x400F: if (a->noise.enabled) a->noise.len = LEN_TABLE[v >> 3]; a->noise.env_start = 1; break;
    case 0x4011: a->dmc_level = v & 0x7F; break;
    case 0x4015:
        a->p[0].enabled = v & 1; a->p[1].enabled = (v >> 1) & 1; a->tri.enabled = (v >> 2) & 1; a->noise.enabled = (v >> 3) & 1;
        if (!a->p[0].enabled) a->p[0].len = 0;
        if (!a->p[1].enabled) a->p[1].len = 0;
        if (!a->tri.enabled) a->tri.len = 0;
        if (!a->noise.enabled) a->noise.len = 0;
        break;
    case 0x4017:
        a->five_step = (v >> 7) & 1; a->seq_cycles = 0; a->seq_next = 0;
        if (a->five_step) { extern void apu_clock_frame(Apu *, int, int); apu_clock_frame(a, 1, 1); }
        break;
    default: break;
    }
}

static void env_clock(int *start, int *div, int *decay, int loop, int vol) {
    if (*start) { *start = 0; *decay = 15; *div = vol; }
    else if (*div > 0) (*div)--;
    else { *div = vol; if (*decay > 0) (*decay)--; else if (loop) *decay = 15; }
}
static int sweep_target(const Pulse *p) {
    int d = p->timer_period >> p->sweep_shift;
    if (p->sweep_neg) return p->timer_period - d - (p->ones_complement ? 1 : 0);
    return p->timer_period + d;
}
void apu_clock_frame(Apu *a, int quarter, int half) {
    if (quarter) {
        for (int i = 0; i < 2; i++) env_clock(&a->p[i].env_start, &a->p[i].env_div, &a->p[i].env_decay, a->p[i].loop, a->p[i].vol);
        env_clock(&a->noise.env_start, &a->noise.env_div, &a->noise.env_decay, a->noise.loop, a->noise.vol);
        if (a->tri.lin_reload) a->tri.lin = a->tri.lin_reload_val; else if (a->tri.lin > 0) a->tri.lin--;
        if (!a->tri.ctrl) a->tri.lin_reload = 0;
    }
    if (half) {
        for (int i = 0; i < 2; i++) {
            Pulse *p = &a->p[i];
            if (!p->loop && p->len > 0) p->len--;
            if (p->sweep_div == 0 && p->sweep_en && p->sweep_shift && p->timer_period >= 8) {
                int t = sweep_target(p); if (t <= 0x7FF) p->timer_period = t;
            }
            if (p->sweep_div == 0 || p->sweep_reload) { p->sweep_div = p->sweep_period; p->sweep_reload = 0; } else p->sweep_div--;
        }
        if (!a->tri.ctrl && a->tri.len > 0) a->tri.len--;
        if (!a->noise.loop && a->noise.len > 0) a->noise.len--;
    }
}

static void clock_cpu_cycles(Apu *a, int n) {
    for (int c = 0; c < n; c++) {
        if ((a->seq_next < 4 || (a->five_step ? 0 : 0)) ) {}
        a->seq_cycles += 1;
        static const int T5[4] = { 7457, 14913, 22371, 37281 }, T4[4] = { 7457, 14913, 22371, 29829 };
        if (a->seq_next < 4 && a->seq_cycles >= (a->five_step ? T5 : T4)[a->seq_next]) {
            int s = a->seq_next++;
            if (a->five_step) { apu_clock_frame(a, 1, s == 1 || s == 3); }
            else { apu_clock_frame(a, 1, s == 1 || s == 3); }
        }
        if (c & 1) {                                                   /* pulse timers run at half CPU speed */
            for (int i = 0; i < 2; i++) { Pulse *p = &a->p[i]; if (p->timer-- <= 0) { p->timer = p->timer_period; p->step = (p->step + 1) & 7; } }
            if (a->noise.timer-- <= 0) {
                a->noise.timer = a->noise.period ? a->noise.period : 4;
                int bit = a->noise.mode ? 6 : 1;
                int fb = (a->noise.shift & 1) ^ ((a->noise.shift >> bit) & 1);
                a->noise.shift = (uint16_t)((a->noise.shift >> 1) | (fb << 14));
            }
        }
        if (a->tri.timer-- <= 0) {
            a->tri.timer = a->tri.timer_period;
            if (a->tri.len > 0 && a->tri.lin > 0) a->tri.step = (a->tri.step + 1) & 31;
        }
    }
}

void apu_run(Apu *a, int16_t *out, int samples, int sample_rate) {
    double per = a->cpu_clock / sample_rate, acc = 0;
    for (int s = 0; s < samples; s++) {
        acc += per; int n = (int)acc; acc -= n;
        clock_cpu_cycles(a, n);
        int pul = 0;
        for (int i = 0; i < 2; i++) {
            Pulse *p = &a->p[i];
            int mute = p->len == 0 || p->timer_period < 8 || (!p->sweep_neg && sweep_target(p) > 0x7FF) || !DUTY[p->duty][p->step];
            if (!mute) pul += p->const_vol ? p->vol : p->env_decay;
        }
        int tri = a->tri.timer_period < 2 ? 7 : (a->tri.step < 16 ? 15 - a->tri.step : a->tri.step - 16);
        int noi = 0;
        if (a->noise.len > 0 && !(a->noise.shift & 1)) noi = a->noise.const_vol ? a->noise.vol : a->noise.env_decay;
        double pulse_out = pul ? 95.88 / (8128.0 / pul + 100.0) : 0.0;
        double tnd_in = tri / 8227.0 + noi / 12241.0 + a->dmc_level / 22638.0;
        double tnd_out = tnd_in > 0 ? 159.79 / (1.0 / tnd_in + 100.0) : 0.0;
        double m = pulse_out + tnd_out;
        double y = m - a->hp_in + 0.9996 * a->hp_out;                  /* the console's output stage blocks DC */
        a->hp_in = m; a->hp_out = y;
        out[s] = (int16_t)(y * 24000.0);
    }
}
