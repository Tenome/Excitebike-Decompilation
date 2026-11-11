/* In-game options menu (Tab or F1): the port's settings, drawn with the game's own font (pattern table 1). Included from main.c.
 * Up/Down choose, Left/Right change (applied at once), Enter on SAVE SETTINGS writes excitebike.cfg, Tab or Esc closes. The game is paused while it is open. */
typedef struct { const char *name; int *val; int lo, hi, step; } MenuItem;
static int m_long, m_riders, m_collide, m_speed, m_jump, m_crash, m_heat, m_width, m_fps, m_unl;
static MenuItem g_items[] = {
    { "EXTRA RIDERS", &m_riders, 0, 4, 1 }, { "RIDER CONTACT", &m_collide, 0, 1, 1 }, { "TOP SPEED", &m_speed, 25, 200, 5 },
    { "JUMP POWER", &m_jump, 0, 255, 5 }, { "CRASH PITCH", &m_crash, 1, 15, 1 }, { "OVERHEAT", &m_heat, 0, 1, 1 },
    { "WIDTH", &m_width, 256, 512, 32 }, { "FRAME RATE", &m_fps, 60, 240, 60 }, { "NO SPRITE LIMIT", &m_unl, 0, 1, 1 }, { "LONG DESIGNS", &m_long, 0, 1, 1 }, { "SAVE SETTINGS", NULL, 0, 0, 0 },
};
#define NITEMS ((int)(sizeof g_items / sizeof g_items[0]))
static int menu_open, menu_sel;

static void menu_load(void) {
    m_riders = g_extra_count; m_collide = g_extra_collide; m_speed = g_rules.max_speed_pct; m_jump = g_rules.jump_power; m_crash = g_rules.crash_pitch; m_heat = g_rules.overheat;
    m_width = width_opt; m_fps = fps_mult * 60; m_unl = g_ppu.unlimited_sprites; m_long = g_design_long;
}
static void menu_apply(void) {
    g_extra_count = m_riders; g_extra_collide = m_collide; g_rules.max_speed_pct = (uint16_t)m_speed; g_rules.jump_power = (uint8_t)m_jump; g_rules.crash_pitch = (uint8_t)m_crash; g_rules.overheat = (uint8_t)m_heat;
    width_opt = m_width; fps_mult = m_fps / 60; g_ppu.unlimited_sprites = m_unl; g_design_long = m_long;
}
static void menu_save(void) {
    FILE *f = fopen("excitebike.cfg", "w"); if (!f) return;
    fprintf(f, "# written by the in-game menu (see port/excitebike.cfg.example)\njump_power=%d\ncrash_pitch=%d\noverheat=%d\nmax_speed=%d\nriders=%d\nextra_collisions=%d\nwidth=%d\nfps=%d\nlong_designs=%d\n",
            m_jump, m_crash, m_heat, m_speed, m_riders, m_collide, m_width, m_fps, m_long);
    fclose(f);
}
static int font_tile(char c) {                              /* the game's text tiles: 0-9 then A-Z in order; -1 = no glyph (spaces) */
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'A' && c <= 'Z') return 10 + (c - 'A');
    return -1;
}
static void draw_text(uint32_t *fb, int w, int x, int y, const char *t, uint32_t col) {
    for (; *t; t++, x += 8) {
        int tile = font_tile(*t); if (tile < 0) continue;
        const uint8_t *g = g_ppu.chr + 0x1000 + tile * 16;
        for (int r = 0; r < 8; r++) for (int c = 0; c < 8; c++)
            if ((((g[r] >> (7 - c)) & 1) | (((g[r + 8] >> (7 - c)) & 1) << 1)) == 3) {      /* glyph pixels are colour 3 */ int px = x + c, py = y + r; if (px >= 0 && px < w && py >= 0 && py < PPU_H) fb[py * w + px] = col; }
    }
}
static void menu_draw(uint32_t *fb, const uint32_t *src, int w) {
    for (int i = 0; i < w * PPU_H; i++) { uint32_t c = src[i]; fb[i] = 0xFF000000u | (((c >> 18) & 0x3F) << 16) | (((c >> 10) & 0x3F) << 8) | ((c >> 2) & 0x3F); }
    int x0 = (w - 256) / 2 + 36, y0 = 24;
    draw_text(fb, w, x0, y0, "OPTIONS", 0xFFFFD040u);
    for (int i = 0; i < NITEMS; i++) {
        char v[32] = ""; MenuItem *it = &g_items[i];
        if (it->val) { if (it->hi == 1 && it->lo == 0) snprintf(v, sizeof v, "%s", *it->val ? "ON" : "OFF"); else snprintf(v, sizeof v, "%d", *it->val); }
        uint32_t col = i == menu_sel ? 0xFFFFFFFFu : 0xFFA0A0A0u;
        if (i == menu_sel) draw_text(fb, w, x0 - 12, y0 + 18 + i * 14, "X", 0xFFFFD040u);
        draw_text(fb, w, x0, y0 + 18 + i * 14, it->name, col); draw_text(fb, w, x0 + 136, y0 + 18 + i * 14, v, col);
    }
    draw_text(fb, w, x0, y0 + 18 + NITEMS * 14 + 8, "TAB CLOSES", 0xFF808080u);
}
static void menu_key(SDL_Keycode k, int *width_changed) {
    MenuItem *it = &g_items[menu_sel];
    if (k == SDLK_UP) menu_sel = (menu_sel + NITEMS - 1) % NITEMS;
    else if (k == SDLK_DOWN) menu_sel = (menu_sel + 1) % NITEMS;
    else if ((k == SDLK_LEFT || k == SDLK_RIGHT) && it->val) {
        int v = *it->val + (k == SDLK_RIGHT ? it->step : -it->step); if (v < it->lo) v = it->lo; if (v > it->hi) v = it->hi; *it->val = v;
        int ow = width_opt; menu_apply(); if (width_opt != ow) *width_changed = 1;
    } else if (k == SDLK_RETURN && !it->val) { menu_apply(); menu_save(); }
}
