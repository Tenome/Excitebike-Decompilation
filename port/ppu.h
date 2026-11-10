/* Picture layer for the PC port: a small scanline renderer driven by the game's PPU register writes.
 * It is not a CPU emulator: the game logic is the lifted C in c/excitebike.c; this file only turns the register writes
 * (nametable/palette uploads, scroll, sprite DMA) into pixels, and keeps a position in the frame so the code's busy-wait
 * loops (vblank, sprite-0 split) finish the way they do on hardware. */
#pragma once
#include <stdint.h>

#define PPU_W 256              /* the NES picture width */
#define PPU_MAXW 512           /* widest picture the port can produce */
#define PPU_H 240

typedef struct {                   /* everything that decides how one picture looks, kept per frame for interpolation */
    uint16_t v[240]; uint8_t x[240], ctrl[240], mask[240];     /* scroll registers each scanline was drawn with */
    uint8_t oam[256];
    int extra_n; struct { int x; uint8_t y, tile, attr; } extra[64];
    int hud_start, wide, valid;
} FrameDesc;

typedef struct {
    uint8_t vram[2048];            /* two nametables */
    uint8_t pal[32];
    uint32_t rgb[64];              /* colours of the 64 NES palette entries (ARGB); replaceable by a mod */
    uint8_t oam[256];
    const uint8_t *chr;            /* 8 KB pattern tables from the ROM */
    int vertical_mirroring;
    int pal_region;                /* 1 = PAL timing (312 lines) */
    uint8_t ctrl, mask;
    uint16_t v, t; uint8_t x, w;   /* the PPU scroll/address registers (loop registers) */
    uint8_t read_buffer, oam_addr;
    int line;                      /* current scanline: 0-239 visible, 241+ vblank */
    double col;                    /* CPU cycles into the current scanline */
    int vblank_flag, sprite0_flag;
    int width;                     /* output width: 256 = original; wider shows the track ahead during races (the game streams about 20 tiles beyond the screen edge) */
    int wide_active;               /* set by the host: widen only while racing (menus stay 256 wide, centred) */
    int hud_start;                 /* first scanline of the status bar (below the sprite-0 split), or 0 */
    uint32_t frame[PPU_MAXW * PPU_H]; /* finished picture (ARGB), `width` pixels per row */
    uint32_t work[PPU_MAXW * PPU_H];  /* picture being drawn */
    int frames_done;               /* increments each time a picture is completed */
    int extra_n;                   /* extra sprites with 9-bit x (widescreen: riders beyond the old edge), set by the host each frame */
    struct { int x; uint8_t y, tile, attr; } extra[64];
    FrameDesc build, done;         /* the picture being drawn / the last finished one */
    uint32_t *target;              /* where draw_line writes (NULL = work) */
    int unlimited_sprites;         /* 1 = lift the 8 sprites per scanline limit */
    const uint8_t *cpu_ram;        /* for $4014 sprite DMA */
} Ppu;

void ppu_init(Ppu *p, const uint8_t *chr, int vertical_mirroring, int pal_region, const uint8_t *cpu_ram);
void ppu_write(Ppu *p, uint16_t reg, uint8_t v);       /* $2000-$2007 and $4014 */
uint8_t ppu_read(Ppu *p, uint16_t reg);                /* $2002 and $2004/$2007 */
void ppu_advance(Ppu *p, double cpu_cycles);           /* time passes: draws the visible lines it crosses */
void ppu_run_to_vblank(Ppu *p);                        /* finish this picture (idle time until the next vblank) */
void ppu_render_interp(Ppu *p, const FrameDesc *a, const FrameDesc *b, double t, uint32_t *out);   /* picture between two finished frames, t = 0..1 */
void ppu_begin_nmi(Ppu *p);                            /* vblank starts: position = first line of vblank */
