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
static void hal_event(int ev, int arg) { if (ev == HAL_EV_DELAY) ppu_advance(&g_ppu, arg); }

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

/* Rules (mutators): "name=value" from the command line (--rule) or from excitebike.cfg (one per line, # comments). Defaults are the original game. */
static int set_rule(const char *kv) {
    char name[64]; int v;
    if (sscanf(kv, "%63[^=]=%i", name, &v) != 2) return 0;
    if (!strcmp(name, "jump_power")) g_rules.jump_power = (uint8_t)v;                 /* 175 = original; higher = longer jumps */
    else if (!strcmp(name, "crash_pitch")) g_rules.crash_pitch = (uint8_t)v;          /* 13 = original; higher = more forgiving wheelies */
    else if (!strcmp(name, "overheat")) g_rules.overheat = v != 0;                    /* 0 = the engine never overheats */
    else if (!strcmp(name, "max_speed")) g_rules.max_speed_pct = (uint16_t)v;         /* percent of the original top speed */
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

int main(int argc, char **argv) {
    load_config("excitebike.cfg");
    const char *rom_path = "orig/excitebike_us.nes", *shot = NULL, *press = NULL, *wav = NULL, *record = NULL, *play = NULL, *chr_bmp = NULL, *chr_raw = NULL, *pal_file = NULL;
    FILE *rec_f = NULL, *play_f = NULL;
    int dump_oam = 0; const char *peek = NULL;
    int16_t *wavbuf = NULL; size_t wavn = 0, wavcap = 0;
    int scale = 3, frames_limit = -1, width_opt = PPU_W;
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--scale") && i + 1 < argc) scale = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--frames") && i + 1 < argc) frames_limit = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--width") && i + 1 < argc) width_opt = atoi(argv[++i]);          /* picture width while racing, 256-512 (416 = 16:9) */
        else if (!strcmp(argv[i], "--widescreen")) width_opt = 416;
        else if (!strcmp(argv[i], "--shot") && i + 1 < argc) shot = argv[++i];
        else if (!strcmp(argv[i], "--press") && i + 1 < argc) press = argv[++i];
        else if (!strcmp(argv[i], "--wav") && i + 1 < argc) wav = argv[++i];
        else if (!strcmp(argv[i], "--record") && i + 1 < argc) record = argv[++i];
        else if (!strcmp(argv[i], "--play") && i + 1 < argc) play = argv[++i];
        else if (!strcmp(argv[i], "--rule") && i + 1 < argc) { if (!set_rule(argv[++i])) { fprintf(stderr, "unknown rule %s\n", argv[i]); return 1; } }
        else if (!strcmp(argv[i], "--chr-bmp") && i + 1 < argc) chr_bmp = argv[++i];
        else if (!strcmp(argv[i], "--chr") && i + 1 < argc) chr_raw = argv[++i];
        else if (!strcmp(argv[i], "--palette") && i + 1 < argc) pal_file = argv[++i];
        else if (!strcmp(argv[i], "--peek") && i + 1 < argc) peek = argv[++i];         /* debug: print RAM bytes at exit, e.g. 12,4d,e8 */
        else if (!strcmp(argv[i], "--dump-oam")) dump_oam = 1;
        else if (!strcmp(argv[i], "--unlimited-sprites")) g_ppu.unlimited_sprites = 1;
        else rom_path = argv[i];
    }
    FILE *f = fopen(rom_path, "rb");
    if (!f) { fprintf(stderr, "cannot open ROM %s\n", rom_path); return 1; }
    fseek(f, 0, SEEK_END); long n = ftell(f); fseek(f, 0, SEEK_SET);
    uint8_t *rom = malloc((size_t)n); if (fread(rom, 1, (size_t)n, f) != (size_t)n) { fprintf(stderr, "short read\n"); return 1; }
    fclose(f);
    if (n < 16 + 0x4000 + 0x2000 || memcmp(rom, "NES\x1a", 4)) { fprintf(stderr, "not an Excitebike iNES ROM\n"); return 1; }
    int unlimited = g_ppu.unlimited_sprites;
    int vertical = rom[6] & 1, pal = (rom[12] & 1) || (rom[9] & 1);
    g_prg = rom + 16;
    g_pal = pal;
    static uint8_t chr_data[0x2000];
    memcpy(chr_data, rom + 16 + rom[4] * 0x4000, sizeof chr_data);
    if (chr_raw && !load_file(chr_raw, chr_data, sizeof chr_data)) { fprintf(stderr, "cannot read 8 KB CHR file %s\n", chr_raw); return 1; }
    ppu_init(&g_ppu, chr_data, vertical, pal, g_ram);
    g_ppu.unlimited_sprites = unlimited;
    if (width_opt < PPU_W) width_opt = PPU_W;
    if (width_opt > PPU_MAXW) width_opt = PPU_MAXW;
    g_ppu.width = width_opt & ~1;
    apu_init(&g_apu, pal);
    g_hal_write = hal_write; g_hal_read = hal_read; g_hal_event = hal_event;

    SDL_SetMainReady();
    if (chr_bmp && !load_chr_bmp(chr_bmp, chr_data)) return 1;
    if (pal_file) { uint8_t rgb[192]; if (!load_file(pal_file, rgb, sizeof rgb)) { fprintf(stderr, "cannot read 192-byte palette file %s\n", pal_file); return 1; } for (int i = 0; i < 64; i++) g_ppu.rgb[i] = 0xFF000000u | (uint32_t)rgb[i * 3] << 16 | (uint32_t)rgb[i * 3 + 1] << 8 | rgb[i * 3 + 2]; }
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
    uint8_t scripted = 0; const char *pp = press;
    while (running) {
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) running = 0;
            if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE) running = 0;
            if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_F5) state_save("quicksave.sav");
            if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_F9) { if (!state_load("quicksave.sav")) fprintf(stderr, "no usable quicksave.sav\n"); }
            if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_F11) SDL_SetWindowFullscreen(win, (SDL_GetWindowFlags(win) & SDL_WINDOW_FULLSCREEN_DESKTOP) ? 0 : SDL_WINDOW_FULLSCREEN_DESKTOP);
        }
        while (pp && *pp) {                                    /* --press "30=8,34=0": button state from that frame on */
            int fr, b; int used = 0;
            if (sscanf(pp, "%d=%i%n", &fr, &b, &used) < 2) break;
            if (fr > frame) break;
            scripted = (uint8_t)b; pp += used; if (*pp == ',') pp++;
        }
        uint8_t pad = press ? scripted : read_pad(SDL_GetKeyboardState(NULL));
        if (play_f) { int c = fgetc(play_f); if (c == EOF) break; pad = (uint8_t)c; }
        if (rec_f) fputc(pad, rec_f);
        g_pad_bits[0] = pad;
        g_ppu.wide_active = g_ram[0x47] != 0;                  /* widen the picture only while racing / editing a track */
        ppu_run_to_vblank(&g_ppu);                             /* the picture for this frame is complete; vblank starts */
        if (g_ppu.frames_done > 1) { SDL_UpdateTexture(tex, NULL, g_ppu.frame, g_ppu.width * 4); }
        for (int i = 0; i < 150; i++) UpdateRandom();          /* the idle loop between frames */
        if (g_ppu.ctrl & 0x80) Nmi();
        /* audio for this frame */
        audio_acc += samples_per_frame;
        int ns = (int)audio_acc; audio_acc -= ns;
        while (ns > 0) {
            int chunk = ns > 2048 ? 2048 : ns;
            apu_run(&g_apu, abuf, chunk, 44100);
            if (dev) SDL_QueueAudio(dev, abuf, (Uint32)chunk * 2);
            if (wav) { if (wavn + chunk > wavcap) { wavcap = (wavn + chunk) * 2; wavbuf = realloc(wavbuf, wavcap * 2); } memcpy(wavbuf + wavn, abuf, (size_t)chunk * 2); wavn += chunk; }
            ns -= chunk;
        }
        frame++;
        if (!headless) {
            SDL_RenderClear(ren); SDL_RenderCopy(ren, tex, NULL, NULL); SDL_RenderPresent(ren);
            next += (Uint64)(frame_ms / 1000.0 * (double)freq);
            Uint64 now = SDL_GetPerformanceCounter();
            while (dev && SDL_GetQueuedAudioSize(dev) > 44100 / 8 * 2) SDL_Delay(1);
            if (now < next) { Uint64 wait = next - now; if (wait > freq / 200) SDL_Delay((Uint32)(wait * 1000 / freq) - 1); while (SDL_GetPerformanceCounter() < next) { } }
            else next = now;
        }
        if (frames_limit >= 0 && frame >= frames_limit) running = 0;
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
    if (dump_oam) for (int i = 0; i < 64; i++) { const uint8_t *o = &g_ppu.oam[i * 4]; if (o[0] < 0xEF) printf("sprite %2d: y=%3d tile=%02X attr=%02X x=%3d\n", i, o[0], o[1], o[2], o[3]); }
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
