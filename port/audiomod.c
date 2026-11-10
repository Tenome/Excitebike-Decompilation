#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "audiomod.h"
#include "../c/excitebike.h"

#define MAXV 8
typedef struct { int16_t *s; int n; } Clip;
static Clip g_clip[4][256];
static const char *CH[4] = { "music", "noise", "pulse2", "pulse1" };
typedef struct { const Clip *c; int pos, loop; } Voice;
static Clip g_engine; static double g_engine_pos, g_engine_rate; static int g_engine_on;     /* engine.wav: looped, pitch follows the engine request */
static Voice g_voice[MAXV];

static uint32_t rd32(const uint8_t *p) { return p[0] | p[1] << 8 | p[2] << 16 | (uint32_t)p[3] << 24; }
static uint16_t rd16(const uint8_t *p) { return (uint16_t)(p[0] | p[1] << 8); }

static int load_wav(const char *path, Clip *out) {         /* converts to 44100 Hz mono 16-bit */
    FILE *f = fopen(path, "rb"); if (!f) return 0;
    fseek(f, 0, SEEK_END); long sz = ftell(f); fseek(f, 0, SEEK_SET);
    uint8_t *b = malloc(sz > 0 ? sz : 1); if (!b || fread(b, 1, sz, f) != (size_t)sz) { fclose(f); free(b); return 0; } fclose(f);
    int ok = 0, fmt = 0, ch = 0, bits = 0; uint32_t rate = 0; const uint8_t *data = NULL; uint32_t dn = 0;
    if (sz >= 12 && !memcmp(b, "RIFF", 4) && !memcmp(b + 8, "WAVE", 4)) {
        for (long p = 12; p + 8 <= sz;) {
            uint32_t cn = rd32(b + p + 4); const uint8_t *cd = b + p + 8;
            if (p + 8 + (long)cn > sz) cn = (uint32_t)(sz - p - 8);
            if (!memcmp(b + p, "fmt ", 4) && cn >= 16) { fmt = rd16(cd); ch = rd16(cd + 2); rate = rd32(cd + 4); bits = rd16(cd + 14); }
            else if (!memcmp(b + p, "data", 4)) { data = cd; dn = cn; }
            p += 8 + cn + (cn & 1);
        }
        ok = data && fmt == 1 && (ch == 1 || ch == 2) && (bits == 8 || bits == 16) && rate > 0;
    }
    if (ok) {
        int fs = ch * bits / 8; long frames = dn / fs; long on = (long)((double)frames * 44100.0 / rate);
        int16_t *o = malloc((on > 0 ? on : 1) * 2);
        for (long i = 0; i < on; i++) {
            long si = (long)((double)i * rate / 44100.0); if (si >= frames) si = frames - 1;
            int sum = 0;
            for (int c = 0; c < ch; c++) sum += bits == 16 ? (int16_t)rd16(data + si * fs + c * 2) : ((int)data[si * fs + c] - 128) * 256;
            o[i] = (int16_t)(sum / ch);
        }
        out->s = o; out->n = (int)on;
    } else fprintf(stderr, "audio mod: cannot use %s (need PCM 8/16-bit WAV)\n", path);
    free(b); return ok;
}

int audiomod_load(const char *dir) {
    int found = 0; char path[512];
    for (int c = 0; c < 4; c++) for (int v = 1; v < 256; v++) {
        snprintf(path, sizeof path, "%s/%s_%02x.wav", dir, CH[c], v);
        FILE *f = fopen(path, "rb"); if (!f) continue; fclose(f);
        if (load_wav(path, &g_clip[c][v])) found++;
    }
    snprintf(path, sizeof path, "%s/engine.wav", dir);
    { FILE *f = fopen(path, "rb"); if (f) { fclose(f); if (load_wav(path, &g_engine)) found++; } }
    if (found) g_hal_sound = audiomod_request;
    return found;
}

int audiomod_request(int chan, int value) {
    if (chan == SND_ENGINE) {                                  /* every frame while an engine runs: value = pitch step (0-48), bit 7 = the player's bike */
        if (!g_engine.s || g_engine.n < 2) return 0;
        g_engine_on = 1; g_engine_rate = 0.5 + (value & 0x7F) / 48.0 * 1.2; return 1;
    }
    const Clip *c = &g_clip[chan][value & 255]; if (!c->s) return 0;
    if (chan == SND_MUSIC) for (int i = 0; i < MAXV; i++) if (g_voice[i].loop) g_voice[i].c = NULL;      /* a new song replaces the old one */
    for (int i = 0; i < MAXV; i++) if (!g_voice[i].c) { g_voice[i] = (Voice){ c, 0, chan == SND_MUSIC }; return 1; }
    return 1;                                                                                           /* all voices busy: drop it */
}

void audiomod_mix(int16_t *buf, int n) {
    if (g_engine_on) {
        for (int k = 0; k < n; k++) {
            int i = (int)g_engine_pos; double fr = g_engine_pos - i; int j = (i + 1) % g_engine.n;
            int s = buf[k] + (int)(g_engine.s[i] * (1 - fr) + g_engine.s[j] * fr);
            buf[k] = (int16_t)(s > 32767 ? 32767 : s < -32768 ? -32768 : s);
            g_engine_pos += g_engine_rate; if (g_engine_pos >= g_engine.n) g_engine_pos -= g_engine.n;
        }
    }
    for (int i = 0; i < MAXV; i++) {
        Voice *v = &g_voice[i]; if (!v->c) continue;
        for (int k = 0; k < n; k++) {
            if (v->pos >= v->c->n) { if (v->loop && v->c->n > 0) v->pos = 0; else { v->c = NULL; break; } }
            int s = buf[k] + v->c->s[v->pos++];
            buf[k] = (int16_t)(s > 32767 ? 32767 : s < -32768 ? -32768 : s);
        }
    }
}

void audiomod_frame(void) { g_engine_on = 0; }
