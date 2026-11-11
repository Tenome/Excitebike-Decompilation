/* Checks that ppu_render_interp moves a tagged rider by how far its origin moved, whatever OAM slot or tile it uses in each frame. Built and run by tests/test_interp.py. */
#include <stdio.h>
#include <string.h>
#include "../port/ppu.h"
static Ppu p; static uint8_t chr[0x2000]; static uint8_t ram[0x800]; static uint32_t out[PPU_MAXW * PPU_H];
static void sprite(FrameDesc *f, int slot, int x, int y, int tile) { f->oam[slot * 4] = (uint8_t)y; f->oam[slot * 4 + 1] = (uint8_t)tile; f->oam[slot * 4 + 2] = 0; f->oam[slot * 4 + 3] = (uint8_t)x; }
int main(void) {
    for (int r = 0; r < 8; r++) { chr[16 * 1 + r] = 0xFF; chr[16 * 2 + r] = 0xFF; }              /* tiles 1 and 2: solid colour 1 */
    ppu_init(&p, chr, 0, 0, ram);
    p.pal[0] = 0x0F; for (int i = 0; i < 16; i++) p.pal[16 + i] = 0x30;
    static FrameDesc a, b; memset(&a, 0, sizeof a); memset(&b, 0, sizeof b);
    for (int i = 0; i < 64; i++) { a.oam[i * 4] = b.oam[i * 4] = 0xFF; a.tags.owner[i] = b.tags.owner[i] = 255; }
    for (int L = 0; L < 240; L++) { a.mask[L] = b.mask[L] = 0x10; }                                /* sprites on, background off */
    sprite(&a, 5, 100, 100, 1);  a.tags.owner[5] = 2; a.tags.ax[2] = 100; a.tags.ay[2] = 100; a.tags.seen[2] = 1;
    sprite(&b, 9, 120, 110, 2);  b.tags.owner[9] = 2; b.tags.ax[2] = 120; b.tags.ay[2] = 110; b.tags.seen[2] = 1;       /* different slot, different tile, moved (+20, +10) */
    a.valid = b.valid = 1;
    ppu_render_interp(&p, &a, &b, 0.5, out);
    int minx = 999, miny = 999;
    for (int y = 0; y < PPU_H; y++) for (int x = 0; x < PPU_W; x++) if (out[y * PPU_W + x] != out[0]) { if (x < minx) minx = x; if (y < miny) miny = y; }
    printf("%d %d\n", minx, miny);                                                                   /* expected 110 106: x halfway between 100 and 120, y one line below halfway between 100 and 110 (sprites draw a line late) */
    return 0;
}
