/* Excitebike native PC port: window, input, timing and audio around the lifted C game (c/excitebike.c).
 * No CPU emulation: the game is C; this file feeds it a controller and shows the picture and sound it produces.
 *   excitebike [rom.nes] [--scale N] [--unlimited-sprites] [--frames N --shot out.bmp [--press frame=buttons,...]]
 * The ROM is only read for its data tables, graphics and sound data (it is not shipped). */
#define SDL_MAIN_HANDLED
#include <SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../c/excitebike.h"
#include "ppu.h"
#include "apu.h"
#include "audiomod.h"

static Ppu g_ppu;
static Apu g_apu;
static uint8_t g_pad_latch[2], g_pad_bits[2];

static void hal_write(uint16_t a, uint8_t v) {
    if ((a >= 0x2000 && a < 0x2008)) ppu_write(&g_ppu, a, v);
    else if (a == 0x4014) { ppu_write(&g_ppu, a, v); ppu_advance(&g_ppu, 513); }
    else if (a == 0x4016) { if (!(v & 1)) { g_pad_latch[0] = g_pad_bits[0]; g_pad_latch[1] = g_pad_bits[1]; } }
    else if (a >= 0x4000 && a <= 0x4017) apu_write(&g_apu, a, v);
}
static uint8_t hal_read(uint16_t a) {
    if (a == 0x2002) { ppu_advance(&g_ppu, 9); return ppu_read(&g_ppu, a); }      /* a status poll loop takes time */
    if (a == 0x2004 || a == 0x2007) return ppu_read(&g_ppu, a);
    if (a == 0x4016 || a == 0x4017) { int p = a & 1; uint8_t v = g_pad_latch[p] & 1; g_pad_latch[p] = (uint8_t)((g_pad_latch[p] >> 1) | 0x80); return v; }
    return 0;
}
static void audio_apu_w(uint16_t a, uint8_t v) { apu_write(&g_apu, a, v); }
static void hal_event(int ev, int arg) {
    if (ev == HAL_EV_DELAY) ppu_advance(&g_ppu, arg);
    else if (ev == HAL_EV_SPRITES) {                       /* tag the OAM slots a rider or shadow was drawn into (see SprTags) */
        unsigned u = (unsigned)arg; int own = (int)(u >> 29), s = (int)((u >> 23) & 63), e = (int)((u >> 16) & 127);
        for (int i = s; i < e && i < 64; i++) g_ppu.tag_next.owner[i] = (uint8_t)own;
        g_ppu.tag_next.ax[own] = (int16_t)((u >> 8) & 255); g_ppu.tag_next.ay[own] = (int16_t)(u & 255); g_ppu.tag_next.seen[own] = 1;
    }
}

typedef struct { char magic[8]; uint8_t ram[0x800]; Ppu ppu; Apu apu; uint8_t latch[2], bits[2]; int pal; } SaveState;
static void state_save(const char *path) {
    static SaveState st; memcpy(st.magic, "EBSAVE1", 8); memcpy(st.ram, g_ram, sizeof st.ram); st.ppu = g_ppu; st.apu = g_apu;
    memcpy(st.latch, g_pad_latch, 2); memcpy(st.bits, g_pad_bits, 2); st.pal = g_pal;
    FILE *f = fopen(path, "wb"); if (f) { fwrite(&st, sizeof st, 1, f); fclose(f); fprintf(stderr, "state saved to %s\n", path); }
}
static int state_load(const char *path) {
    static SaveState st; FILE *f = fopen(path, "rb"); if (!f) return 0;
    size_t n = fread(&st, sizeof st, 1, f); fclose(f);
    if (n != 1 || memcmp(st.magic, "EBSAVE1", 8) || st.pal != g_pal) return 0;
    const uint8_t *chr = g_ppu.chr; int unl = g_ppu.unlimited_sprites;
    memcpy(g_ram, st.ram, sizeof st.ram); g_ppu = st.ppu; g_apu = st.apu; g_ppu.chr = chr; g_ppu.cpu_ram = g_ram; g_ppu.unlimited_sprites = unl;
    memcpy(g_pad_latch, st.latch, 2); memcpy(g_pad_bits, st.bits, 2);
    return 1;
}

static void present_and_wait(SDL_Renderer *ren, SDL_Texture *tex, Uint64 *next, Uint64 slice, SDL_AudioDeviceID dev) {
    Uint64 freq = SDL_GetPerformanceFrequency();
    SDL_RenderClear(ren); SDL_RenderCopy(ren, tex, NULL, NULL); SDL_RenderPresent(ren);
    *next += slice;
    Uint64 now = SDL_GetPerformanceCounter();
    while (dev && SDL_GetQueuedAudioSize(dev) > 44100 / 8 * 2) SDL_Delay(1);
    if (now < *next) { Uint64 wait = *next - now; if (wait > freq / 200) SDL_Delay((Uint32)(wait * 1000 / freq) - 1); while (SDL_GetPerformanceCounter() < *next) { } }
    else *next = now;
}

static uint8_t read_pad(const uint8_t *keys) {            /* bit 0 = A (first bit shifted out) ... bit 7 = Right */
    uint8_t b = 0;
    if (keys[SDL_SCANCODE_Z]) b |= 0x01;                  /* A: accelerate */
    if (keys[SDL_SCANCODE_X]) b |= 0x02;                  /* B: turbo */
    if (keys[SDL_SCANCODE_RSHIFT] || keys[SDL_SCANCODE_BACKSPACE]) b |= 0x04;   /* Select */
    if (keys[SDL_SCANCODE_RETURN]) b |= 0x08;             /* Start */
    if (keys[SDL_SCANCODE_UP]) b |= 0x10;
    if (keys[SDL_SCANCODE_DOWN]) b |= 0x20;
    if (keys[SDL_SCANCODE_LEFT]) b |= 0x40;
    if (keys[SDL_SCANCODE_RIGHT]) b |= 0x80;
    return b;
}

/* Track designs: the design menu's SAVE and LOAD talk to the Famicom Data Recorder on the real machine (the game's idle loop runs the tape routines
 * when ResetState is 1 = save or 2 = load). Here they use a file instead: the 64 bytes of zero page from $60 (header, times) and the 256-byte design at $05E0. */
static const char *designs_path = "designs.ebd";
static void tape_service(void) {
    uint8_t st = g_ram[0x48];
    if (st == 0 || (st & 0x80)) return;
    DisableNmi();
    FILE *f = fopen(designs_path, st == 1 ? "wb" : "rb");
    if (f) {
        static uint8_t full[2300];
        int ln = g_design_long ? DesignAssemble(full, sizeof full) : 0;
        if (st == 1 && ln > 0) { fwrite("EBDES2", 1, 6, f); fputc(ln & 255, f); fputc(ln >> 8, f); fwrite(full, 1, (size_t)ln, f); }      /* a long design (see --long-designs) */
        else if (st == 1) { fwrite("EBDES1", 1, 6, f); fwrite(g_ram + 0x60, 1, 0x40, f); fwrite(g_ram + 0x05E0, 1, 0x100, f); }
        else {
            char magic[6]; uint8_t zp[0x40], design[0x100];
            if (fread(magic, 1, 6, f) == 6 && !memcmp(magic, "EBDES2", 6)) {
                int c0 = fgetc(f), c1 = fgetc(f); int n = c0 | c1 << 8; size_t got = n > 0 && n <= (int)sizeof full ? fread(full, 1, (size_t)n, f) : 0;
                if (g_design_long && (int)got == n && n >= 3) DesignExtImport(full, n); else fprintf(stderr, "%s holds a long design: start with --long-designs (or the LONG DESIGNS menu item)\n", designs_path);
            } else if (!memcmp(magic, "EBDES1", 6) && fread(zp, 1, 0x40, f) == 0x40 && fread(design, 1, 0x100, f) == 0x100) {
                memcpy(g_ram + 0x60, zp, sizeof zp); memcpy(g_ram + 0x05E0, design, sizeof design); if (g_design_long) DesignExtReset();
            } else fprintf(stderr, "%s is not a track design file\n", designs_path);
        }
        fclose(f);
    } else if (st != 1) fprintf(stderr, "no %s to load\n", designs_path);
    g_ram[0x48] = 0xFF;
    WaitVblankEndEnableNmi();
}

/* Graphics mods: a 128x256 8-bit indexed BMP (see tools/chrbmp.py) or a raw 8 KB CHR file replaces the tiles; a 192-byte RGB file replaces the 64 colours. */
static int load_chr_bmp(const char *path, uint8_t *chr) {
    SDL_Surface *s = SDL_LoadBMP(path);
    if (!s || s->format->BitsPerPixel != 8 || s->w != 128 || s->h != 256) { fprintf(stderr, "%s: need a 128x256 8-bit BMP\n", path); if (s) SDL_FreeSurface(s); return 0; }
    const uint8_t *px = s->pixels;
    for (int table = 0; table < 2; table++) for (int tile = 0; tile < 256; tile++) {
        int base = table * 0x1000 + tile * 16, tx = tile % 16, ty = tile / 16 + table * 16;
        for (int row = 0; row < 8; row++) {
            int lo = 0, hi = 0;
            for (int c = 0; c < 8; c++) { int v = px[(ty * 8 + row) * s->pitch + tx * 8 + c] & 3; lo = (lo << 1) | (v & 1); hi = (hi << 1) | (v >> 1); }
            chr[base + row] = (uint8_t)lo; chr[base + 8 + row] = (uint8_t)hi;
        }
    }
    SDL_FreeSurface(s);
    return 1;
}
static int load_file(const char *path, void *dst, size_t n) { FILE *f = fopen(path, "rb"); if (!f) return 0; size_t r = fread(dst, 1, n, f); fclose(f); return r == n; }

/* Graphics mods are re-read on F6 (together with the track files): edit tiles.bmp / colors.pal in the editors, save, press F6. */
static uint8_t g_pk_tile[512][16]; static unsigned char g_pk_tile_set[512]; static uint8_t g_pk_rgb[64][3]; static unsigned char g_pk_rgb_set[64];   /* level pack extras, filled by pack_extras_parse */
static const char *s_chr_bmp, *s_chr_raw, *s_pal_file; static uint8_t *s_chr_data; static uint8_t s_rom_chr[0x2000]; static uint32_t s_rgb_default[64];
static void reload_graphics(void) {
    memcpy(s_chr_data, s_rom_chr, sizeof s_rom_chr);
    if (s_chr_raw && !load_file(s_chr_raw, s_chr_data, 0x2000)) fprintf(stderr, "cannot read 8 KB CHR file %s\n", s_chr_raw);
    if (s_chr_bmp && !load_chr_bmp(s_chr_bmp, s_chr_data)) fprintf(stderr, "cannot use tile BMP %s\n", s_chr_bmp);
    memcpy(g_ppu.rgb, s_rgb_default, sizeof s_rgb_default);
    if (s_pal_file) { uint8_t rgb[192]; if (load_file(s_pal_file, rgb, sizeof rgb)) { for (int i = 0; i < 64; i++) g_ppu.rgb[i] = 0xFF000000u | (uint32_t)rgb[i * 3] << 16 | (uint32_t)rgb[i * 3 + 1] << 8 | rgb[i * 3 + 2]; } else fprintf(stderr, "cannot read 192-byte palette file %s\n", s_pal_file); }
    for (int t = 0; t < 512; t++) if (g_pk_tile_set[t]) memcpy(s_chr_data + t * 16, g_pk_tile[t], 16);                       /* level pack extras */
    for (int i = 0; i < 64; i++) if (g_pk_rgb_set[i]) g_ppu.rgb[i] = 0xFF000000u | (uint32_t)g_pk_rgb[i][0] << 16 | (uint32_t)g_pk_rgb[i][1] << 8 | g_pk_rgb[i][2];
}

/* Custom tracks: `--track N=file.ebd` replaces built-in track N (1-5) or the designed track (6) with a track made by the editor (tools/editor) or by the game's own design mode.
 * Tracks may be longer than the original design limit; F6 reloads the files while the game runs (a track is read when its race starts). */
static int width_opt = 416, fps_mult = 1;                 /* picture width while racing; output frames per game frame */
static const char *g_track_file[6];
static int b64_value(int c);
/* Level pack extras: tile differences, palette colours and a song that travel inside a .ebpack.json (see tools/levelpack.py); applied by reload_graphics(). */
static void pack_extras_clear(void) { memset(g_pk_tile_set, 0, sizeof g_pk_tile_set); memset(g_pk_rgb_set, 0, sizeof g_pk_rgb_set); }
static const char *json_array(const char *json, const char *key, const char **end) {        /* the text inside "key": [ ... ] (no nested arrays in our files) */
    char pat[32]; snprintf(pat, sizeof pat, "\"%s\"", key); const char *k = strstr(json, pat); if (!k) return NULL;
    k = strchr(k + strlen(pat), '['); if (!k) return NULL; const char *e = strchr(k, ']'); if (!e) return NULL; *end = e; return k + 1;
}
static int hexv(int c) { return c >= '0' && c <= '9' ? c - '0' : c >= 'a' && c <= 'f' ? c - 'a' + 10 : c >= 'A' && c <= 'F' ? c - 'A' + 10 : -1; }
static void pack_extras_parse(const char *json) {
    const char *end, *p;
    if ((p = json_array(json, "tiles", &end))) while (p < end) {
        const char *n = strstr(p, "\"n\""), *d = strstr(p, "\"d\""); if (!n || !d || n >= end || d >= end) break;
        int tn = atoi(strchr(n, ':') + 1); const char *q = strchr(d + 3, '"'); if (!q) break; q++;
        uint8_t out[24]; size_t m = 0; unsigned acc = 0; int bits = 0;
        for (; *q && *q != '"'; q++) { int v = b64_value((unsigned char)*q); if (v < 0) continue; acc = acc << 6 | (unsigned)v; bits += 6; if (bits >= 8) { bits -= 8; if (m < sizeof out) out[m++] = (uint8_t)(acc >> bits); acc &= (1u << bits) - 1; } }
        if (tn >= 0 && tn < 512 && m >= 16) { memcpy(g_pk_tile[tn], out, 16); g_pk_tile_set[tn] = 1; }
        p = q + 1; const char *close = strchr(p, '}'); if (!close) break; p = close + 1;
    }
    if ((p = json_array(json, "palette", &end))) while (p < end) {
        const char *i = strstr(p, "\"i\""), *r = strstr(p, "\"rgb\""); if (!i || !r || i >= end || r >= end) break;
        int pi = atoi(strchr(i, ':') + 1); const char *q = strchr(r + 5, '"'); if (!q) break; q++;
        if (pi >= 0 && pi < 64 && hexv(q[0]) >= 0 && hexv(q[5]) >= 0) { for (int c = 0; c < 3; c++) g_pk_rgb[pi][c] = (uint8_t)(hexv(q[c * 2]) << 4 | hexv(q[c * 2 + 1])); g_pk_rgb_set[pi] = 1; }
        const char *close = strchr(q, '}'); if (!close) break; p = close + 1;
    }
    if ((p = json_array(json, "pieces", &end))) while (p < end) {                    /* custom track pieces: {"id": 36, "data": "<base64 of a column list>"} */
        const char *i = strstr(p, "\"id\""), *d = strstr(p, "\"data\""); if (!i || !d || i >= end || d >= end) break;
        int pid = atoi(strchr(i, ':') + 1); const char *q = strchr(d + 6, ':'); q = q ? strchr(q, '"') : NULL; if (!q) break; q++;
        uint8_t col[512]; size_t m = 0; unsigned acc = 0; int bits = 0;
        for (; *q && *q != '"'; q++) { int v = b64_value((unsigned char)*q); if (v < 0) continue; acc = acc << 6 | (unsigned)v; bits += 6; if (bits >= 8) { bits -= 8; if (m < sizeof col) col[m++] = (uint8_t)(acc >> bits); acc &= (1u << bits) - 1; } }
        if (m >= 2) PieceCustomSet(pid, col, (int)m);
        const char *close = strchr(q, '}'); if (!close) break; p = close + 1;
    }
    const char *sg = strstr(json, "\"song\"");
    if (sg) {
        const char *rq = strstr(sg, "\"request\""), *eb = strstr(sg, "\"ebm\"");
        if (rq && eb) {
            rq = strchr(rq + 9, '"'); eb = strchr(eb + 5, ':'); if (rq && eb) {
                int req = hexv(rq[1]) << 4 | hexv(rq[2]); eb = strchr(eb, '"');
                static char ebm[24000]; size_t m = 0;
                if (eb) for (eb++; *eb && *eb != '"' && m < sizeof ebm - 1; eb++) {
                    if (*eb == '\\' && eb[1]) { eb++; ebm[m++] = *eb == 'n' ? '\n' : *eb == 't' ? '\t' : *eb == 'r' ? '\r' : *eb; } else ebm[m++] = *eb;
                }
                ebm[m] = 0; if (req > 0 && m > 4) audiomod_install_song(req, ebm);
            }
        }
    }
}
static int b64_value(int c) { return c >= 'A' && c <= 'Z' ? c - 'A' : c >= 'a' && c <= 'z' ? c - 'a' + 26 : c >= '0' && c <= '9' ? c - '0' + 52 : c == '+' ? 62 : c == '/' ? 63 : -1; }
static size_t pack_track_bytes(const char *json, uint8_t *out, size_t cap) {       /* the "track" field of a level pack (*.ebpack.json, see tools/levelpack.py) */
    const char *k = strstr(json, "\"track\""); if (!k) return 0;
    k = strchr(k + 7, '"'); if (!k) return 0; k++;
    size_t n = 0; unsigned acc = 0; int bits = 0;
    for (; *k && *k != '"'; k++) { int v = b64_value((unsigned char)*k); if (v < 0) continue; acc = acc << 6 | (unsigned)v; bits += 6; if (bits >= 8) { bits -= 8; if (n < cap) out[n++] = (uint8_t)(acc >> bits); acc &= (1u << bits) - 1; } }
    return n;
}
static int load_track_file(int slot, const char *path) {
    static uint8_t buf[70000]; size_t n; FILE *f = fopen(path, "rb"); if (!f) return 0;
    n = fread(buf, 1, sizeof buf, f); fclose(f);
    const uint8_t *st; size_t avail;
    static uint8_t packed[0x2000]; static char text[70000];
    if (n > 0 && buf[0] == '{') {                       /* level pack */
        size_t m = n < sizeof text - 1 ? n : sizeof text - 1; memcpy(text, buf, m); text[m] = 0;
        avail = pack_track_bytes(text, packed, sizeof packed); st = packed; if (avail < 3) return 0;
        pack_extras_parse(text);
    } else
    if (n >= 326 && !memcmp(buf, "EBDES1", 6)) { st = buf + 70; avail = 256; }
    else if (n >= 8 && !memcmp(buf, "EBDES2", 6)) { st = buf + 8; avail = n - 8; if (avail > (size_t)(buf[6] | buf[7] << 8)) avail = (size_t)(buf[6] | buf[7] << 8); }
    else return 0;
    size_t i = 1;                                        /* walk the script to its end: piece 9 (finish line) or 0 */
    while (i < avail) { uint8_t b = st[i++]; if (b == 0 || b == 9) break; if (b & 0x40) i++; }
    if (i > avail) return 0;
    static uint8_t out[0x2000 + 2]; memcpy(out, st, i); out[i] = 0;
    return TrackExtSet(slot, out, (int)i + 1);
}
static void load_tracks(void) {
    pack_extras_clear(); PieceCustomClear();
    for (int k = 0; k < 6; k++) if (g_track_file[k]) {
        if (load_track_file(k, g_track_file[k])) fprintf(stderr, "track %d: %s\n", k + 1, g_track_file[k]);
        else { fprintf(stderr, "track %d: cannot use %s (need an EBDES1/EBDES2 design file or a .ebpack.json level pack)\n", k + 1, g_track_file[k]); TrackExtClear(k); }
    }
}

/* Rules (mutators): "name=value" from the command line (--rule) or from excitebike.cfg (one per line, # comments). Defaults are the original game. */
static int g_region_eu;                                       /* embedded builds: 1 = the PAL (Europe) ROM; set by --region eu or region=eu in excitebike.cfg */
static int set_rule(const char *kv) {
    char name[64]; int v;
    if (!strncmp(kv, "region=", 7)) { g_region_eu = !strncmp(kv + 7, "eu", 2); return 1; }           /* region=us|eu (embedded builds) */
    if (sscanf(kv, "%63[^=]=%i", name, &v) != 2) return 0;
    if (!strcmp(name, "jump_power")) g_rules.jump_power = (uint8_t)v;                 /* 175 = original; higher = longer jumps */
    else if (!strcmp(name, "crash_pitch")) g_rules.crash_pitch = (uint8_t)v;          /* 13 = original; higher = more forgiving wheelies */
    else if (!strcmp(name, "overheat")) g_rules.overheat = v != 0;                    /* 0 = the engine never overheats */
    else if (!strcmp(name, "max_speed")) g_rules.max_speed_pct = (uint16_t)v;         /* percent of the original top speed */
    else if (!strcmp(name, "long_designs")) g_design_long = v != 0;
    else if (!strcmp(name, "riders")) g_extra_count = v < 0 ? 0 : v > 4 ? 4 : v;        /* extra CPU riders */
    else if (!strcmp(name, "extra_collisions")) g_extra_collide = v != 0;
    else if (!strcmp(name, "width")) width_opt = v;                                     /* picture width while racing, 256-512 */
    else if (!strcmp(name, "fps")) { fps_mult = (v + 30) / 60; if (fps_mult < 1) fps_mult = 1; if (fps_mult > 4) fps_mult = 4; }
    else return 0;
    return 1;
}
static void load_config(const char *path) {
    FILE *f = fopen(path, "r"); char line[256];
    if (!f) return;
    while (fgets(line, sizeof line, f)) {
        char *p = line; while (*p == ' ' || *p == '\t') p++;
        if (*p == '#' || *p == '\n' || *p == 0) continue;
        if (!set_rule(p)) fprintf(stderr, "excitebike.cfg: unknown or malformed rule: %s", line);
    }
    fclose(f);
}

#include <sys/stat.h>
static int g_watch, g_autostart;                            /* --watch: reload mod files when they change; --autostart: press the menu buttons to start a race on track 1 */
static long file_stamp(const char *path) { struct stat st; return path && stat(path, &st) == 0 ? (long)st.st_mtime * 7 + (long)st.st_size : 0; }
static long mods_stamp(void) {
    long s = audiomod_stamp() + file_stamp(s_chr_bmp) + file_stamp(s_chr_raw) + file_stamp(s_pal_file);
    for (int k = 0; k < 6; k++) s += file_stamp(g_track_file[k]) * (k + 1);
    return s;
}
#include "menu.inc"

/* Starting by double-click: no arguments. The program then works from its own folder (settings, saves, mods), looks for the ROM there and starts in the game's title screen. */
#ifdef _WIN32
#include <windows.h>
#include <direct.h>
#define CHDIR _chdir
#else
#include <dirent.h>
#include <unistd.h>
#define CHDIR chdir
#endif
/* Private builds (tools/build_exe.py, -DEMBED_ROM) carry the ROM data inside the program, taken from the builder's own ROM files, so the program runs without any ROM file.
 * Such a build must never be shared or uploaded. Without EMBED_ROM the ROM is read from a file as before. */
#ifdef EMBED_ROM
extern const unsigned char g_rom_us[]; extern const unsigned int g_rom_us_len;
extern const unsigned char g_rom_eu[]; extern const unsigned int g_rom_eu_len;
#endif
static uint8_t *load_rom_bytes(const char *path, int path_given, long *n_out) {
#ifdef EMBED_ROM
    if (!path_given) {
        const unsigned char *src = g_region_eu ? g_rom_eu : g_rom_us; unsigned len = g_region_eu ? g_rom_eu_len : g_rom_us_len;
        if (!len) { src = g_region_eu ? g_rom_us : g_rom_eu; len = g_region_eu ? g_rom_us_len : g_rom_eu_len; }          /* only one ROM was embedded */
        if (len) { uint8_t *b = malloc(len); if (!b) return NULL; memcpy(b, src, len); *n_out = (long)len; return b; }
    }
#else
    (void)path_given;
#endif
    FILE *f = fopen(path, "rb"); if (!f) return NULL;
    fseek(f, 0, SEEK_END); long n = ftell(f); fseek(f, 0, SEEK_SET);
    uint8_t *rom = malloc((size_t)n); if (!rom || fread(rom, 1, (size_t)n, f) != (size_t)n) { fclose(f); free(rom); return NULL; }
    fclose(f); *n_out = n; return rom;
}
static int has_nes_ext(const char *n) { size_t l = strlen(n); return l > 4 && (n[l - 4] == '.') && (n[l - 3] | 32) == 'n' && (n[l - 2] | 32) == 'e' && (n[l - 1] | 32) == 's'; }
static int name_has_excitebike(const char *n) { char low[260]; size_t i = 0; for (; n[i] && i < 259; i++) low[i] = (char)(n[i] >= 'A' && n[i] <= 'Z' ? n[i] + 32 : n[i]); low[i] = 0; return strstr(low, "excitebike") != NULL; }
static int file_exists(const char *p) { FILE *f = fopen(p, "rb"); if (f) { fclose(f); return 1; } return 0; }
static int find_rom(char *out, size_t cap) {          /* the usual names first, then any .nes file with "excitebike" in its name in the current folder */
    static const char *names[] = { "excitebike.nes", "Excitebike.nes", "orig/excitebike_us.nes", "orig/excitebike_eu.nes" };
    for (size_t i = 0; i < sizeof names / sizeof names[0]; i++) if (file_exists(names[i])) { snprintf(out, cap, "%s", names[i]); return 1; }
#ifdef _WIN32
    WIN32_FIND_DATAA fd; HANDLE h = FindFirstFileA("*.nes", &fd);
    if (h != INVALID_HANDLE_VALUE) { do { if (name_has_excitebike(fd.cFileName)) { snprintf(out, cap, "%s", fd.cFileName); FindClose(h); return 1; } } while (FindNextFileA(h, &fd)); FindClose(h); }
#else
    DIR *d = opendir("."); struct dirent *e;
    if (d) { while ((e = readdir(d))) if (has_nes_ext(e->d_name) && name_has_excitebike(e->d_name)) { snprintf(out, cap, "%s", e->d_name); closedir(d); return 1; } closedir(d); }
#endif
    (void)has_nes_ext;
    return 0;
}

int main(int argc, char **argv) {
    const char *audio_mod = NULL;
    if (argc == 1) { char *base = SDL_GetBasePath(); if (base) { if (CHDIR(base) != 0) { /* stay where we are */ } SDL_free(base); } }       /* double-clicked: work from the program's folder */
    load_config("excitebike.cfg");
    static char found_rom[512]; int rom_given = 0;
    const char *rom_path = "orig/excitebike_us.nes", *shot = NULL, *press = NULL, *wav = NULL, *record = NULL, *play = NULL, *chr_bmp = NULL, *chr_raw = NULL, *pal_file = NULL;
    FILE *rec_f = NULL, *play_f = NULL;
    int dump_oam = 0, shot_menu = 0; const char *peek = NULL, *dump_ppu = NULL;
    int16_t *wavbuf = NULL; size_t wavn = 0, wavcap = 0;
    int scale = 3, frames_limit = -1;
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--scale") && i + 1 < argc) scale = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--frames") && i + 1 < argc) frames_limit = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--width") && i + 1 < argc) width_opt = atoi(argv[++i]);          /* picture width while racing, 256-512 (416 = 16:9) */
        else if (!strcmp(argv[i], "--fps") && i + 1 < argc) { fps_mult = (atoi(argv[++i]) + 30) / 60; if (fps_mult < 1) fps_mult = 1; if (fps_mult > 4) fps_mult = 4; }   /* output rate: 60 = original, 120/180/240 interpolate */
        else if (!strcmp(argv[i], "--widescreen")) width_opt = 416;
        else if (!strcmp(argv[i], "--no-extra-collisions")) g_extra_collide = 0;
        else if (!strcmp(argv[i], "--riders") && i + 1 < argc) g_extra_count = atoi(argv[++i]);          /* extra CPU riders, 0-4 */
        else if (!strcmp(argv[i], "--shot") && i + 1 < argc) shot = argv[++i];
        else if (!strcmp(argv[i], "--press") && i + 1 < argc) press = argv[++i];
        else if (!strcmp(argv[i], "--wav") && i + 1 < argc) wav = argv[++i];
        else if (!strcmp(argv[i], "--record") && i + 1 < argc) record = argv[++i];
        else if (!strcmp(argv[i], "--play") && i + 1 < argc) play = argv[++i];
        else if (!strcmp(argv[i], "--rule") && i + 1 < argc) { if (!set_rule(argv[++i])) { fprintf(stderr, "unknown rule %s\n", argv[i]); return 1; } }
        else if (!strcmp(argv[i], "--designs") && i + 1 < argc) designs_path = argv[++i];
        else if (!strcmp(argv[i], "--track") && i + 1 < argc) { int k; char *eq = strchr(argv[++i], '='); if (eq && (k = atoi(argv[i])) >= 1 && k <= 6) g_track_file[k - 1] = eq + 1; else fprintf(stderr, "--track N=file (N = 1-6)\n"); }
        else if (!strcmp(argv[i], "--audio-mod") && i + 1 < argc) audio_mod = argv[++i];
        else if (!strcmp(argv[i], "--chr-bmp") && i + 1 < argc) chr_bmp = argv[++i];
        else if (!strcmp(argv[i], "--chr") && i + 1 < argc) chr_raw = argv[++i];
        else if (!strcmp(argv[i], "--palette") && i + 1 < argc) pal_file = argv[++i];
        else if (!strcmp(argv[i], "--peek") && i + 1 < argc) peek = argv[++i];         /* debug: print RAM bytes at exit, e.g. 12,4d,e8 */
        else if (!strcmp(argv[i], "--dump-ppu") && i + 1 < argc) dump_ppu = argv[++i];         /* debug/tools: 2 KB nametables + 32 palette bytes at exit */
        else if (!strcmp(argv[i], "--region") && i + 1 < argc) g_region_eu = !strcmp(argv[++i], "eu");               /* embedded builds: which of the two ROMs to run (us = NTSC, eu = PAL) */
        else if (!strcmp(argv[i], "--long-designs")) g_design_long = 1;                     /* the design editor can record tracks longer than the original 236 bytes */
        else if (!strcmp(argv[i], "--watch")) g_watch = 1;                                  /* reload tracks, tiles, palette and audio when their files change (live editing) */
        else if (!strcmp(argv[i], "--autostart")) g_autostart = 1;                          /* press Start and A by itself to begin a race on track 1 (with --track 1=...) */
        else if (!strcmp(argv[i], "--shot-menu")) shot_menu = 1;                         /* debug: also save the options menu over the last picture */
        else if (!strcmp(argv[i], "--dump-oam")) dump_oam = 1;
        else if (!strcmp(argv[i], "--unlimited-sprites")) g_ppu.unlimited_sprites = 1;
        else { rom_path = argv[i]; rom_given = 1; }
    }
#ifndef EMBED_ROM
    if (!rom_given && find_rom(found_rom, sizeof found_rom)) rom_path = found_rom;
#else
    (void)found_rom;
#endif
    if (!audio_mod) audio_mod = "mods/audio";      /* a mods/audio folder next to the program is used by default */
    long n = 0; uint8_t *rom = load_rom_bytes(rom_path, rom_given, &n);
    if (!rom) {
        fprintf(stderr, "cannot open ROM %s\n", rom_path);
        SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Excitebike", "Excitebike ROM not found.\n\nCopy your own Excitebike .nes file into this program's folder and name it excitebike.nes (or start the program with the ROM's path).", NULL);
        return 1;
    }
    if (n < 16 + 0x4000 + 0x2000 || memcmp(rom, "NES\x1a", 4)) { fprintf(stderr, "not an Excitebike iNES ROM\n"); return 1; }
    int unlimited = g_ppu.unlimited_sprites;
    int vertical = rom[6] & 1, pal = (rom[12] & 1) || (rom[9] & 1);
    g_prg = rom + 16;
    g_pal = pal;
    static uint8_t chr_data[0x2000];
    memcpy(chr_data, rom + 16 + rom[4] * 0x4000, sizeof chr_data);
    if (chr_raw && !load_file(chr_raw, chr_data, sizeof chr_data)) { fprintf(stderr, "cannot read 8 KB CHR file %s\n", chr_raw); return 1; }
    ppu_init(&g_ppu, chr_data, vertical, pal, g_ram);
    s_chr_data = chr_data; memcpy(s_rom_chr, chr_data, sizeof s_rom_chr); memcpy(s_rgb_default, g_ppu.rgb, sizeof s_rgb_default); s_chr_bmp = chr_bmp; s_chr_raw = chr_raw; s_pal_file = pal_file;
    g_ppu.unlimited_sprites = unlimited;
    if (width_opt < PPU_W) width_opt = PPU_W;
    if (width_opt > PPU_MAXW) width_opt = PPU_MAXW;
    g_ppu.width = width_opt & ~1;
    apu_init(&g_apu, pal);
    audiomod_set_apu_writer(audio_apu_w);
    if (audio_mod) fprintf(stderr, "audio mod %s: %d files\n", audio_mod, audiomod_load(audio_mod));
    g_hal_write = hal_write; g_hal_read = hal_read; g_hal_event = hal_event;

    SDL_SetMainReady();
    if (chr_bmp && !load_chr_bmp(chr_bmp, chr_data)) return 1;
    load_tracks();
    reload_graphics();
    int headless = shot != NULL && frames_limit >= 0;
    if (SDL_Init(SDL_INIT_VIDEO | (headless ? 0 : SDL_INIT_AUDIO)) != 0) { fprintf(stderr, "SDL: %s\n", SDL_GetError()); return 1; }
    SDL_Window *win = SDL_CreateWindow("Excitebike", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, g_ppu.width * scale, PPU_H * scale, headless ? SDL_WINDOW_HIDDEN : SDL_WINDOW_RESIZABLE);
    SDL_Renderer *ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_PRESENTVSYNC);
    if (!ren) ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_SOFTWARE);
    SDL_RenderSetLogicalSize(ren, g_ppu.width, PPU_H);
    SDL_Texture *tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, g_ppu.width, PPU_H);
    SDL_AudioDeviceID dev = 0;
    if (!headless) {
        SDL_AudioSpec want; SDL_zero(want); want.freq = 44100; want.format = AUDIO_S16SYS; want.channels = 1; want.samples = 1024;
        dev = SDL_OpenAudioDevice(NULL, 0, &want, NULL, 0);
        if (dev) SDL_PauseAudioDevice(dev, 0);
    }

    ResetInit();
    if (record) { rec_f = fopen(record, "wb"); if (rec_f) fwrite("EBREC1\n\0", 1, 8, rec_f); }
    if (play) {
        play_f = fopen(play, "rb");
        if (play_f) { char h[8]; if (fread(h, 1, 8, play_f) != 8 || memcmp(h, "EBREC1\n", 7)) { fclose(play_f); play_f = NULL; } }
        if (!play_f) { fprintf(stderr, "cannot read replay %s\n", play); return 1; }
    }
    int running = 1, frame = 0;
    double frame_ms = pal ? 1000.0 / 50.0 : 1000.0 / 60.0988, audio_acc = 0, samples_per_frame = 44100.0 * frame_ms / 1000.0;
    Uint64 freq = SDL_GetPerformanceFrequency(), next = SDL_GetPerformanceCounter();
    int16_t abuf[2048];
    static FrameDesc prev_desc, shot_prev; static uint32_t interp_buf[PPU_MAXW * PPU_H];
    uint8_t scripted = 0; const char *pp = press;
    while (running) {
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) running = 0;
            if (e.type == SDL_KEYDOWN && (e.key.keysym.sym == SDLK_TAB || e.key.keysym.sym == SDLK_F1)) { menu_open = !menu_open; if (menu_open) { menu_load(); menu_sel = 0; } }
            else if (e.type == SDL_KEYDOWN && menu_open && e.key.keysym.sym != SDLK_ESCAPE) { int wc = 0; menu_key(e.key.keysym.sym, &wc);
                if (wc) { g_ppu.width = width_opt & ~1; SDL_DestroyTexture(tex); tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, g_ppu.width, PPU_H); SDL_RenderSetLogicalSize(ren, g_ppu.width, PPU_H); prev_desc.valid = 0; } }
            else if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE) { if (menu_open) menu_open = 0; else running = 0; }
            if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_F5) state_save("quicksave.sav");
            if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_F6) { if (audio_mod) audiomod_load(audio_mod); load_tracks(); reload_graphics(); fprintf(stderr, "mods reloaded\n"); }
            if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_F9) { if (!state_load("quicksave.sav")) fprintf(stderr, "no usable quicksave.sav\n"); }
            if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_F11) SDL_SetWindowFullscreen(win, (SDL_GetWindowFlags(win) & SDL_WINDOW_FULLSCREEN_DESKTOP) ? 0 : SDL_WINDOW_FULLSCREEN_DESKTOP);
        }
        if (menu_open) {                                       /* paused: the last picture dimmed, with the options on top */
            static uint32_t mbuf[PPU_MAXW * PPU_H];
            menu_draw(mbuf, g_ppu.frame, g_ppu.width);
            SDL_UpdateTexture(tex, NULL, mbuf, g_ppu.width * 4); present_and_wait(ren, tex, &next, (Uint64)(freq / 60), dev);
            continue;
        }
        while (pp && *pp) {                                    /* --press "30=8,34=0": button state from that frame on */
            int fr, b; int used = 0;
            if (sscanf(pp, "%d=%i%n", &fr, &b, &used) < 2) break;
            if (fr > frame) break;
            scripted = (uint8_t)b; pp += used; if (*pp == ',') pp++;
        }
        uint8_t pad = press ? scripted : read_pad(SDL_GetKeyboardState(NULL));
        if (g_autostart) { if (frame >= 200 && frame < 215) pad |= 0x08; if (frame >= 260 && frame < 275) pad |= 0x01; if (frame >= 340 && frame < 355) pad |= 0x08; }
        if (g_watch && frame % 30 == 0) { static long last = -1; long now = mods_stamp(); if (last >= 0 && now != last) { if (audio_mod) audiomod_load(audio_mod); load_tracks(); reload_graphics(); fprintf(stderr, "mods changed: reloaded\n"); } last = now; }
        if (play_f) { int c = fgetc(play_f); if (c == EOF) break; pad = (uint8_t)c; }
        if (rec_f) fputc(pad, rec_f);
        g_pad_bits[0] = pad;
        g_ppu.wide_active = g_ram[0x47] != 0;                  /* widen the picture only while racing / editing a track */
        ppu_run_to_vblank(&g_ppu);                             /* the picture for this frame is complete; vblank starts */
        for (int i = 0; i < 150; i++) UpdateRandom();          /* the idle loop between frames */
        audiomod_frame();
        if (g_ppu.ctrl & 0x80) Nmi();
        ExtraRidersFrame();
        g_ppu.extra_n = 0;
        if (g_ram[0x47]) {
            WideSprite ws[64]; int k = 0;
            if (g_ppu.width > PPU_W) k = WideRiderSprites(ws, 40, g_ppu.width);
            k += ExtraRiderSprites(ws + k, 64 - k, g_ppu.width);
            for (int i = 0; i < k; i++) { g_ppu.extra[i].x = ws[i].x; g_ppu.extra[i].y = ws[i].y; g_ppu.extra[i].tile = ws[i].tile; g_ppu.extra[i].attr = ws[i].attr; }
            g_ppu.extra_n = k;
        }
        tape_service();                                        /* design save/load requested through the (former) tape interface */
        /* audio for this frame */
        audio_acc += samples_per_frame;
        int ns = (int)audio_acc; audio_acc -= ns;
        while (ns > 0) {
            int chunk = ns > 2048 ? 2048 : ns;
            apu_run(&g_apu, abuf, chunk, 44100);
            audiomod_mix(abuf, chunk);
            if (dev) SDL_QueueAudio(dev, abuf, (Uint32)chunk * 2);
            if (wav) { if (wavn + chunk > wavcap) { wavcap = (wavn + chunk) * 2; wavbuf = realloc(wavbuf, wavcap * 2); } memcpy(wavbuf + wavn, abuf, (size_t)chunk * 2); wavn += chunk; }
            ns -= chunk;
        }
        frame++;
        if (!headless) {
            Uint64 slice = (Uint64)(frame_ms / 1000.0 * (double)freq / fps_mult);
            if (fps_mult > 1 && prev_desc.valid && g_ppu.done.valid) {      /* in-between pictures: scroll and sprites moved part of the way */
                for (int i = 1; i < fps_mult; i++) {
                    ppu_render_interp(&g_ppu, &prev_desc, &g_ppu.done, (double)i / fps_mult, interp_buf);
                    SDL_UpdateTexture(tex, NULL, interp_buf, g_ppu.width * 4);
                    present_and_wait(ren, tex, &next, slice, dev);
                }
            }
            SDL_UpdateTexture(tex, NULL, g_ppu.frame, g_ppu.width * 4);
            present_and_wait(ren, tex, &next, slice, dev);
        }
        shot_prev = prev_desc; prev_desc = g_ppu.done;
        if (frames_limit >= 0 && frame >= frames_limit) running = 0;
    }
    if (shot && fps_mult > 1 && shot_prev.valid) {            /* debug: also save the in-between picture of the last two frames */
        static uint32_t mid[PPU_MAXW * PPU_H]; char name[512];
        ppu_render_interp(&g_ppu, &shot_prev, &g_ppu.done, 0.5, mid);
        snprintf(name, sizeof name, "%s.mid.bmp", shot);
        SDL_Surface *ms = SDL_CreateRGBSurfaceWithFormatFrom(mid, g_ppu.width, PPU_H, 32, g_ppu.width * 4, SDL_PIXELFORMAT_ARGB8888);
        SDL_SaveBMP(ms, name); SDL_FreeSurface(ms);
    }
    if (shot && shot_menu) {
        static uint32_t mb[PPU_MAXW * PPU_H]; char name[512]; menu_load(); menu_draw(mb, g_ppu.frame, g_ppu.width);
        snprintf(name, sizeof name, "%s.menu.bmp", shot);
        SDL_Surface *ms = SDL_CreateRGBSurfaceWithFormatFrom(mb, g_ppu.width, PPU_H, 32, g_ppu.width * 4, SDL_PIXELFORMAT_ARGB8888);
        SDL_SaveBMP(ms, name); SDL_FreeSurface(ms);
    }
    if (shot) {
        SDL_Surface *s = SDL_CreateRGBSurfaceWithFormatFrom(g_ppu.frame, g_ppu.width, PPU_H, 32, g_ppu.width * 4, SDL_PIXELFORMAT_ARGB8888);
        SDL_SaveBMP(s, shot); SDL_FreeSurface(s);
        printf("saved %s (game state %d, frame %d)\n", shot, g_ram[0x41], frame);
    }
    if (wav && wavbuf) {                                       /* 16-bit mono 44.1 kHz WAV of everything the game played */
        FILE *w = fopen(wav, "wb");
        if (w) {
            uint32_t dl = (uint32_t)(wavn * 2), rl = 36 + dl, sr = 44100, br = 88200; uint16_t one = 1, bits = 16, ba = 2; uint32_t fmt = 16;
            fwrite("RIFF", 1, 4, w); fwrite(&rl, 4, 1, w); fwrite("WAVEfmt ", 1, 8, w); fwrite(&fmt, 4, 1, w); fwrite(&one, 2, 1, w); fwrite(&one, 2, 1, w);
            fwrite(&sr, 4, 1, w); fwrite(&br, 4, 1, w); fwrite(&ba, 2, 1, w); fwrite(&bits, 2, 1, w); fwrite("data", 1, 4, w); fwrite(&dl, 4, 1, w);
            fwrite(wavbuf, 2, wavn, w); fclose(w); printf("saved %s (%zu samples)\n", wav, wavn);
        }
    }
    if (dump_ppu) { FILE *pf = fopen(dump_ppu, "wb"); if (pf) { fwrite(g_ppu.vram, 1, 2048, pf); fwrite(g_ppu.pal, 1, 32, pf); fclose(pf); } }
    if (dump_oam) for (int i = 0; i < 64; i++) { const uint8_t *o = &g_ppu.oam[i * 4]; if (o[0] < 0xEF) printf("sprite %2d: y=%3d tile=%02X attr=%02X x=%3d owner=%d\n", i, o[0], o[1], o[2], o[3], g_ppu.done.tags.owner[i]); }
    for (const char *q = peek; q && *q;) { unsigned a; int used = 0; if (sscanf(q, "%x%n", &a, &used) < 1) break; printf("ram[%03X] = %02X\n", a, g_ram[a & 0x7FF]); q += used; if (*q == ',') q++; }
    if (rec_f) fclose(rec_f);
    if (play_f) fclose(play_f);
    {
        uint32_t h = 2166136261u;                              /* checksum of the game's RAM: equal for equal replays */
        for (int i = 0; i < 0x800; i++) { h ^= g_ram[i]; h *= 16777619u; }
        printf("final: frame %d, game state %d, RAM checksum %08x\n", frame, g_ram[0x41], h);
    }
    if (dev) SDL_CloseAudioDevice(dev);
    SDL_Quit();
    free(rom);
    return 0;
}
