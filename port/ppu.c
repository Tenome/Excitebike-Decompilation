#include "ppu.h"
#include <string.h>
#include <math.h>

/* 2C02 colours (ARGB) */
static const uint32_t NES_RGB[64] = {
    0x545454,0x001E74,0x081090,0x300088,0x440064,0x5C0030,0x540400,0x3C1800,0x202A00,0x083A00,0x004000,0x003C00,0x00323C,0x000000,0x000000,0x000000,
    0x989698,0x084CC4,0x3032EC,0x5C1EE4,0x8814B0,0xA01464,0x982220,0x783C00,0x545A00,0x287200,0x087C00,0x007628,0x006678,0x000000,0x000000,0x000000,
    0xECEEEC,0x4C9AEC,0x787CEC,0xB062EC,0xE454EC,0xEC58B4,0xEC6A64,0xD48820,0xA0AA00,0x74C400,0x4CD020,0x38CC6C,0x38B4CC,0x3C3C3C,0x000000,0x000000,
    0xECEEEC,0xA8CCEC,0xBCBCEC,0xD4B2EC,0xECAEEC,0xECAED4,0xECB4B0,0xE4C490,0xCCD278,0xB4DE78,0xA8E290,0x98E2B4,0xA0D6E4,0xA0A2A0,0x000000,0x000000 };

static int total_lines(const Ppu *p) { return p->pal_region ? 312 : 262; }
static double cycles_per_line(const Ppu *p) { return p->pal_region ? 106.5625 : 113.6667; }
static int rendering_on(const Ppu *p) { return (p->mask & 0x18) != 0; }

void ppu_init(Ppu *p, const uint8_t *chr, int vertical_mirroring, int pal_region, const uint8_t *cpu_ram) {
    memset(p, 0, sizeof *p);
    p->chr = chr; p->vertical_mirroring = vertical_mirroring; p->pal_region = pal_region; p->cpu_ram = cpu_ram;
    for (int i = 0; i < 64; i++) p->rgb[i] = NES_RGB[i];
    p->line = 0; p->col = 0; p->unlimited_sprites = 0; p->width = PPU_W;
    memset(p->tag_next.owner, 255, 64); memset(p->tag_dma.owner, 255, 64); memset(p->build.tags.owner, 255, 64); memset(p->done.tags.owner, 255, 64);
}

static uint8_t *nt_byte(Ppu *p, uint16_t addr) {            /* addr in $2000-$2FFF */
    int table = (addr >> 10) & 3;
    int idx = p->vertical_mirroring ? (table & 1) : (table >> 1);
    return &p->vram[idx * 0x400 + (addr & 0x3FF)];
}
static uint8_t *pal_byte(Ppu *p, uint16_t addr) {
    int i = addr & 0x1F;
    if ((i & 0x13) == 0x10) i &= ~0x10;
    return &p->pal[i];
}

void ppu_write(Ppu *p, uint16_t reg, uint8_t v) {
    switch (reg) {
    case 0x2000: p->ctrl = v; p->t = (uint16_t)((p->t & 0xF3FF) | ((v & 3) << 10)); break;
    case 0x2001: p->mask = v; break;
    case 0x2003: p->oam_addr = v; break;
    case 0x2004: p->oam[p->oam_addr++] = v; break;
    case 0x2005:
        if (!p->w) { p->t = (uint16_t)((p->t & ~0x1F) | (v >> 3)); p->x = v & 7; }
        else p->t = (uint16_t)((p->t & ~0x73E0) | ((v & 7) << 12) | ((v >> 3) << 5));
        p->w ^= 1; break;
    case 0x2006:
        if (!p->w) p->t = (uint16_t)((p->t & 0x00FF) | ((v & 0x3F) << 8));
        else { p->t = (uint16_t)((p->t & 0xFF00) | v); p->v = p->t; }
        p->w ^= 1; break;
    case 0x2007: {
        uint16_t a = p->v & 0x3FFF;
        if (a >= 0x3F00) *pal_byte(p, a) = v & 0x3F;
        else if (a >= 0x2000) *nt_byte(p, a & 0x2FFF) = v;
        p->v = (uint16_t)(p->v + ((p->ctrl & 4) ? 32 : 1));
        break; }
    case 0x4014:
        for (int i = 0; i < 256; i++) p->oam[(uint8_t)(p->oam_addr + i)] = p->cpu_ram[((v & 7) << 8) | i];
        p->tag_dma = p->tag_next; memset(&p->tag_next, 0, sizeof p->tag_next); memset(p->tag_next.owner, 255, 64);        /* the tags of what was built last frame belong to this DMA */
        break;
    default: break;
    }
}

static int sprite_height(const Ppu *p) { return (p->ctrl & 0x20) ? 16 : 8; }
static uint8_t sprite_row_bits(const Ppu *p, int tile, int attr, int row, int *hi_out) {   /* two pattern bytes for one sprite row */
    int h = sprite_height(p), flipv = (attr & 0x80) != 0;
    if (flipv) row = h - 1 - row;
    uint16_t base;
    if (h == 16) { base = (uint16_t)((tile & 1) * 0x1000 + (tile & 0xFE) * 16 + (row & 8 ? 16 : 0) + (row & 7)); }
    else base = (uint16_t)(((p->ctrl >> 3) & 1) * 0x1000 + tile * 16 + row);
    *hi_out = p->chr[base + 8];
    return p->chr[base];
}
static int sprite0_line(const Ppu *p) {                      /* first scanline where sprite 0 has an opaque pixel, or -1 */
    int y = p->oam[0] + 1, tile = p->oam[1], attr = p->oam[2];
    if (y >= 240) return -1;
    for (int r = 0; r < sprite_height(p); r++) { int hi; uint8_t lo = sprite_row_bits(p, tile, attr, r, &hi); if (lo | hi) return y + r; }
    return -1;
}

static void draw_line(Ppu *p, int L) {
    int stride = p->width;
    int wide = stride > PPU_W && p->wide_active;
    int hud = wide && p->hud_start > 0 && L >= p->hud_start;       /* the status bar stays 256 wide, centred */
    int cw = (wide && !hud) ? stride : PPU_W;                       /* canvas width for this line */
    int ox = (cw < stride) ? (stride - cw) / 2 : 0;
    uint32_t *out = (p->target ? p->target : p->work) + L * stride;
    uint8_t bg_opaque[PPU_MAXW], bg_col[PPU_MAXW];
    int on_bg = (p->mask & 0x08) != 0, on_spr = (p->mask & 0x10) != 0;
    uint8_t grey = (p->mask & 1) ? 0x30 : 0x3F;
    int coarse_x = p->v & 31, nt_x = (p->v >> 10) & 1, coarse_y = (p->v >> 5) & 31, fine_y = (p->v >> 12) & 7, nt_y = (p->v >> 11) & 1;
    memset(bg_opaque, 0, sizeof bg_opaque);
    for (int x = 0; x < cw; x++) bg_col[x] = p->pal[0];
    if (on_bg) {
        for (int x = 0; x < cw; x++) {
            if (x < 8 && !(p->mask & 2)) continue;
            int px = p->x + x;
            int tilecol = coarse_x + (px >> 3);
            int nt = nt_x ^ ((tilecol >> 5) & 1), col = tilecol & 31;
            int table = p->vertical_mirroring ? nt : nt_y;
            const uint8_t *base = &p->vram[table * 0x400];
            int tile = base[coarse_y * 32 + col];
            int attr = base[0x3C0 + (coarse_y >> 2) * 8 + (col >> 2)];
            int shift = ((coarse_y & 2) << 1) | (col & 2);
            int palsel = (attr >> shift) & 3;
            uint16_t a = (uint16_t)(((p->ctrl >> 4) & 1) * 0x1000 + tile * 16 + fine_y);
            int bit = 7 - (px & 7);
            int pix = ((p->chr[a] >> bit) & 1) | (((p->chr[a + 8] >> bit) & 1) << 1);
            if (pix) { bg_opaque[x] = 1; bg_col[x] = p->pal[palsel * 4 + pix]; }
        }
    }
    uint8_t spr_col[PPU_MAXW], spr_set[PPU_MAXW], spr_behind[PPU_MAXW];
    memset(spr_set, 0, sizeof spr_set);
    if (on_spr) {
        int found[64], n = 0, h = sprite_height(p);
        for (int i = 0; i < 64; i++) {
            int row = L - (p->oam[i * 4] + 1);
            if (row < 0 || row >= h) continue;
            if (n < 8 || p->unlimited_sprites) found[n++] = i;
            else break;
        }
        for (int k = 0; k < p->extra_n; k++) {                  /* host sprites (beyond the old right edge), under the game's own */
            int row = L - (p->extra[k].y + 1);
            if (row < 0 || row >= h) continue;
            int hi; uint8_t lo = sprite_row_bits(p, p->extra[k].tile, p->extra[k].attr, row, &hi);
            for (int c = 0; c < 8; c++) {
                int bit = (p->extra[k].attr & 0x40) ? c : 7 - c;
                int pix = ((lo >> bit) & 1) | (((hi >> bit) & 1) << 1), x = p->extra[k].x + c;
                if (!pix || x >= cw) continue;
                spr_set[x] = 1; spr_col[x] = p->pal[16 + (p->extra[k].attr & 3) * 4 + pix]; spr_behind[x] = (p->extra[k].attr & 0x20) != 0;
            }
        }
        for (int k = n - 1; k >= 0; k--) {
            int i = found[k], row = L - (p->oam[i * 4] + 1);
            int tile = p->oam[i * 4 + 1], attr = p->oam[i * 4 + 2], sx = p->oam[i * 4 + 3];
            int hi; uint8_t lo = sprite_row_bits(p, tile, attr, row, &hi);
            for (int c = 0; c < 8; c++) {
                int bit = (attr & 0x40) ? c : 7 - c;
                int pix = ((lo >> bit) & 1) | (((hi >> bit) & 1) << 1);
                int x = sx + c;
                if (!pix || x >= cw || (x < 8 && !(p->mask & 4))) continue;
                spr_set[x] = 1; spr_col[x] = p->pal[16 + (attr & 3) * 4 + pix]; spr_behind[x] = (attr & 0x20) != 0;
            }
        }
    }
    uint32_t black = 0xFF000000u;
    for (int x = 0; x < stride; x++) out[x] = black;
    uint32_t backdrop = black | p->rgb[p->pal[0] & grey];
    for (int x = 0; x < cw; x++) {
        uint8_t ci = bg_col[x];
        if (spr_set[x] && (!spr_behind[x] || !bg_opaque[x])) ci = spr_col[x];
        out[ox + x] = rendering_on(p) ? (black | p->rgb[ci & grey]) : backdrop;
    }
}

static void enter_line(Ppu *p, int L) {                       /* the PPU starts scanline L */
    int total = total_lines(p);
    if (L == 241) {                                           /* picture complete, vblank begins */
        memcpy(p->frame, p->work, sizeof(uint32_t) * (size_t)p->width * PPU_H); p->done = p->build; p->done.valid = 1; p->frames_done++; p->vblank_flag = 1;
    } else if (L == total - 1) {                              /* pre-render line */
        p->vblank_flag = 0; p->sprite0_flag = 0;
        if (rendering_on(p)) p->v = (uint16_t)((p->v & ~0x7BE0) | (p->t & 0x7BE0));
    }
    if (L < 240) {
        if (L > 0 && rendering_on(p)) p->v = (uint16_t)((p->v & ~0x041F) | (p->t & 0x041F));
        if (L == 0 && rendering_on(p)) p->v = (uint16_t)((p->v & ~0x041F) | (p->t & 0x041F));
        p->build.v[L] = p->v; p->build.x[L] = p->x; p->build.ctrl[L] = p->ctrl; p->build.mask[L] = p->mask;
        if (L == 0) {
            memcpy(p->build.oam, p->oam, 256); p->build.tags = p->tag_dma;
            p->build.extra_n = p->extra_n; memcpy(p->build.extra, p->extra, sizeof p->extra);
            p->build.wide = p->width > PPU_W && p->wide_active;
        }
        p->build.hud_start = p->hud_start;
        draw_line(p, L);
        int s0 = sprite0_line(p);
        if (s0 >= 0 && (p->mask & 0x18) == 0x18) p->hud_start = s0 + 1; else p->hud_start = 0;
        if (s0 == L && (p->mask & 0x18) == 0x18) p->sprite0_flag = 1;
        if (rendering_on(p)) {                                /* vertical increment */
            int fy = (p->v >> 12) & 7, cy = (p->v >> 5) & 31;
            if (fy < 7) p->v = (uint16_t)(p->v + 0x1000);
            else {
                p->v &= ~0x7000;
                if (cy == 29) { p->v &= ~0x03E0; p->v ^= 0x0800; }
                else if (cy == 31) p->v &= ~0x03E0;
                else p->v = (uint16_t)(p->v + 0x20);
            }
        }
    }
}

void ppu_advance(Ppu *p, double cpu_cycles) {
    double cpl = cycles_per_line(p);
    p->col += cpu_cycles;
    while (p->col >= cpl) {
        p->col -= cpl;
        if (++p->line >= total_lines(p)) p->line = 0;
        enter_line(p, p->line);
    }
}

uint8_t ppu_read(Ppu *p, uint16_t reg) {
    if (reg == 0x2002) {
        uint8_t v = (uint8_t)((p->vblank_flag << 7) | (p->sprite0_flag << 6));
        p->vblank_flag = 0; p->w = 0; return v;
    }
    if (reg == 0x2004) return p->oam[p->oam_addr];
    if (reg == 0x2007) {
        uint16_t a = p->v & 0x3FFF; uint8_t r = p->read_buffer;
        if (a >= 0x3F00) r = *pal_byte(p, a);
        else if (a >= 0x2000) p->read_buffer = *nt_byte(p, a & 0x2FFF);
        else p->read_buffer = p->chr[a];
        p->v = (uint16_t)(p->v + ((p->ctrl & 4) ? 32 : 1));
        return r;
    }
    return 0;
}

void ppu_run_to_vblank(Ppu *p) {
    int f = p->frames_done;
    while (p->frames_done == f) ppu_advance(p, cycles_per_line(p));
}

/* A picture between two finished frames: each scanline's horizontal scroll and each sprite that is the same object in both frames
 * (same slot, tile and attributes, moved less than 64 pixels) is moved by t of the way; anything else is shown as in frame b. */
void ppu_render_interp(Ppu *p, const FrameDesc *a, const FrameDesc *b, double t, uint32_t *out) {
    uint16_t sv = p->v; uint8_t sx = p->x, sc = p->ctrl, sm = p->mask, soam[256], shud = (uint8_t)0; int shud_i = p->hud_start, sextra_n = p->extra_n, swide = p->wide_active;
    uint8_t saved_oam[256]; memcpy(saved_oam, p->oam, 256); (void)soam; (void)shud;
    static struct { int x; uint8_t y, tile, attr; } saved_extra[64]; memcpy(saved_extra, p->extra, sizeof saved_extra);
    uint32_t *old_target = p->target;
    p->target = out;
    memcpy(p->oam, b->oam, 256);
    for (int i = 0; i < 64; i++) {
        uint8_t *ob = &p->oam[i * 4]; const uint8_t *oa = &a->oam[i * 4];
        int own = b->tags.owner[i];
        if (own < 8 && ob[0] < 0xEF && a->tags.seen[own] && b->tags.seen[own]) {          /* a rider or shadow: move it by how far the game drew its origin, whatever OAM slot it landed in and whatever animation frame it shows */
            int dx = (int)b->tags.ax[own] - a->tags.ax[own], dy = (int)b->tags.ay[own] - a->tags.ay[own];
            if (dx >= -64 && dx <= 64 && dy >= -64 && dy <= 64) {
                int ny = ob[0] - (int)((1.0 - t) * dy + ((1.0 - t) * dy < 0 ? -0.5 : 0.5)), nx = ob[3] - (int)((1.0 - t) * dx + ((1.0 - t) * dx < 0 ? -0.5 : 0.5));
                if (ny >= 0 && ny < 0xEF && nx >= 0 && nx < 256) { ob[0] = (uint8_t)ny; ob[3] = (uint8_t)nx; }
            }
            continue;
        }
        if (ob[0] >= 0xEF || oa[0] >= 0xEF || ob[1] != oa[1] || ob[2] != oa[2]) continue;
        int dy = (int)ob[0] - oa[0], dx = (int)ob[3] - oa[3];
        if (dy > 64 || dy < -64 || dx > 64 || dx < -64) continue;
        ob[0] = (uint8_t)(oa[0] + (int)(dy * t + (dy < 0 ? -0.5 : 0.5)));
        ob[3] = (uint8_t)(oa[3] + (int)(dx * t + (dx < 0 ? -0.5 : 0.5)));
    }
    p->extra_n = b->extra_n; memcpy(p->extra, b->extra, sizeof p->extra);
    for (int i = 0; i < b->extra_n && i < a->extra_n; i++) {
        if (b->extra[i].tile != a->extra[i].tile || b->extra[i].attr != a->extra[i].attr) continue;
        int dy = (int)b->extra[i].y - a->extra[i].y, dx = b->extra[i].x - a->extra[i].x;
        if (dy > 64 || dy < -64 || dx > 64 || dx < -64) continue;
        p->extra[i].y = (uint8_t)(a->extra[i].y + (int)(dy * t + (dy < 0 ? -0.5 : 0.5)));
        p->extra[i].x = a->extra[i].x + (int)(dx * t + (dx < 0 ? -0.5 : 0.5));
    }
    p->hud_start = b->hud_start; p->wide_active = b->wide;
    for (int L = 0; L < PPU_H; L++) {
        int ax = ((a->v[L] >> 10) & 1) * 256 + (a->v[L] & 31) * 8 + a->x[L];
        int bx = ((b->v[L] >> 10) & 1) * 256 + (b->v[L] & 31) * 8 + b->x[L];
        int d = bx - ax;
        if (d > 256) d -= 512; else if (d < -256) d += 512;
        int nx = bx;
        if (d >= -128 && d <= 128) nx = ((ax + (int)(d * t + (d < 0 ? -0.5 : 0.5))) % 512 + 512) % 512;
        p->v = (uint16_t)((b->v[L] & ~0x041F) | ((nx >> 3) & 31) | (((nx >> 8) & 1) << 10));
        p->x = (uint8_t)(nx & 7); p->ctrl = b->ctrl[L]; p->mask = b->mask[L];
        draw_line(p, L);
    }
    p->target = old_target;
    p->v = sv; p->x = sx; p->ctrl = sc; p->mask = sm; p->hud_start = shud_i; p->extra_n = sextra_n; p->wide_active = swide;
    memcpy(p->oam, saved_oam, 256); memcpy(p->extra, saved_extra, sizeof saved_extra);
}
