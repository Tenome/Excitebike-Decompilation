/* .ebm songs (see tools/ebmusic.py for the format): a small sequencer that plays four voices through the APU registers each frame. Included from audiomod.c. */
typedef struct { int midi, frames, gate, decay, rest; } MEv;
typedef struct { int kind, duty, decay, n; MEv *ev; } MVoice;      /* kind: 0 pulse1, 1 pulse2, 2 triangle, 3 noise */
typedef struct { int nv; MVoice v[4]; } Song;
static Song g_song[256]; static int g_song_ok[256];
typedef struct { int idx, left, elapsed, gate, on, done; } VState;
static struct { int song; VState st[4]; } g_play = { -1 };
static void (*g_apu_w)(uint16_t, uint8_t);
void audiomod_set_apu_writer(void (*w)(uint16_t, uint8_t)) { g_apu_w = w; }

static int song_parse_text(const char *text, Song *s) {
    char line[256]; MVoice *cur = NULL; int cap[4] = { 0, 0, 0, 0 };
    memset(s, 0, sizeof *s);
    while (*text) {
        size_t ll = strcspn(text, "\n"); if (ll >= sizeof line) ll = sizeof line - 1;
        memcpy(line, text, ll); line[ll] = 0; text += strcspn(text, "\n"); if (*text == '\n') text++;
        char *h = strchr(line, '#'); if (h) *h = 0;
        char w[16]; int off = 0; if (sscanf(line, "%15s%n", w, &off) < 1) continue;
        if (!strcmp(w, "voice")) {
            char k[16]; int o2 = 0; if (s->nv >= 4 || sscanf(line + off, "%15s%n", k, &o2) < 1) continue;
            cur = &s->v[s->nv++]; cur->kind = !strcmp(k, "pulse1") ? 0 : !strcmp(k, "pulse2") ? 1 : !strcmp(k, "tri") ? 2 : 3; cur->duty = 2; cur->decay = 0;
            const char *p = line + off + o2; char key[16]; int val, used;
            while (sscanf(p, "%15s %d%n", key, &val, &used) == 2) { if (!strcmp(key, "duty")) cur->duty = val & 3; else if (!strcmp(key, "decay")) cur->decay = val & 15; p += used; }
            cap[s->nv - 1] = 0;
        } else if ((!strcmp(w, "n") || !strcmp(w, "r")) && cur) {
            MEv e = { 0, 0, 0, cur->decay, w[0] == 'r' }; int a, b, used; const char *p = line + off;
            if (e.rest) { if (sscanf(p, "%d", &a) != 1) continue; e.frames = a; }
            else { if (sscanf(p, "%d %d%n", &a, &b, &used) != 2) continue; e.midi = a; e.frames = b; p += used; char key[16]; int val, u2; while (sscanf(p, "%15s %d%n", key, &val, &u2) == 2) { if (!strcmp(key, "gate")) e.gate = val; else if (!strcmp(key, "decay")) e.decay = val & 15; p += u2; } }
            if (e.frames < 1) continue; if (!e.gate) e.gate = e.frames;
            int vi = (int)(cur - s->v);
            if (cur->n == cap[vi]) { cap[vi] = cap[vi] ? cap[vi] * 2 : 256; cur->ev = realloc(cur->ev, cap[vi] * sizeof(MEv)); }
            cur->ev[cur->n++] = e;
        }
    }
    return s->nv > 0;
}
static int song_parse(const char *path, Song *s) {
    FILE *f = fopen(path, "rb"); if (!f) return 0;
    static char buf[40000]; size_t n = fread(buf, 1, sizeof buf - 1, f); fclose(f); buf[n] = 0;
    return song_parse_text(buf, s);
}
int audiomod_install_song(int request, const char *text) {          /* a song that came inside a level pack */
    request &= 255; if (!request) return 0;
    g_song_ok[request] = song_parse_text(text, &g_song[request]);
    if (g_song_ok[request]) g_hal_sound = audiomod_request;
    return g_song_ok[request];
}
static double cpu_clock(void) { return g_pal ? 1662607.0 : 1789773.0; }
static int period_of(int midi, int tri) { double f = 440.0 * pow(2.0, (midi - 69) / 12.0); int p = (int)(cpu_clock() / ((tri ? 32.0 : 16.0) * f) + 0.5) - 1; return p < 8 ? 8 : p > 0x7FF ? 0x7FF : p; }
static int sfx_busy(int kind) { return (kind == 0 && g_ram[0xF0] != 0) || (kind == 1 && g_ram[0xF1] != 0); }   /* game sound effects keep their channel */
static void voice_silence(int kind) { if (!g_apu_w) return; if (kind <= 1) g_apu_w((uint16_t)(0x4000 + kind * 4), 0x10); else if (kind == 2) g_apu_w(0x4008, 0); else g_apu_w(0x400C, 0x10); }
static void voice_note(const MVoice *v, const MEv *e) {
    if (!g_apu_w || sfx_busy(v->kind)) return;
    if (v->kind <= 1) {
        int p = period_of(e->midi, 0), d = e->decay, b = 0x4000 + v->kind * 4;
        g_apu_w((uint16_t)b, (uint8_t)(v->duty << 6 | (d ? d : 0x1F))); g_apu_w((uint16_t)(b + 1), 0x7F);
        g_apu_w((uint16_t)(b + 2), (uint8_t)p); g_apu_w((uint16_t)(b + 3), (uint8_t)((p >> 8) | 8));
    } else if (v->kind == 2) {
        int p = period_of(e->midi, 1); g_apu_w(0x4008, 0xFF); g_apu_w(0x400A, (uint8_t)p); g_apu_w(0x400B, (uint8_t)((p >> 8) | 8));
    } else {
        g_apu_w(0x400C, (uint8_t)(v->decay ? v->decay - 1 : 0x1F)); g_apu_w(0x400E, (uint8_t)(e->midi & 15)); g_apu_w(0x400F, 8);
    }
}
static void music_stop(void) { if (g_play.song < 0) return; for (int i = 0; i < g_song[g_play.song].nv; i++) voice_silence(g_song[g_play.song].v[i].kind); g_play.song = -1; }
static int music_request(int value) {                      /* a game music request: play the replacement song if there is one, else make sure ours is stopped */
    value &= 255; music_stop();
    if (!g_song_ok[value]) return 0;
    g_play.song = value; memset(g_play.st, 0, sizeof g_play.st); g_apu_w ? (void)0 : (void)0; return 1;
}
static void music_tick(void) {                             /* once per game frame, before the frame's audio is made */
    if (g_play.song < 0) return;
    Song *s = &g_song[g_play.song]; int alive = 0;
    for (int i = 0; i < s->nv; i++) {
        MVoice *v = &s->v[i]; VState *t = &g_play.st[i]; if (t->done) continue;
        if (t->left == 0) {
            if (t->idx >= v->n) { t->done = 1; voice_silence(v->kind); continue; }
            const MEv *e = &v->ev[t->idx++]; t->left = e->frames; t->elapsed = 0; t->gate = e->gate; t->on = !e->rest;
            if (e->rest) voice_silence(v->kind); else voice_note(v, e);
        } else if (t->on && t->elapsed == t->gate) { voice_silence(v->kind); t->on = 0; }
        t->left--; t->elapsed++; alive = 1;
    }
    if (!alive) g_play.song = -1;
}
