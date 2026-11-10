#include "excitebike.h"

uint8_t g_ram[0x800];
const uint8_t *g_prg;

/* ---- tiny 6502 helpers so the lifted code keeps the exact arithmetic of the original ---- */
static inline uint8_t sbc8(uint8_t a, uint8_t m, uint8_t *c) { unsigned r = a + (uint8_t)~m + *c; *c = r > 0xFF; return (uint8_t)r; }
static inline uint8_t rd16mem(uint16_t a) { return a < 0x2000 ? g_ram[a & 0x7FF] : (a >= 0x8000 ? ROMB(a) : 0); }
static inline uint8_t adc8(uint8_t a, uint8_t m, uint8_t *c) { unsigned r = a + m + *c; *c = r > 0xFF; return (uint8_t)r; }
#define RAM(a) g_ram[(a) & 0x7FF]
#define NEG(v) (((v) & 0x80) != 0)

Regs DivModByX(Regs r) {
    uint8_t a = r.a, c = 0;
    RAM(0x0F) = r.x;
    uint8_t q = 0;
    do { q++; c = 1; a = sbc8(a, RAM(0x0F), &c); } while (!NEG(a));
    q--;
    a = adc8(a, RAM(0x0F), &c);
    return (Regs){ a, q, r.y, c };
}
Regs DivMod10(Regs r) { r.x = 10; return DivModByX(r); }

Regs IncMod64(Regs r) {
    uint8_t c = 0; uint8_t a = adc8(r.a, 1, &c);
    if (a == 0x40) a = 0;
    r.a = a; return r;
}

void UpdateRandom(void) {
    RAM(0x00) = RAM(0x18) & 0x02;
    uint8_t c = ((RAM(0x19) & 0x02) ^ RAM(0x00)) ? 1 : 0;
    for (int i = 0; i < 8; i++) {
        uint8_t v = RAM(0x18 + i), nc = v & 1;
        RAM(0x18 + i) = (uint8_t)((v >> 1) | (c << 7));
        c = nc;
    }
}

void TickTimers(void) {
    uint8_t x = 0x0E;
    RAM(0x20)--;
    if (NEG(RAM(0x20))) { RAM(0x20) = 0x0A; x = 0x1C; }
    do { if (RAM(0x21 + x)) RAM(0x21 + x)--; x--; } while (!NEG(x));
}

Regs AddCollisionHeight(Regs r) { if (r.a < 0xE7) r.a += 0x0C; return r; }
Regs AddCollisionWidth(Regs r)  { if (r.a < 0xE7) r.a += 0x02; return r; }

Regs RiderBaseYFrom(Regs r) {
    uint8_t c = 1;
    uint8_t a = sbc8(r.a, RAM(0xBC + r.x), &c);
    a = sbc8(a, RAM(0xB8 + r.x), &c);
    r.a = a; return r;
}
Regs RiderBaseY(Regs r) { r.a = RAM(0x03F1); return RiderBaseYFrom(r); }

Regs RiderLaneFromY(Regs r) {
    uint8_t x = r.x, y = 0;
    if (RAM(0x9C + x) == 0) {
        uint8_t a = RAM(0xB8 + x);
        for (;;) {
            uint8_t d = (uint8_t)(a - ROMB(0xD913 + y));          /* cmp ... ; bmi */
            if (NEG(d)) break;
            y++;
            if (!NEG((uint8_t)(y - 5))) { y = 0; break; }          /* cpy #5 ; bmi */
        }
        if (y != 0 && RAM(0xA4 + x) == 1) y += 2;
    }
    RAM(0x70 + x) = y;
    r.y = y; r.a = y; return r;
}

void ComputeRiderLanes(void) {
    for (int x = 3; x >= 0; x--) {
        uint8_t y = 5, a = (uint8_t)(RAM(0xB8 + x) - 0x10);
        if (!NEG(a)) {
            for (;;) { y--; if (y == 0) break; a = (uint8_t)(a - 8); if (NEG(a)) break; }
        }
        RAM(0x0360 + x) = y;
    }
}

void AdvanceTrackPositions(void) {
    for (int x = 3; x >= 0; x--) {
        if (RAM(0x60 + x) != 0) {
            uint8_t d = (uint8_t)(RAM(0x64 + x) - RAM(0x60 + x));
            if (d == 0 || NEG(d)) {
                RAM(0x64 + x) = (uint8_t)(d + 8);
                RAM(0xE0 + x) = (uint8_t)((RAM(0xE0 + x) + 1) & 0x3F);
            } else {
                RAM(0x64 + x) = d;
            }
        }
        RAM(0xD8 + x) = 0;
    }
}

void SplitDigits3(Regs r) {
    uint8_t zx = r.x;
    uint8_t p0 = RAM(0x00 + zx), p1 = RAM(0x01 + zx), p2 = RAM(0x02 + zx);
    Regs t;
    t = DivMod10((Regs){ p2, 0, 0, 0 }); RAM(0x03D6) = t.x; RAM(0x03D7) = t.a;
    t = DivMod10((Regs){ p1, 0, 0, 0 }); RAM(0x03D3) = t.x; RAM(0x03D4) = t.a;
    t = DivMod10((Regs){ p0, 0, 0, 0 }); RAM(0x03D1) = t.a;
}

void SortRidersByY(void) {
    for (int x = 3; x >= 0; x--) { RAM(0x88 + x) = (uint8_t)x; RAM(x) = RAM(0xB8 + x); }
    if (RAM(0x0373)) RAM(0x03) = RAM(0x6F);
    RAM(0x0D) = 3;
    do {
        for (uint8_t y = 0; y != RAM(0x0D); y++) {
            uint8_t xa = RAM(0x88 + y), xb = RAM(0x89 + y);
            if (RAM(xa) >= RAM(xb)) { RAM(0x89 + y) = RAM(0x88 + y); RAM(0x88 + y) = xb; }
        }
        RAM(0x0D)--;
    } while (RAM(0x0D) != 0);
}

/* ---------------------------------------------------------------- batch 2 */
Regs AccumulateRiderMove(Regs r) {            /* $DA58 */
    uint8_t x = r.x, c = 0;
    RAM(0x60 + x) = RAM(0x94 + x);
    uint8_t a = adc8(RAM(0x90 + x), RAM(0x0394 + x), &c);
    RAM(0x0394 + x) = a;
    if (c) RAM(0x60 + x)++;
    r.a = a; r.c = c; return r;
}

void ScrollWorld(void) {                      /* $DA6A */
    uint8_t c = 0, a = adc8(RAM(0x12), RAM(0x60), &c);
    RAM(0x12) = a;
    if (c) RAM(0x4D) ^= 0x01;
}

void ShiftRidersByScroll(void) {              /* $DA7A */
    for (int x = 3; x != 0; x--) {
        if (RAM(0xA8 + x) == 0) continue;
        uint8_t c = 0, a = adc8(RAM(0x60 + x), RAM(0x80 + x), &c);
        if (c) RAM(0x84 + x)++;
        c = 1; a = sbc8(a, RAM(0x60), &c);
        RAM(0x80 + x) = a;
        if (!c) RAM(0x84 + x)--;
        RAM(0x0390 + x) = (uint8_t)(RAM(0x0390 + x) - RAM(0x60));
    }
}

void ScrollSplitLayer(void) {                 /* $DBFE */
    uint8_t a = RAM(0x60), c = a & 1;
    a >>= 1;
    for (int i = 0; i < 3; i++) { uint8_t nc = a & 1; a = (uint8_t)((a >> 1) | (c << 7)); c = nc; }
    c = 0; a = adc8(a, RAM(0x03BF), &c); RAM(0x03BF) = a;
    a = adc8(RAM(0x60), RAM(0x50), &c); RAM(0x50) = a;
    if (c) RAM(0x4E) ^= 0x01;
}

Regs ComputeRiderShadowY(Regs r) {            /* $DA15 */
    uint8_t x = r.x, c = 1;
    uint8_t a = sbc8(RAM(0x0390 + x), RAM(0x80 + x), &c);
    a = sbc8(a, 8, &c);
    c = (uint8_t)(a >> 7); a = (uint8_t)(a << 1);          /* asl a */
    c = 0; a = adc8(a, RAM(0xB8 + x), &c);
    a = adc8(a, 4, &c);
    RAM(0x6C + x) = a;
    r.a = a; r.c = c; return r;
}

Regs JumpArcStep(Regs r) {                    /* $DD6F: vertical velocity/height integration for a jump */
    uint8_t x = r.x, c = r.c;
    uint8_t a = adc8(RAM(0x0380 + x), RAM(0x038C + x), &c);
    RAM(0x0380 + x) = a;
    a = adc8(RAM(0x0384 + x), 0, &c);
    RAM(0x0384 + x) = a;
    a = sbc8(RAM(0x01), RAM(0x037C + x), &c);
    RAM(0x01) = a;
    a = adc8(RAM(0x01), RAM(0x0384 + x), &c);
    r.a = a; r.c = c; return r;
}

Regs RiderPitchTimer(Regs r) {                /* $DCDE */
    uint8_t x = r.x;
    uint8_t a = RAM(0x0374 + x);
    if (a != 0) {
        RAM(0x0374 + x) = --a;
        a = RAM(0x5C + x) & 0xC0;
        if (a != 0) { a = 0; RAM(0x0374 + x) = 0; }
    }
    r.a = a; return r;
}

Regs AiMatchTargetSpeedFrom(Regs r) {         /* $CFDB: clear the throttle bits of the opposite direction */
    uint8_t x = r.x, a = RAM(0x94 + x);
    if (a != 0) { a = 0x0F; RAM(0x5C + x) = (uint8_t)(a & RAM(0x5C + x)); a = RAM(0x5C + x); }
    r.a = a; return r;
}
Regs AiMatchTargetSpeed(Regs r) {             /* $CFCB: compare speed with target; set accelerate/brake input bits */
    uint8_t x = r.x, y = 0x80, hi = RAM(0x94 + x), thi = RAM(0x78 + x);
    if (hi >= thi) {
        if (hi != thi || RAM(0x90 + x) >= RAM(0x74 + x)) { Regs q = AiMatchTargetSpeedFrom(r); q.y = y; return q; }
    }
    uint8_t a = (uint8_t)(y | RAM(0x5C + x));
    RAM(0x5C + x) = a;
    r.a = a; r.y = y; return r;
}

Regs SetTrackRowPointer(Regs r) {             /* $E80D */
    RAM(0x03) = ROMB(0xE54E + r.y);
    r.a = RAM(0x04) = ROMB(0xE554 + r.y);
    return r;
}
Regs TrackPieceAt(Regs r) {                   /* $E803: A = track piece at row Y, ring position $08 */
    r = SetTrackRowPointer(r);
    RAM(0x07) = r.y;
    r.y = RAM(0x08);
    uint16_t p = (uint16_t)(RAM(0x03) | RAM(0x04) << 8);
    r.a = rd16mem((uint16_t)(p + r.y));
    return r;
}
Regs TrackPieceAtRow(Regs r) { RAM(0x08) = RAM(0xE0 + r.x); return TrackPieceAt(r); }                 /* $E7FF */
Regs TrackPieceAtRiderLane(Regs r) { r.y = RAM(0x0360 + r.x); return TrackPieceAtRow(r); }             /* $E7FC */

Regs RiderYOverlapTest(Regs r) {              /* $E52C: 0 when |Y[x]-Y[y]| is within 0x12 */
    uint8_t d = (uint8_t)(RAM(0x8C + r.x) - RAM(0x8C + r.y));
    if (d >= 0xEC) { r.a = d; r.c = 1; return r; }
    if (d < 0x12)  { r.a = d; r.c = 0; return r; }
    r.a = 0; r.c = 1; return r;
}

Regs ClearRider(Regs r) {                     /* $DB95 */
    static const uint16_t arr[] = { 0xA8, 0xB8, 0xBC, 0xA0, 0xA4, 0x58, 0xCC, 0x036C, 0x90, 0x94, 0x98, 0x9C, 0xB0, 0xD4, 0x0388, 0xC0, 0x039C, 0xDC, 0x70, 0x0370 };
    for (unsigned i = 0; i < sizeof arr / sizeof arr[0]; i++) RAM(arr[i] + r.x) = 0;
    r.a = 0; return r;
}

Regs AdvanceBufferPos(Regs r) {               /* $C971: X = old PPU buffer length, buffer length += A */
    uint8_t c = 0;
    r.x = RAM(0x0300);
    r.a = adc8(r.a, RAM(0x0300), &c);
    RAM(0x0300) = r.a; r.c = c; return r;
}

/* ---- batch 2: rider jump/launch, target speed/pitch, AI input bits ---- */
void SetRiderTargetSpeed(Regs r) {            /* $DB50: Y = speed class from the AI */
    uint8_t x = r.x, y = r.y, a;
    if (RAM(0x52)) a = 3;
    else {
        if (x == 3) {                          /* $DB6C: the pace-setter copies the player's speed when close by */
            uint8_t go_table = 0;
            if ((RAM(0x84 + x) >> 1) & 1) go_table = 1;
            else if (RAM(0x94) == 0) go_table = 1;
            else {
                RAM(0x78 + x) = RAM(0x94); RAM(0x74 + x) = RAM(0x90);
                if (RAM(0x84 + x) != 0) {
                    if (RAM(0x80 + x) >= 0x40) go_table = 1;
                    else if (RAM(0x70) == RAM(0x73)) return;
                }
                if (!go_table) { if (RAM(0x78 + x) < 4) RAM(0x78 + x)++; return; }
            }
            (void)go_table;
        }
        a = ROMB(0xD8D5 + y);
    }
    RAM(0x78 + x) = a;
    y = RAM(0x1B + x) & 0x0F;
    RAM(0x74 + x) = ROMB(0xD8CD + y);
}

void AiJumpCheck(Regs r) {                    /* $D000 */
    uint8_t x = r.x; r.y = 0;
    if (x != 3) {
        if ((RAM(0x80 + x) & 0x10) == 0) return;
        uint8_t a = RAM(0x1A + x);
        if (a < 0xC0) return;
        if (a == 0xC0) r.y = 1;
    }
    SetRiderTargetSpeed(r);
}

void AiClearPitchBits(Regs r) { RAM(0x5C + r.x) &= 0xF0; }           /* $CFE3 */
void AiSetPitchInput(Regs r) {                /* $CFEA */
    uint8_t x = r.x;
    AiClearPitchBits(r);
    uint8_t y = 1, t = RAM(0x7C + x), p = RAM(0xAC + x);
    if (t == 0 || t == p) return;
    if (t > p) y = 2;
    RAM(0x5C + x) |= y;
}

void SetRiderTargetPitch(Regs r) {            /* $DCA0 */
    uint8_t x = r.x, y = RAM(0xD4 + x), a;
    if (RAM(0x52) == 1 && (uint8_t)(x | RAM(0x98) | RAM(0x9C) | RAM(0x58)) == 0) a = 0x0A;
    else a = ROMB(0xD88B + y);
    RAM(0x0368 + x) = a;
    if (RAM(0xA4 + x) == 1) RAM(0x0368 + x) = 6;
}

void RiderPitchAdjust(Regs r) {               /* $DCC7: step pitch one notch toward A, at most once per Y-latched period */
    uint8_t x = r.x;
    RAM(0x00) = r.a;
    if (RAM(0x2A + x) != 0) return;
    RAM(0x2A + x) = r.y;
    uint8_t p = RAM(0xAC + x);
    if (p == RAM(0x00)) return;
    if (p < RAM(0x00)) RAM(0xAC + x) = p + 1; else RAM(0xAC + x) = p - 1;
}

static uint8_t jump_setup(uint8_t x) {         /* $DD38 body; returns carry as the 6502 leaves it */
    uint8_t c = 0;
    RAM(0xB0 + x) = 2; RAM(0x0380 + x) = 0x0F;
    RAM(0x0378 + x) = adc8(RAM(0x90 + x), 0xAF, &c);
    RAM(0x037C + x) = adc8(RAM(0x94 + x), 0, &c);
    uint8_t v = RAM(0x0388 + x);
    c = v >= 2;
    if (v == 2) {
        c = RAM(0x037C + x) & 1; RAM(0x037C + x) >>= 1;
        uint8_t o = RAM(0x0378 + x); RAM(0x0378 + x) = (uint8_t)((o >> 1) | (c << 7)); c = o & 1;
    }
    if (x == 0) {
        uint8_t t = RAM(0x94); c = (t >> 4) & 1;
        uint8_t a = (uint8_t)((t << 4) ^ 0x30);
        RAM(0xFF) = a ? a : 0x08;
    }
    return c;
}
void RiderJumpSetup(Regs r) { jump_setup(r.x); }

static void launch_tail(uint8_t x, uint8_t c) {   /* $DD1A */
    uint8_t y = RAM(0x5C + x) & 3;
    RAM(0x038C + x) = ROMB(0xD868 + y);
    RAM(0x01) = RAM(0x8C + x);
    Regs q = JumpArcStep((Regs){ 0, x, y, c });
    RAM(0x8C + x) = q.a;
    if (RAM(0xCC + x) == 0) RAM(0x0364 + x) = 1;
}
void RiderStartJump(Regs r) {                 /* $DD06 */
    uint8_t x = r.x;
    RAM(0x0384 + x) = RAM(0x94 + x);
    launch_tail(x, jump_setup(x));
}
void RiderLaunchUpdate(Regs r) {              /* $DCF2 */
    uint8_t x = r.x, a = RAM(0xB0 + x);
    if (a == 0) return;
    if (a != 2) {                              /* $DCFA */
        RAM(0x0384 + x) = 0; launch_tail(x, jump_setup(x)); return;
    }
    uint8_t in = RAM(0x5C + x);
    if (in & 1) { if (RAM(0x4C) == 0) return; launch_tail(x, 1); }
    else launch_tail(x, 0);
}

void ClearOam(void) { for (int i = 0; i < 256; i++) RAM(0x0200 + i) = 0xF8; }   /* $D255 */

/* ---- batch 3: speed model and AI lane changes ---- */
Regs RiderTerrainSpeedBias(Regs r) {          /* $CDEE: bump state ($036C) from terrain; returns the 6502 Z flag in .c (1 = on the ramp-free path) */
    uint8_t x = r.x, y;
    if (RAM(0xC0 + x) != 0xE4) {
        int skip = (RAM(0xA4 + x) == 3) && RAM(0x70 + x) >= 3;
        if (!skip) {
            y = RAM(0xB8 + x);
            if (y < 0x38 && y >= 0x08) {                       /* $CE1D */
                if (RAM(0x036C + x) != 1) RAM(0x036C + x) = 0;
                r.c = 1; return r;
            }
        }
    }
    if (RAM(0x036C + x) != 1) RAM(0x036C + x) = 2;             /* $CE0A */
    if (x == 0) RAM(0xFD) = 4;
    r.c = 0; return r;
}

void RiderAccelerate(Regs r) {                /* $CE29: Y = acceleration class; speed capped for rider 0 */
    uint8_t x = r.x, y = r.y, c = 0;
    if (x != RAM(0x4C)) return;
    RAM(0x90 + x) = adc8(ROMB(0xC0BC + y), RAM(0x90 + x), &c);
    if (c) RAM(0x94 + x)++;
    if (x != 0) return;
    uint8_t hi = RAM(0x94), t = ROMB(0xC0D1 + y);
    if (hi == t) { if (RAM(0x90) < ROMB(0xC0CE + y)) return; }
    else if (hi < t) return;
    RAM(0x90) = ROMB(0xC0CE + y); RAM(0x94) = t;
}

void RiderDecelerateBy(Regs r) {              /* $CE5C */
    uint8_t x = r.x;
    RAM(0x00) = r.y;
    if (RAM(0x94 + x) == 0) {
        uint8_t i = RAM(0xB0 + x) >> 1;
        if (RAM(0x90 + x) < ROMB(0xC0CC + i)) return;
    }
    uint8_t y = RAM(0x00), lo = RAM(0x90 + x), m = ROMB(0xC0C1 + y);
    RAM(0x90 + x) = (uint8_t)(lo - m);
    if (lo >= m) return;
    if (RAM(0x94 + x)) { RAM(0x94 + x)--; return; }
    RAM(0x90 + x) = 0;
}
void RiderDecelerate(Regs r) { if (r.x == RAM(0x4C)) RiderDecelerateBy(r); }   /* $CE58 */

void RiderPitchWobble(Regs r) {               /* $CE83: bit 0 of $00 chooses the direction; pitch crash at 13 */
    uint8_t x = r.x;
    if (RAM(0x26 + x)) return;
    uint8_t i = RAM(0xB0 + x) >> 1;
    RAM(0x26 + x) = ROMB(0xC0D4 + i);
    uint8_t up = RAM(0x00) & 1; RAM(0x00) >>= 1;
    uint8_t p = RAM(0xAC + x);
    if (up) {
        uint8_t t = ROMB(0xC0C8 + i);
        if (p == t) return;
        if (p < t) RAM(0xAC + x) = p + 1; else RAM(0xAC + x) = p - 1;
        return;
    }
    RAM(0x0388 + x) &= 2;
    if (p < ROMB(0xC0CA + i)) { RAM(0xAC + x) = p + 1; return; }
    if ((RAM(0x5C + x) & 0xC0) == 0) return;
    if (RAM(0xB0 + x) != 0) return;
    RAM(0xAC + x) = p + 1;
    RAM(0x26 + x) = 0x0D;
    if ((uint8_t)(p + 1) >= 0x0D) { RAM(0x98 + x) = 1; RAM(0x26 + x) = 2; }
}

Regs AiLaneBlocked(Regs r) {                  /* $CF96: C=1 when another rider is in lane $02 within the X window */
    uint8_t x = r.x, c = 0;
    RAM(0x00) = adc8(RAM(0x80 + x), ROMB(0xC0D6 + r.y), &c);
    RAM(0x01) = (uint8_t)(RAM(0x00) - ROMB(0xC0D7 + r.y));
    uint8_t y = RAM(0x4A);
    for (;;) {
        if (y != RAM(0x0F) && (RAM(0x84 + y) & 1) && RAM(0x70 + y) != 0 && RAM(0x70 + y) == RAM(0x02)) {
            uint8_t v = RAM(0x80 + y);
            if (v < RAM(0x00) && v >= RAM(0x01)) { r.c = 1; return r; }
        }
        y++;
        if (y >= 4) { r.c = 0; return r; }
    }
}
Regs AiTrackPieceOpen(Regs r) {               /* $CF8B: C=0 only for pieces $3B-$3D */
    r.c = !(r.a >= 0x3B && r.a < 0x3E); return r;
}
static uint8_t lane_piece_open(uint8_t x, uint8_t y) {   /* $CF88 */
    Regs q = TrackPieceAtRow((Regs){ 0, x, y, 0 });
    return AiTrackPieceOpen(q).c;
}

static void lane_down(uint8_t x);
static void lane_up(uint8_t x) {              /* $CF47 */
    uint8_t y = RAM(0x0360 + x) - 1;
    if ((uint8_t)(y - 1) & 0x80) { lane_down(x); return; }
    if (lane_piece_open(x, y)) return;
    RAM(0x02) = RAM(0x70 + x) + 1;
    if (AiLaneBlocked((Regs){ 0, x, 0, 0 }).c) return;
    RAM(0xDC + x) = 1;
}
static void lane_down(uint8_t x) {            /* $CF6A */
    uint8_t y = RAM(0x0360 + x) + 1;
    if (!((uint8_t)(y - 5) & 0x80)) { lane_up(x); return; }
    if (lane_piece_open(x, y)) return;
    RAM(0x02) = RAM(0x70 + x) - 1;
    if (AiLaneBlocked((Regs){ 0, x, 0, 0 }).c) return;
    RAM(0xDC + x) = 0xFF;
}
void AiLaneChangeUp(Regs r) { lane_up(r.x); }
void AiLaneChangeDown(Regs r) { lane_down(r.x); }

void AiConsiderLaneChange(Regs r) {           /* $CF0C */
    uint8_t x = r.x;
    if (!(RAM(0x84 + x) & 1)) return;
    RAM(0x02) = RAM(0x70 + x);
    int to64 = 0;
    if (AiLaneBlocked((Regs){ 0, x, 2, 0 }).c) {
        AiMatchTargetSpeedFrom((Regs){ 0, x, 2, 0 });
        if (!(RAM(0x80 + x) & 0x80)) return;
        if (RAM(0x18 + x) & 1) to64 = 1; else { lane_up(x); return; }
    } else {
        if (RAM(0xDC + x) != 0) return;
        if (!(RAM(0x84 + x) & 1)) return;
        uint8_t a = RAM(0x80 + x);
        if (a >= 0xF0) return;
        if (!(a & 0x80)) return;
        a = RAM(0x19 + x);
        if (a < 0xE0) return;
        if (a < 0xF8) to64 = 1; else { lane_up(x); return; }
    }
    if (to64 && RAM(0xC0 + x) == 0xE6) { lane_up(x); return; }
    lane_down(x);
}

/* ---- batch 4: rider start-sequence states (gate, move to lane, wait, finish) ---- */
void RiderState1Gate(Regs r) {                /* $D933: riders creep up to the gate */
    uint8_t x = r.x;
    if (RAM(0x0370 + x) != 0) {
        if (RAM(0x3F) & 1) return;
        RAM(0x0390 + x)++;
        uint8_t y = RAM(0x03E4 + x);
        uint8_t a = (uint8_t)(RAM(0x80 + x) + ROMB(0xD90E + y));
        if (a >= RAM(0x0390 + x)) return;
    }
    if (++RAM(0x9C + x) == 0) return;
    RAM(0x2A + x) = 8;
}

void RiderState2MoveToLane(Regs r) {          /* $D953 */
    uint8_t x = r.x, y = x;
    if (x != 0 && RAM(0xBC + x) != 0) y = 4;
    uint8_t a = RAM(0xB8 + x), t = ROMB(0xD8C4 + y);
    if (a != t) { RAM(0xDC + x) = a < t ? 1 : 0xFF; return; }
    RAM(0x0398 + x) = 0; RAM(0xDC + x) = 0;
    RAM(0x9C + x)++;
    if (x == 0) RAM(0xFD) = 2;
    RAM(0x2A + x) = 8;
}

void RiderState3Wait(Regs r) {                /* $D983 */
    uint8_t x = r.x, a;
    if (RAM(0x0370 + x) != 0) {
        if (RAM(0x2A + x) != 0) return;
        int dec = 0;
        a = 0;
        int frame = 1;
        if ((uint8_t)(x | RAM(0x03F7)) == 0) {
            uint8_t y = RAM(0x49);
            a = RAM(0x14) & 0xC0;
            if (a != 0 && y == 0) { RAM(0x49) = a; dec = 1; frame = 0; a = 0; }
            else RAM(0x49) = (a != 0) ? y : 0;      /* $D99F stores A, which is the old latch after TYA */
        }
        if (frame) { a = RAM(0x3F) & 0x0F; if (a == 0) dec = 1; }
        if (dec) RAM(0x0390 + x)--;
        if ((a & 7) == 0) RAM(0x0398 + x) ^= 1;
        if ((uint8_t)(RAM(0x0390 + x) - 8) >= RAM(0x80 + x)) return;
    }
    RAM(0x36 + x) = 3;                         /* $D9C0 */
    RAM(0x9C + x)++;
    if (x == 3) { RAM(0x03A8) = 0; RAM(0x0373) = 0; }
}

void RiderState5Finish(Regs r) {              /* $D9F6 */
    uint8_t x = r.x;
    if ((RAM(0x94 + x) | RAM(0xDC + x)) == 0 && RAM(0xB8 + x) == ROMB(0xD8C4 + x)) return;
    RAM(0xDC + x) = 1;
    if (x != 0 && RAM(0xB8 + x) < 8) return;
    RAM(0x9C + x) = 0;
}

/* ---- batch 5: reset, time-table indexing, release state ---- */
void ResetGameRam(void) {                     /* $CA85: clears zero page $21-$FF, keeps the menu cursor */
    uint8_t cur = RAM(0x42);
    for (int i = 0x21; i <= 0xFF; i++) RAM(i) = 0;
    RAM(0xFC) = 0;
    RAM(0x49)++;
    RAM(0x42) = cur;
}

Regs TimeTableIndexForTrack(Regs r) {         /* $CB13: best-time table slot for track number $02 */
    uint8_t y = RAM(0x02), a = 0x20, c = y >= 5;
    if (y == 5) { r.a = a; r.y = y; r.c = c; return r; }
    a = 0;
    for (;;) {
        y--;
        if (y & 0x80) break;
        c = 0; a = adc8(a, 3, &c);
    }
    y = RAM(0x46);
    if (y) a |= 0x10;
    r.a = a; r.y = y; r.c = c; return r;
}
Regs TimeTableIndexForSelection(Regs r) {     /* $CB06 */
    r = TimeTableIndexForTrack(r);
    uint8_t c = r.c, a = r.a;
    if (RAM(0x03F2) != 0) { c = 0; a = adc8(a, 0x23, &c); }
    r.a = r.y = a; r.c = c; return r;
}

void SaveInputToRider0(void) { RAM(0x5C) = RAM(0x14); }   /* $CA1B */

void RiderState4Release(Regs r) {             /* $D9D3 */
    uint8_t x = r.x;
    if (RAM(0x36 + x) != 0) return;
    if (x == 0) {
        if (RAM(0x03E0) != 0) { RAM(0x9C) = 0; return; }
        if (RAM(0x03F7) != 0) { ResetGameRam(); return; }
    } else {
        if (RAM(0x22) != 0) return;
        RAM(0xDC + x) = 1; RAM(0x22) = 0x18;
    }
    RAM(0x9C + x)++;
}

/* ---- batch 6: player/AI control step, race clock, engine sound ---- */
void RiderControlStep(Regs r) {               /* $CD59: one rider's throttle, brake and pitch handling for this frame */
    uint8_t x = r.x, y = 0, a;
    RAM(0x0A) = RAM(0x5C + x) & 3;
    if ((RAM(0x0374 + x) | RAM(0x98 + x)) != 0) goto decel;
    a = RAM(0x9C + x);
    if (a != 0 && a != 5) goto decel;
    if (x == 0) {
        y = 2;
        if (RAM(0x52) != 0) goto cmp_speed;
        y = 0;
    }
    if (RAM(0xB0 + x) != 0) {                   /* $CDB2: airborne */
        y = 4; a = RAM(0x0A);
        if (a == 0) goto decel;
        y = a; goto brake;
    }
    a = RAM(0x5C + x) & 0xC0;
    if (a == 0) goto decel;
    RAM(0x00) = x;
    if (!(a & 0x80)) RAM(0x00)++;
    if (!RiderTerrainSpeedBias(r).c && RAM(0x94 + x) != 0) goto decel;
    y = RAM(0x00);
    if (x != 0) goto accel;
cmp_speed: {                                    /* $CD9A */
    uint8_t hi = RAM(0x94 + x), t = ROMB(0xC0D1 + y);
    if (hi < t) goto accel;
    if (hi != t) goto brake;
    uint8_t lo = RAM(0x90 + x), t2 = ROMB(0xC0CE + y);
    if (lo == t2) goto after;
    if (lo >= t2) goto brake;
}
accel:
    RiderAccelerate((Regs){ 0, x, y, 0 }); goto after;
brake:
    y++;
decel:
    RiderDecelerate((Regs){ 0, x, y, 0 });
after:                                          /* $CDBD */
    if (RAM(0x98 + x) != 0) return;
    if (RAM(0xB0 + x) == 0) {
        if ((RAM(0x58 + x) | RAM(0x52)) != 0) goto settle;
        if (RAM(0x94 + x) == 0 && RAM(0x90 + x) < 0xA0) goto settle;
    }
    a = RAM(0x0A);                              /* $CDD5 */
    if (a == 0) goto settle;
    RAM(0x00) = a;
    RiderPitchWobble(r);
    return;
settle:                                         /* $CDDE */
    if (RAM(0xB0 + x) != 0) return;
    if (RAM(0x0368 + x) == RAM(0xAC + x)) return;
    RiderPitchAdjust((Regs){ RAM(0x0368 + x), x, 5, 0 });
}

void UpdateRaceClock(void) {                  /* $DF30: ticks the race time (minutes:seconds:hundredths) and mirrors the digits to $03D9 */
    if (!RAM(0x4F)) return;
    RAM(0x6B) += 0x10;
    for (;;) {
        if (RAM(0x6B) < 0x0A) break;
        RAM(0x6B) -= 0x0A;
        if (++RAM(0x6A) < 0x64) continue;
        RAM(0x6A) = 0;
        if (++RAM(0x69) < 0x3C) continue;
        RAM(0x69) = 0;
        if (++RAM(0x68) < 0x09) continue;
        RAM(0x52) = 2;
        break;
    }
    SplitDigits3((Regs){ 0, 0x68, 0, 0 });
    for (int i = 6; i >= 0; i--) RAM(0x03D9 + i) = RAM(0x03D1 + i);
}

void UpdateEngineSound(void) {                /* $DEE2: engine pitch request for rider 0 */
    uint8_t x = 0;
    if (RAM(0x03A9) != 0) {
        if (RAM(0x4C) & 1) return;
        RAM(0x00) = RAM(0x94); RAM(0x01) = RAM(0x90);
        for (int i = 0; i < 3; i++) { uint8_t c = RAM(0x00) & 1; RAM(0x00) >>= 1; RAM(0x01) = (uint8_t)((RAM(0x01) >> 1) | (c << 7)); }
        x = RAM(0xB0) ? 4 : 2;
        uint8_t a = (uint8_t)(RAM(0x01) - 2);
        if (a & 0x80) x = 1;
        else {
            x = DivModByX((Regs){ a, x, 0, 0 }).x;
            if (x == 0) x = 1;
        }
        if (x >= 0x2F) { x = 0x2F; if ((RAM(0x3F) & 8) == 0) x--; }
        if (!(RAM(0x5C) & 0x80)) x |= 0x80;
    }
    RAM(0xFC) = x;
}

/* ---- batch 7: AI obstacle scan and the per-frame rider update loops ---- */
Regs AiScanObstacles(Regs r) {                /* $D018: A = obstacles found ahead (Z flag set when none); steers around them */
    uint8_t x = r.x, a, y;
    int8_t yb;
    RAM(0x09) = 0; RAM(0x0D) = 0;
    RAM(0x0A) = (uint8_t)(x << 2);
    yb = 3;
    for (;;) {
        RAM(0x0B) = (uint8_t)yb;
        a = RAM(0x03C0 + RAM(0x0A));
        if (a == 0xC0 || a == 0xC1 || (a >= 0x70 && a < 0x74)) goto obstacle;
        if (a >= 0x48 && a < 0x4B) { a = 9; goto done; }
        RAM(0x0A)++;
        yb = (int8_t)(RAM(0x0B) - 1);
        if (yb < 0) break;
    }
clear:                                          /* $D04B */
    y = 0;
    if (RAM(0x58 + x) == 0) y = RAM(0x0368 + x);
    a = y; goto done;
obstacle:                                       /* $D058 */
    RAM(0x0D)++;
    a = (uint8_t)(((RAM(0x0A) & 3) + 1 + RAM(0xE0 + x)) & 0x3F);
    RAM(0x08) = a; RAM(0x09) = 0x40;
    y = RAM(0x0360 + x);
    for (;;) {                                  /* $D06F: look toward lower lanes */
        y--;
        if ((uint8_t)(y - 1) & 0x80) break;
        a = TrackPieceAt((Regs){ 0, x, y, 0 }).a;
        y = RAM(0x07);
        if (a == 0xFA) break;
        if (!AiTrackPieceOpen((Regs){ a, 0, 0, 0 }).c) { AiLaneChangeUp((Regs){ 0, x, 0, 0 }); goto clear; }
    }
    y = RAM(0x0360 + x);
    for (;;) {                                  /* $D08B */
        y++;
        if (!((uint8_t)(y - 6) & 0x80)) goto clear;
        a = TrackPieceAt((Regs){ 0, x, y, 0 }).a;
        y = RAM(0x07);
        if (a == 0xE4) goto clear;
        if (!AiTrackPieceOpen((Regs){ a, 0, 0, 0 }).c) { AiLaneChangeDown((Regs){ 0, x, 0, 0 }); goto clear; }
    }
done:
    RAM(0x7C + x) = a;
    r.a = RAM(0x0D); r.c = (r.a == 0); return r;
}

void UpdateAiRiders(void) {                   /* $CED0 */
    uint8_t x = RAM(0x4A);
    do {
        RAM(0x0F) = x;
        if (RAM(0xA8 + x) != 0 && (RAM(0x98 + x) | RAM(0x9C + x)) == 0) {
            AiSetPitchInput((Regs){ 0, x, 0, 0 });
            if (RAM(0xB0 + x) != 0) RAM(0x7C + x) = RAM(0x0368 + x);
            else {
                AiMatchTargetSpeed((Regs){ 0, x, 0, 0 });
                if (AiScanObstacles((Regs){ 0, x, 0, 0 }).a == 0 && RAM(0x03A6) != 0) {
                    AiJumpCheck((Regs){ 0, x, 0, 0 });
                    if (RAM(0x52) == 0) AiConsiderLaneChange((Regs){ 0, x, 0, 0 });
                }
            }
        }
        x = (uint8_t)(RAM(0x0F) + 1);
    } while (x < 4);
}

void UpdateRiderControls(void) {              /* $CD1F */
    if (RAM(0x4F)) {
        for (int i = 3; i >= 0; i--) {
            uint8_t x = (uint8_t)i;
            if (RAM(0xA8 + x) == 0) continue;
            if (RAM(0x9C + x) != 5 && (RAM(0x9C + x) | RAM(0x98 + x) | RAM(0x03E0 + x)) != 0) RAM(0x5C + x) = 0;
            RiderControlStep((Regs){ 0, x, 0, 0 });
        }
    }
    if (RAM(0x34) == 0 && (RAM(0x5C) & 0xC0) != 0 && (RAM(0x03A9) | RAM(0x52)) == 0) {
        RAM(0x03A9) = 1; RAM(0xFE) = 1;
    }
}

/* ---- batch 8: spawning CPU riders and the lost-rider respawn ---- */
Regs SpawnRider(Regs r) {                     /* $DAE3: X = slot, Y = start lane + 1; A=0 (Z set) when the spot is blocked */
    uint8_t x = r.x, y = r.y, a;
    ClearRider((Regs){ 0, x, 0, 0 });
    y--;
    RAM(0xB8 + x) = ROMB(0xD8D8 + y);
    y = RAM(0x84 + x);
    RAM(0x80 + x) = ROMB(0xD8DF + y);
    RAM(0xAC + x) = 6;
    RAM(0xE0 + x) = (uint8_t)((RAM(0xE0) + ROMB(0xD8E2 + y)) & 0x3F);
    RAM(0x64 + x) = RAM(0x64);
    if (y != 0) {
        a = TrackPieceAtRow((Regs){ 0, x, 5, 0 }).a;
        if (a != 0xE4) {
            if (a < 0x3B || a >= 0x93) { r.a = 0; r.c = 1; return r; }
            a = TrackPieceAtRow((Regs){ 0, x, 2, 0 }).a;
            if (a == 0xE6) {
                if (RAM(0xB8 + x) >= 0x20) { RAM(0xBC + x) = 0x30; RAM(0xA4 + x) = 1; }
                else RAM(0xA4 + x) = 3;
            }
        }
    }
    y = RAM(0x84 + x);                          /* $DB34 */
    SetRiderTargetSpeed((Regs){ 0, x, y, 0 });
    RAM(0x94 + x) = (uint8_t)((RAM(0x84 + x) ^ 2) << 1);
    RAM(0x039B + x) = 0x20;
    RAM(0x23) = 0x10;
    RAM(0xA8 + x) = 1;
    r.a = 1; r.c = 0; return r;
}

void SpawnCpuRiders(void) {                   /* $DA9F: occasionally brings a CPU rider in from the edge */
    uint8_t x = 3;
    if (RAM(0x3B) != 0) x--;                    /* first pass is skipped when $3B is set (falls to the DEX) */
    for (;;) {
        if ((uint8_t)(x ^ RAM(0x4C) | RAM(0xA8 + x) | RAM(0x23) | RAM(0x0373) | RAM(0x03A8)) == 0 && RAM(0x18 + x) >= 0xA0) {
            uint8_t a = RAM(0x18 + x), y;
            RAM(0x00) = x;
            y = (uint8_t)((a & 3) + 1);
            RAM(0x84 + x) = RAM(0x94) & 2;
            for (uint8_t xx = 3; xx != 0; xx--) {
                RAM(0x01) = y;
                if (RAM(0x70 + xx) == y) { y++; if (y >= 5) y = 1; }
            }
            x = RAM(0x00);
            SpawnRider((Regs){ 0, x, y, 0 });
        }
        x--;
        if (x == 0) return;
    }
}

void HandleLostRider(void) {                  /* $DBC4: clears rider 3 when it falls behind, or respawns it ahead */
    if (RAM(0x03A8) == 0) return;
    if (RAM(0xAB) != 0) {
        if (RAM(0x87) & 1) return;
        if (!(RAM(0x87) & 2) && RAM(0x83) >= 0xEA) return;
        ClearRider((Regs){ 0, 3, 0, 0 });
        return;
    }
    RAM(0x03A8) = 0;
    RAM(0x87) = 2;
    if (SpawnRider((Regs){ 0, 3, 1, 0 }).a == 0) return;
    RAM(0x97) = 0; RAM(0x8F) = 0x92; RAM(0x0373) = 0x92;
    RAM(0x9B) = 0xFF;
}

/* ---- batch 9: track script interpreter ----
 * Each track piece can start a script (tables at $E559/$E56E): pairs of (position, opcode/operand). The opcode byte
 * indexes the jump table at $E6B7. Handlers set rider height, bump/terrain state and launch jumps. */
static uint8_t ts_set_height(uint8_t x, uint8_t a) {      /* $E893: returns A = distance into the piece */
    RAM(0xD4 + x) = a; RAM(0xB4 + x) = a;
    return (uint8_t)(RAM(0xC8 + x) - RAM(0xD0 + x));
}
static void ts_height_abs(uint8_t x, uint8_t a) { RAM(0xBC + x) = a; RAM(0xE4 + x) = a; }       /* $E84F */
static void ts_height_rel(uint8_t x, uint8_t a) { RAM(0x00) = a; RAM(0xBC + x) = (uint8_t)(RAM(0xE4 + x) - a); }   /* $E86F */

void RiderLaunchFromRest(Regs r) {            /* $DCFA path: start a jump with no speed bonus */
    uint8_t x = r.x;
    RAM(0x0384 + x) = 0; launch_tail(x, jump_setup(x));
}

static void ts_op_E963(uint8_t x) { RAM(0xCC + x) = 0; RAM(0xD4 + x) = 0; RAM(0xB4 + x) = 0; }
static void ts_op_E8E3(uint8_t x) { RAM(0xA0 + x) = 1; }
static void ts_op_E85D(uint8_t x) { ts_height_abs(x, ts_set_height(x, 6)); RAM(0xD8 + x) = 0x60; }
static void ts_op_E86A(uint8_t x) { ts_height_rel(x, ts_set_height(x, 1)); }
static void ts_op_E845(uint8_t x) { RAM(0xD8 + x) = 0x80; ts_height_abs(x, ts_set_height(x, 5) >> 1); }
static void ts_op_E854(uint8_t x) { ts_height_rel(x, ts_set_height(x, 2) >> 1); }
static void ts_op_E934(uint8_t x) {
    if (RAM(0xB0 + x) != 0) return;
    uint8_t y = 0, a = RAM(0x94 + x);
    if (a == 0) return;
    if (a < 2 && RAM(0x90 + x) < RAM(0xD8 + x)) y = 1;
    RAM(0x0388 + x) = y;
    if (RAM(0xA0 + x) == 2) RiderStartJump((Regs){ 0, x, 0, 0 });
    else RiderLaunchFromRest((Regs){ 0, x, 0, 0 });
}
static void ts_op_E818(uint8_t x) {
    if (RAM(0xB0 + x) != 0) return;
    if (!((uint8_t)(RAM(0xAC + x) - 7) & 0x80)) return;
    uint8_t hi = RAM(0x94 + x);
    if (hi < 3) {
        if (hi != 2) return;
        if (!(RAM(0x90 + x) & 0x80)) return;
    }
    RAM(0x98 + x) = 0xFF;
}
static void ts_op_EA8F(uint8_t x) {            /* finish line: rider 0 copies the time digits to the sprite block, or starts the end sequence */
    if (x != 0) return;
    RAM(0x3A) = 0x1D;
    if (RAM(0x57) == 0) { RAM(0x32) = 0x10; RAM(0xFD) = 2; RAM(0x52) = 1; RAM(0x3A) = 0; return; }
    if (RAM(0x3C) != 0) { RAM(0x3A) = 0; return; }
    RAM(0x0D) = x;
    uint8_t y = 0x19;
    for (int i = 6; i >= 0; i--) { RAM(0x02C0 + y) = RAM(0x03D9 + i); y -= 4; }
}
static void ts_op_E879(uint8_t x) {
    ts_height_abs(x, (uint8_t)(ts_set_height(x, 4) << 1));
    if (RAM(0xA0 + x) != 0) ts_height_abs(x, RAM(0xBC + x) + 0x10);
    RAM(0xD8 + x) = 0x40;
}
static void ts_op_E89D(uint8_t x) {
    uint8_t s = RAM(0xA4 + x);
    if (s == 1) return;
    ts_height_rel(x, (uint8_t)(ts_set_height(x, 3) << 1));
    if (RAM(0xA4 + x) == 4) {
        RiderStartJump((Regs){ 0, x, 0, 0 });
        RAM(0xA4 + x) = 2; RAM(0x0364 + x) = 2;
    }
}
static void ts_op_E8EE(uint8_t x) { RAM(0xA0 + x) = 2; RAM(0xD8 + x) = 1; ts_height_abs(x, 0x30); }
static void ts_op_E8FF(uint8_t x, uint8_t y) {
    if (RAM(0xB0 + x) != 0) return;
    uint8_t s = RAM(0xA4 + x);
    if (s != 0 && !((s >> 1) & 1)) return;
    RAM(0x01) = y;
    if (RAM(0x94 + x) != 0) {
        uint8_t yy = (RAM(0x5C + x) & 0x40) ? 3 : 4;
        RAM(0x036C + x) = 1;
        RiderDecelerateBy((Regs){ 0, x, (uint8_t)(yy + 2), 0 });
    }
}
static void ts_op_E956(uint8_t x) {
    if (RAM(0xA4 + x) != 1) return;
    RAM(0xBC + x) = 0;
    RiderStartJump((Regs){ 0, x, 0, 0 });
}
static void ts_op_E8BF(uint8_t x) { RAM(0xA4 + x) = 0; RAM(0xA0 + x) = 0; }
static void ts_op_E8C6(uint8_t x) { RAM(0xA4 + x) = 1; if (RAM(0xB8 + x) < 0x20) RAM(0xA4 + x) = 2; }
static void ts_op_E8FA(uint8_t x) { ts_height_abs(x, 0x10); }
static void ts_op_E8D3(uint8_t x) { if ((uint8_t)(x | RAM(0xB0 + x) | RAM(0x03E0) | RAM(0x3C)) == 0) RAM(0x03B6) = 8; }
static void ts_op_E8E7(uint8_t x) {
    if (RAM(0xB0 + x) != 0) return;
    if (RAM(0x98 + x) == 0) RAM(0x94 + x)++;
    RiderLaunchFromRest((Regs){ 0, x, 0, 0 });
}
static void ts_op_E8F5(uint8_t x) { ts_height_abs(x, 0x30); }

void TrackScriptOpcode(Regs r) {              /* $E794: A = opcode (0-20, not 17), X = rider */
    uint8_t x = r.x, op = (uint8_t)(r.a << 1);
    RAM(0x00) = ROMB(0xE6B7 + op); RAM(0x01) = ROMB(0xE6B8 + op);
    switch (op >> 1) {
    case 0: ts_op_E963(x); break;   case 1: ts_op_E8E3(x); break;   case 2: ts_op_E85D(x); break;
    case 3: ts_op_E86A(x); break;   case 4: ts_op_E845(x); break;   case 5: ts_op_E854(x); break;
    case 6: ts_op_E934(x); break;   case 7: ts_op_E818(x); break;   case 8: ts_op_EA8F(x); break;
    case 9: ts_op_E879(x); break;   case 10: ts_op_E89D(x); break;  case 11: ts_op_E8EE(x); break;
    case 12: ts_op_E8FF(x, op); break; case 13: ts_op_E956(x); break; case 14: ts_op_E8BF(x); break;
    case 15: ts_op_E8C6(x); break;  case 16: ts_op_E8FA(x); break;
    case 18: ts_op_E8D3(x); break;  case 19: ts_op_E8E7(x); break;  case 20: ts_op_E8F5(x); break;
    default: break;
    }
}

void RunPendingTrackScripts(void) {           /* $E927 */
    for (int i = 3; i >= 0; i--) {
        uint8_t x = (uint8_t)i;
        if (RAM(0xCC + x) != 0) TrackScriptOpcode((Regs){ RAM(0xCC + x), x, 0, 0 });
    }
}

void RunTrackScriptRider(Regs r) {            /* $E73B: advance one rider through the script of the piece it is on */
    uint8_t x = r.x, c = 0, a;
    RAM(0xC8 + x) = adc8(RAM(0x60 + x), RAM(0xC8 + x), &c);
    if (RAM(0x58 + x) == 0) {
        a = (uint8_t)(RAM(0xC0 + x) - 0x40);
        if (a & 0x80) return;
        a >>= 2;
        if (a >= 0x16) return;
        RAM(0x58 + x) = a + 1;
        RAM(0xC4 + x) = 0;
        RAM(0xC8 + x) = RAM(0x64 + x) - 1;
    }
    for (;;) {
        uint8_t idx = RAM(0x58 + x);
        RAM(0x0A) = ROMB(0xE559 + idx); RAM(0x0B) = ROMB(0xE56E + idx);
        uint16_t ptr = (uint16_t)(RAM(0x0A) | RAM(0x0B) << 8);
        uint8_t y = RAM(0xC4 + x);
        a = rd16mem((uint16_t)(ptr + y));
        if (a == 0xFF) {                        /* $E7D0: script finished */
            RAM(0x58 + x) = 0; RAM(0xD4 + x) = 0;
            if (RAM(0xA0 + x) == 0 && RAM(0xA4 + x) != 1) {
                RAM(0xBC + x) = 0;
                if (RAM(0xA4 + x) == 2) RAM(0xA4 + x)++;
            }
            RAM(0x036C + x) = 0;
            return;
        }
        RAM(0x0F) = a;
        if (a > RAM(0xC8 + x)) return;
        y++;
        a = rd16mem((uint16_t)(ptr + y));
        if (a & ROMB(0xE703)) {                 /* $E7A3: pitch command */
            if ((RAM(0xB0 + x) | RAM(0x98 + x)) == 0) {
                uint8_t v = rd16mem((uint16_t)(ptr + y)) & 0x0F;
                RAM(0x00) = v;
                if (RAM(0xA4 + x) != 1) {
                    RAM(0xAC + x) = v;
                    if (RAM(0x58 + x) != 3) RAM(0xD4 + x) = ROMB(0xE6AD + (uint8_t)(v - 2));
                }
            }
        } else if (a & ROMB(0xE6FB)) {           /* $E7F2: deferred command */
            RAM(0xCC + x) = a & 0x0F;
            RAM(0xD0 + x) = RAM(0x0F);
        } else {
            TrackScriptOpcode((Regs){ a, x, y, 0 });
        }
        RAM(0xC4 + x) += 2;
    }
}

void RunTrackScripts(void) {                  /* $E733 */
    for (uint8_t x = 3; x != 0; x--) RunTrackScriptRider((Regs){ 0, x, 0, 0 });
    RunTrackScriptRider((Regs){ 0, 0, 0, 0 });
}

/* ---- batch 10: sprite drawing into the OAM buffer, temperature gauge, rider overlap ---- */
#define OAM_AT(off) RAM(0x0200 + RAM(0x04) + (uint8_t)(off))     /* ($04),y with $05 = 2 */

void DrawMetasprite(Regs r) {                 /* $D1C7: A = blank-tile mask; $00 X, $01 Y, $02 first tile, $03 size (rows<<4|cols), $04 OAM offset, $0B attributes */
    uint8_t x, y, a, c = 0;
    RAM(0x0A) = r.a;
    RAM(0x05) = 2;
    RAM(0x07) = 0x0F & RAM(0x03);
    RAM(0x06) = RAM(0x03) >> 4;
    x = RAM(0x06); a = 0;
    do { a = adc8(a, RAM(0x07), &c); x--; } while (x != 0);
    RAM(0x08) = a;
    y = 1; x = 0;
    do {
        int write = 1;
        if (!(x & 1)) { uint8_t b = RAM(0x0A) & 1; RAM(0x0A) >>= 1; if (b) write = 0; }
        if (write) { OAM_AT(y) = RAM(0x02); RAM(0x02)++; } else OAM_AT(y) = 0xFC;
        y++; OAM_AT(y) = RAM(0x0B);
        y += 3; x++;
    } while (x != RAM(0x08));
    y = 0;
    do {
        x = RAM(0x06); RAM(0x09) = RAM(0x01);
        do {
            OAM_AT(y) = RAM(0x09); RAM(0x09) += 8;
            y += 3; OAM_AT(y) = RAM(0x00); y++;
            x--;
        } while (x != 0);
        RAM(0x00) += 8;
        RAM(0x07)--;
    } while (RAM(0x07) != 0);
}

void ClearSpriteBlock(Regs r) {               /* $E4AD: Y = block index, $07 = base offset: hides three sprites */
    RAM(0x01) = 2;
    RAM(0x00) = (uint8_t)(RAM(0x07) + ROMB(0xD8DC + r.y));
    for (uint8_t y = 0; y < 0x0C; y += 4) RAM(0x0200 + RAM(0x00) + y) = 0xF8;
}
void EraseRiderSpriteRange(void) {            /* $E49B */
    for (uint8_t x = 0; x < 3; x++)
        if (!(RAM(0x02 + x) & 1)) ClearSpriteBlock((Regs){ 0, 0, x, 0 });
}
void ErasePassedRiderSprites(void) {          /* $E456 */
    int8_t y = 3;
    do {
        RAM(0x05) = (uint8_t)y;
        RAM(0x07) = ROMB(0xD8C0 + y);
        uint8_t x = RAM(0x88 + y);
        if (x != 0) {
            uint8_t a = RAM(0x84 + x);
            RAM(0x02) = RAM(0x03) = RAM(0x04) = a;
            uint8_t lo = RAM(0x80 + x);
            if (!(a & 1) && lo >= 0x70 && lo < 0x90) {
                ClearRider((Regs){ 0, x, 0, 0 });
                RAM(0x03A6) = 1;
            } else {
                if (lo >= 0xF8) RAM(0x03)++;
                if (lo >= 0xF0) RAM(0x04)++;
            }
            EraseRiderSpriteRange();
        }
        y = (int8_t)(RAM(0x05) - 1);
    } while (y >= 0);
}

Regs RiderSpriteFrame(Regs r) {               /* $E1F9: returns the animation frame for a rider (also sets $0E and $039F) */
    uint8_t x = r.x, a, y;
    RAM(0x0E) = 0; RAM(0x039F) = 0;
    a = RAM(0x9C + x);
    if (a != 0 && a != 5) {
        y = 6;
        if (RAM(0xBC + x) != 0 || RAM(0x0370 + x) == 0) y = 2;
        a = y; y = RAM(0x36 + x);
        if (y != 0) { y--; a = y; }
        r.a = a | 0x10; return r;
    }
    if (RAM(0x52) == 1 && RAM(0xAC + x) == 0x0A) { RAM(0x0E) = 2; r.a = 0x0A; return r; }
    if ((RAM(0x98 + x) | RAM(0xB0 + x)) == 0) {
        a = RAM(0x58 + x);
        if (a == 0 || (a == 0x0D && RAM(0xB8 + x) >= 0x20)) {
            if ((RAM(0x90 + x) | RAM(0x94 + x)) == 0) { RAM(0x0E)++; }
            else if (RAM(0xAC + x) == 6) {
                y = 0x14; a = RAM(0xDC + x);
                if (a != 0) { if (a & 0x80) y++; r.a = y; return r; }
                if (RAM(0x3F) & 2) { r.a = 0x13; return r; }
            }
        }
    }
    r.a = RAM(0xAC + x); return r;
}

void DrawRider(Regs r) {                      /* $E1A3 */
    uint8_t x = r.x;
    RAM(0x00) = RAM(0x80 + x); RAM(0x01) = RAM(0x8C + x);
    uint8_t y = RiderSpriteFrame(r).a;
    RAM(0x02) = ROMB(0xD892 + y); RAM(0x03) = 0x33;
    if (y == 0x16) {
        RAM(0x039F) = RAM(0x04);
        RAM(0x04) += 0x0C; RAM(0x01) += 8; RAM(0x03) = 0x23;
    }
    DrawMetasprite((Regs){ ROMB(0xD8A9 + y), x, y, 0 });
    uint8_t a = RAM(0x0E);
    if (a == 0) return;
    if (!(a & 1)) {
        uint8_t t = 0xB2;
        for (int8_t yy = 0x11; yy >= 0; yy -= 4) {
            if (yy != 9) { OAM_AT(yy) = t; t--; }
        }
    } else OAM_AT(0x15) = 0xAE;
}

void DrawRiderShadow(Regs r) {                /* $E26A */
    uint8_t x = r.x, a;
    if (RAM(0x039F) == 0) return;
    if (RAM(0x84 + x) == 2) return;
    a = RAM(0x0390 + x);
    if (a >= 0xF8 || a < RAM(0x80 + x)) return;
    RAM(0x00) = a;
    RAM(0x01) = (uint8_t)(0xA8 - RAM(0x6C + x));
    RAM(0x03) = 0x22;
    RAM(0x04) = RAM(0x039F);
    a = RAM(0xA4 + x) ? 0x20 : 0;
    RAM(0x0B) = a | RAM(0x0B);
    uint8_t y = RAM(0x0398 + x);
    RAM(0x02) = ROMB(0xD90B + y);
    a = y ? (y ^ 3) : 0;
    DrawMetasprite((Regs){ a, x, y, 0 });
}

void DrawRiders(void) {                       /* $E17F: back to front by Y */
    SortRidersByY();
    for (int8_t x = 3; x >= 0; x--) {
        RAM(0x0D) = (uint8_t)x;
        RAM(0x04) = ROMB(0xD8C0 + x);
        uint8_t xx = RAM(0x88 + x);
        if (RAM(0xA8 + xx) != 0) {
            RAM(0x0B) = ROMB(0xD8C9 + xx);
            DrawRider((Regs){ 0, xx, 0, 0 });
            DrawRiderShadow((Regs){ 0, xx, 0, 0 });
        }
        x = (int8_t)RAM(0x0D);
    }
}

void DrawSkidSmoke(Regs r) {                  /* $E2F6: Y = OAM offset of the rider's smoke sprites */
    uint8_t x = r.x, y = r.y, a, c = 0;
    if (RAM(0x036C + x) == 0) return;
    if ((RAM(0x94 + x) | RAM(0x90 + x)) == 0) return;
    if (RAM(0xBC + x) != 0) return;
    if (!(RAM(0x84 + x) & 1)) return;
    a = RAM(0x80 + x);
    if (a < 0x10) return;
    c = 0; a = adc8(a, 0xF9, &c); RAM(0x0297 + y) = a;
    c = 0; a = adc8(a, 0xF8, &c); RAM(0x029B + y) = a;
    c = 0; a = adc8(RAM(0x8C + x), 8, &c); RAM(0x0298 + y) = a;
    c = 0; a = adc8(a, 8, &c); RAM(0x0294 + y) = a;
    RAM(0x0295 + y) = 0xF6; RAM(0x0299 + y) = 0xF7;
    if (RAM(0x3F) & 4) { RAM(0x0295 + y) = 0xF7; RAM(0x0299 + y) = 0xF6; }
    a = RAM(0x036C + x) & 2;
    RAM(0x0296 + y) = a; RAM(0x029A + y) = a;
    if (RAM(0x94 + x) == 0) RAM(0x0298 + y) = 0xF8;
}

void DrawJumpShadows(void) {                  /* $EA44: shadow under airborne riders near the right edge, or skid smoke */
    for (int8_t i = 3; i >= 0; i--) {
        uint8_t x = (uint8_t)i, y = (uint8_t)(x << 3), a = RAM(0x84 + x), draw = 0;
        if (a & 1) draw = RAM(0x80 + x) < 0xF4;
        else if (!((a >> 1) & 1)) draw = RAM(0x80 + x) >= 0xF6;
        if (draw && RAM(0xB0 + x) != 0) {
            uint8_t c = 0;
            RAM(0x0294 + y) = RiderBaseYFrom((Regs){ 0xB6, x, 0, 0 }).a;
            RAM(0x0297 + y) = adc8(RAM(0x80 + x), 0x0A, &c);
            RAM(0x01) = y;
            RAM(0x0295 + y) = ROMB(0xE69A + RAM(0xB4 + x));
            RAM(0x0296 + y) = 0;
        } else DrawSkidSmoke((Regs){ 0, x, y, 0 });
    }
}

void UpdateTempGauge(void) {                  /* $E359: turbo temperature: updates $03B5/$03B6 and draws the gauge sprites */
    uint8_t a, y = 0, c;
    if (RAM(0x52) != 0) { a = 0xFE; goto draw; }
    if (RAM(0x03E0) != 0) {
        if (RAM(0x3C) & 1) { a = 0xFE; goto draw; }
        a = 0xFC; goto draw;
    }
    a = RAM(0x5C) & 0xC0;
    if (a != 0) {
        if (RAM(0x4F) == 0) a = 0x80;
        c = a >> 7; a <<= 1;                                   /* ASL */
        { uint8_t n = a >> 7; a = (uint8_t)((a << 1) | c); c = n; }   /* ROL */
        { uint8_t n = a >> 7; a = (uint8_t)((a << 1) | c); c = n; }   /* ROL */
    }
    y = a;
    {
        uint8_t t = ROMB(0xD8FB + y), h = RAM(0x03B6);
        if (h < t) {
            c = 0; RAM(0x03B5) = adc8(RAM(0x03B5), ROMB(0xD8F7 + y), &c);
            if (c) RAM(0x03B6)++;
        } else if (h != t) {
            uint8_t v = RAM(0x03B5), nv = (uint8_t)(v - 0x0B);
            RAM(0x03B5) = nv;
            if (v < 0x0B && RAM(0x03B6) != 0) RAM(0x03B6)--;
        }
    }
    {
        uint8_t x = 0, h = RAM(0x03B6);
        if (h >= 0x20) { RAM(0x3C) = h; RAM(0x03E0) = h; }
        if (h >= 0x1A) { y--; if (y == 0) x = 0xB0; }
        RAM(0xFC) = x | RAM(0xFC);
    }
    a = 0xFE;
draw:
    RAM(0x01) = a;
    RAM(0x00) = (uint8_t)(RAM(0x03B6) + 0x50);
    for (int8_t x = 0x0C; x >= 0; x -= 4) {
        RAM(0x02F0 + x) = 0xCF; RAM(0x02F1 + x) = RAM(0x01);
        RAM(0x02F2 + x) = 0x20; RAM(0x02F3 + x) = RAM(0x00);
        RAM(0x00) += 8;
    }
}

static uint8_t ryo_z(uint8_t x, uint8_t y) {   /* Z flag RiderYOverlapTest leaves: set for the "far apart" result or a difference of exactly $EC */
    uint8_t d = (uint8_t)(RAM(0x8C + x) - RAM(0x8C + y));
    if (d >= 0xEC) return d == 0xEC;
    if (d < 0x12) return 0;
    return 1;
}
void DetectRiderOverlap(void) {               /* $E4C8: flags in $03A3 when two or more riders overlap on screen */
    uint8_t x = 1, y, a, n;
    for (;;) {
        RAM(0x0C) = x;
        a = RAM(0x84 + x);
        if ((a & 1) || ((a >> 1) == 0 && RAM(0x80 + x) >= 0xF8)) {
            RAM(0x0A) = 0;
            y = x + 1;
            do {
                RAM(0x05) = y;
                a = RAM(0x84 + y);
                if ((a & 1) || ((a >> 1) == 0 && RAM(0x80 + x) >= 0xF8)) {
                    if (!ryo_z(x, y)) {
                        RAM(0x0A)++;
                        RAM(0x0B) = (uint8_t)((RAM(0x0B) << 2) | RAM(0x05));
                    }
                }
                y++;
            } while (y < 4);
            n = RAM(0x0A);
            if (n >= 2) {
                if (n != 2) goto set1;
                uint8_t v = RAM(0x0B);
                if (!ryo_z((uint8_t)((v >> 2) & 3), (uint8_t)(v & 3))) goto set1;
            }
        }
        x = RAM(0x0C) - 1;
        if (x & 0x80) { RAM(0x03A3) = 0; return; }
    }
set1:
    RAM(0x03A3) = 1;
}

/* ---- batch 11: crash recovery, track edge, start-light animation ---- */
void RiderCrashUpdate(void) {                 /* $DDD1: tumbling riders slow down, then stand up */
    for (int8_t i = 3; i >= 0; i--) {
        uint8_t x = (uint8_t)i, y = 4;
        if (RAM(0x98 + x) == 0) continue;
        if (x == 0) {
            RAM(0x03A9) = 0; RAM(0xFC) = 0;
            if (RAM(0x4C) == 0) RAM(0xFD) = 1;
            y = RAM(0x1B) & 3;
        }
        RAM(0x03E4 + x) = y;
        if (RAM(0x4C) & 1) continue;
        if (RAM(0x94 + x) == 0) {
            if ((RAM(0xB0 + x) | RAM(0x58 + x)) == 0) {
                RAM(0x90 + x) = 0; RAM(0x60 + x) = 0; RAM(0x98 + x) = 0;
                RAM(0xAC + x) = 6;
                RAM(0x0390 + x) = RAM(0x80 + x) + 8;
                ComputeRiderShadowY((Regs){ 0, x, 0, 0 });
                RAM(0x0398 + x) = 2; RAM(0x9C + x) = 1;
                continue;
            }
            RAM(0x90 + x) = 0x88;
        }
        RAM(0xAC + x) = (uint8_t)((RAM(0xAC + x) + RAM(0x98 + x)) & 0x0F);
    }
}

void CheckTrackEdge(void) {                   /* $DEBB: tracks whether riders 1-3 are on the grass strip at the left edge */
    for (uint8_t x = 3; x != 0; x--) {
        if (!(RAM(0x84 + x) & 1)) continue;
        uint8_t lo = RAM(0x80 + x);
        if (lo >= 0x30 && lo < 0x40) RAM(0x03A9 + x) = 1;
        else if (RAM(0x03A9 + x) != 0) { RAM(0xFF) = 0x40; RAM(0x03A9 + x) = 0; }
    }
}

void UpdateExhaustSprites(void) {             /* $DE31: start-light countdown ($24) drawn with sprites at $02C0 */
    uint8_t a = RAM(0x24), y, c;
    if (a == 1) {
        RAM(0x4F) = 1;
        uint8_t v = RAM(0x03B4);
        RAM(0x03B4) = (uint8_t)(v - RAM(0x60));
        if (v < RAM(0x60)) return;
        RAM(0x24) = 2;
    } else {
        if (RAM(0x4F) != 0) return;
        if (a < 0x60 && RAM(0x03A9) != 0 && (RAM(0x5C) & 0xC0) != 0) RAM(0xFE) = 1;
    }
    a = RAM(0x24);                              /* $DE4E */
    y = 0xF0;
    if (a < 0x10) { y = 0xF2; if (a < 0x08) y = 0xF4; }
    if (a == 0x72) RAM(0xFB) = 0x20;
    RAM(0x00) = y; RAM(0x01) = RAM(0x03B4);
    for (int8_t i = 7; i >= 0; i--) {
        uint8_t yy = (uint8_t)i, x = (uint8_t)(yy << 2);
        RAM(0x02C0 + x) = ROMB(0xD8E7 + yy);
        RAM(0x02C1 + x) = RAM(0x00);
        RAM(0x02C2 + x) = 0;
        RAM(0x02C3 + x) = RAM(0x01);
        if (yy & 1) {
            RAM(0x02C1 + x)++;
            if (RAM(0x02C1 + x) != 0) continue;
        }
        c = RAM(0x01) < 0x10;
        RAM(0x01) = (uint8_t)(RAM(0x01) - 0x10);
        if (c) break;
    }
    if (RAM(0x34) != 0) RAM(0x24) = 0x88;
}

/* ---- batch 12: landing, rider collisions, obstacle hit, Y movement, state dispatch, menu cursor ---- */
void RiderLandingCheck(Regs r) {              /* $DC1A: an airborne rider touches down (or crashes if the pitch is wrong) */
    uint8_t x = r.x, a, y;
    if (RAM(0xB0 + x) == 0) return;
    a = RiderBaseY(r).a;
    RAM(0x01) = a;
    if (a >= RAM(0x8C + x)) return;
    if (RAM(0x8C + x) >= 0xA8) return;
    if (RAM(0x0364 + x) == 0) return;
    if (x == 0) RAM(0xFF) = 2;
    RAM(0xB0 + x) = 0; RAM(0x0364 + x) = 0;
    if (RAM(0x98 + x) == 0) {
        if (RAM(0x52) != 0) {                   /* $DC8E: race over, just level out */
            if (RAM(0xD4 + x) == 0) RAM(0xAC + x) = 6;
            return;
        }
        y = RAM(0x0388 + x); RAM(0x0388 + x) = 0;
        if (y == 0) {
            a = RAM(0xD4 + x);
            if ((int8_t)(RAM(0x94 + x) - 2) < 0) a += 8;
            y = a;
            uint8_t p = RAM(0xAC + x);
            if (p < ROMB(0xD86C + y) || p >= ROMB(0xD87C + y)) { RAM(0x98 + x) = 0xFF; return; }
            if (RAM(0x0368 + x) != p && (RAM(0xD4 + x) | RAM(0xCC + x)) == 0) {
                RAM(0x0374 + x) = 4; RAM(0x0388 + x) = 2; RAM(0xB0 + x) = 1;
            }
        }
    }
    RAM(0x01)--;                                /* $DC87 */
    RAM(0x8C + x) = RAM(0x01);
}

void RiderCollisions(void) {                  /* $DFD5: rider-vs-rider contact; crashes the rider on the left and the other */
    uint8_t x = 0, y = 1, a, ax, ay, lx, ly;
    for (;;) {
        if (RAM(0xA8 + x) == 0) goto next_x;
        for (;;) {
            if (RAM(0xA8 + y) == 0) goto next_y;
            if (!(RAM(0x84 + x) & 1)) goto next_x;
            if (!(RAM(0x84 + y) & 1)) goto next_y;
            a = RAM(0x70 + x);
            if (a == 0) goto next_x;
            if (a != RAM(0x70 + y)) goto next_y;
            if ((RAM(0x98 + x) | RAM(0x03E0 + x)) != 0) goto next_x;
            if (RAM(0x98 + y) != 0) goto next_y;
            if (RAM(0xB0 + x) != 0 || RAM(0xB0 + y) != 0) {
                ax = RAM(0x8C + x); ay = RAM(0x8C + y);
                if (ax >= ay) {
                    if (AddCollisionHeight((Regs){ ay, 0, 0, 0 }).a < ax) goto next_y;
                } else {
                    if (AddCollisionHeight((Regs){ ax, 0, 0, 0 }).a < ay) goto next_y;
                }
            }
            lx = RAM(0x80 + x); ly = RAM(0x80 + y);
            if (lx < ly) {
                if (AddCollisionWidth((Regs){ lx, 0, 0, 0 }).a >= ly) goto e061;
                if (AddCollisionHeight((Regs){ lx, 0, 0, 0 }).a >= ly) goto e05b;
                goto next_y;
            } else {
                if (AddCollisionWidth((Regs){ ly, 0, 0, 0 }).a >= lx) goto e061;
                if (AddCollisionHeight((Regs){ ly, 0, 0, 0 }).a >= lx) goto e065;
                goto next_y;
            }
        e05b: RAM(0x98 + x) = 0xFF; goto e076;
        e061: RAM(0x98 + x) = 0xFF;
        e065: if (x == 0 && y == 3) RAM(0x3B) = 0x10;
            RAM(0x98 + y) = 0xFF;
        e076: if (x == 0) RAM(0xFD) = 1;
        next_y:
            y++;
            if (y == 4) break;
        }
    next_x:
        x++; y = x + 1;
        if (x == 3) return;
    }
}

void BikeVsObstacleCheck(void) {              /* $E09F: rider 0 hits the obstacle sprite at $0393 */
    uint8_t a;
    if (RAM(0x9C) != 0) return;
    if (!(RAM(0x87) & 1)) return;
    if (RAM(0x0373) == 0) return;
    a = (uint8_t)(RAM(0xB8) - 3);
    if (a >= RAM(0x6F)) return;
    a += 7;
    if (a < RAM(0x6F)) return;
    a = RAM(0x80);
    if (a >= RAM(0x0393)) return;
    a += 0x12;
    if (a < RAM(0x0393)) return;
    a = (uint8_t)(RiderBaseY((Regs){ 0, 0, 0, 0 }).a - 8);
    if (a >= RAM(0x8C)) return;
    RAM(0x98) = 0xFF; RAM(0xDF) = 0; RAM(0x9F) = 1; RAM(0xFD) = 1; RAM(0x039B) = 2;
}

void UpdateRiderGroundDistance(void) {        /* $E836 */
    for (int8_t i = 3; i >= 0; i--)
        if (RAM(0xB0 + i) == 0) RAM(0x8C + i) = RiderBaseY((Regs){ 0, (uint8_t)i, 0, 0 }).a;
}

void UpdateRiderY(void) {                     /* $E96C: lane change movement, ramps and screen limits for each rider, then rider 0 steering */
    uint8_t a;
    for (int8_t i = 3; i >= 0; i--) {
        uint8_t x = (uint8_t)i, y;
        a = RAM(0x58 + x);
        if (a != 0x15 && a != 0x14) RAM(0xB8 + x) += RAM(0xDC + x);
        for (y = 0; y < 4; y++) if (RAM(0xB8 + x) == ROMB(0xE53D + y)) break;
        if (y < 4) { RAM(0xDC + x) = 0; continue; }
        a = RAM(0xA4 + x);
        if (a != 0) {
            if (a == 1) {
                if (RAM(0xB8 + x) < 0x20) {
                    RAM(0xA4 + x) = 4;
                    a = RAM(0x58 + x);
                    if (a == 0 || a == 0x12 || a == 0x10 || a == 0x0D) {
                        RAM(0xBC + x) = 0;
                        RiderStartJump((Regs){ 0, x, 0, 0 });
                        RAM(0xA4 + x)--;
                    }
                    continue;
                }
            } else if (a != 3 && RAM(0xB8 + x) >= 0x20) RAM(0xB8 + x)--;
        }
        a = RAM(0xB8 + x);                      /* $E9C4 */
        if (a < 8) {
            if (RAM(0x9C + x) == 0) a = 7;
            else { a = RAM(0xB8 + x); if (a < 2) a = 1; }
            RAM(0xB8 + x) = a;
            if (x != 0) goto e9d2;
            goto e9d9;
        }
        if (a < 0x3A) continue;
        RAM(0xB8 + x) = 0x39;
    e9d2:
        if ((RAM(0x9C + x) | RAM(0x03E0 + x)) != 0) continue;
    e9d9:
        a = RAM(0xDC + x);
        if (a == 0) a = 0xFF;
        RAM(0xDC + x) = a ^ 0xFE;
    }
    if (RAM(0x4F) == 0) return;
    if ((RAM(0x98) | RAM(0x03E0) | RAM(0x03F7)) != 0) return;
    if (RAM(0xB0) != 0) { if (RAM(0x0388) != 2) return; RAM(0x0388)++; }
    a = RAM(0x9C);
    if (a != 0 && a != 5) return;
    a = RAM(0x14) & 0x0C;
    if (a == 0) return;
    RAM(0xDC) = (a & 4) ? 0xFF : 1;
    RAM(0xFD) |= 4;
}

void RiderStateDispatch(Regs r) {             /* $D924: runs the handler for the rider's state (0 = racing, 1-5 = start/finish sequence) */
    uint8_t x = r.x, y = RAM(0x9C + x);
    RAM(0x00) = ROMB(0xD8FF + y); RAM(0x01) = ROMB(0xD905 + y);
    switch (y) {
    case 1: RiderState1Gate(r); break;
    case 2: RiderState2MoveToLane(r); break;
    case 3: RiderState3Wait(r); break;
    case 4: RiderState4Release(r); break;
    case 5: RiderState5Finish(r); break;
    default: break;
    }
}
void UpdateRiderStates(void) {                /* $D918 */
    for (int8_t i = 3; i >= 0; i--) {
        Regs q = { 0, (uint8_t)i, 0, 0 };
        RiderStateDispatch(q);
        ComputeRiderShadowY(q);
    }
}

Regs MenuHandleInput(Regs r) {                /* $C7DE: A = number of items; moves $42 with the d-pad. Returns X = 4 for a button press, Y = cursor */
    uint8_t y = RAM(0x42), a, xo = 0, y0 = y;
    RAM(0x00) = r.a;
    a = RAM(0x15) & 0x3C;
    if (a == 0) { RAM(0x49) = 0; return (Regs){ 0, 0, y0, r.c }; }
    RAM(0x31) = 0x5D;
    if (RAM(0x49) != 0) return (Regs){ 0, 0, y0, r.c };
    a = RAM(0x15);
    int step = 0;                                /* 1 = down, 2 = up */
    if (a & ROMB(0xC0CE)) step = 1;
    else if ((a >> 2) & 1) step = 1;
    else if ((a >> 3) & 1) step = 2;
    else { RAM(0x30) = 4; xo = 4; goto store; }
    if (step == 1) { y++; if (y >= RAM(0x00)) y = 1; else goto beep; }
    y--;
    if (y & 0x80) y = (uint8_t)(RAM(0x00) - 1);
beep:
    RAM(0xFF) = 1;
store:
    RAM(0x42) = y;
    RAM(0x49)++;
    return (Regs){ 0, xo, y, r.c };
}

/* ---- batch 13: overheating, race end, game-state advance ---- */
void GameStateClearSteps(void) { RAM(0x40) = 0; RAM(0x44) = 0; }          /* $C3B1 */
void GameStateAdvance(void) { RAM(0x41)++; GameStateClearSteps(); }       /* $C3AF */

void HudSpriteTemplate(void) {                /* $CD13: copies the 8-byte template to sprite slots $02C0 */
    for (int8_t x = 7; x >= 0; x--) RAM(0x02C0 + x) = ROMB(0xC150 + x);
}
void OverheatMessage(void) {                  /* $CCDD: flashing "overheat" letters while $3C is odd */
    if (!(RAM(0x3C) & 1)) return;
    RAM(0xFB) = 0x40;
    RAM(0x00) = 0x58;
    for (int8_t x = 8; x >= 0; x--) {
        uint8_t y = (uint8_t)(x << 2);
        RAM(0x02C0 + y) = 0x44;
        RAM(0x02C1 + y) = ROMB(0xC147 + x);
        RAM(0x02C2 + y) = 0;
        RAM(0x02C3 + y) = RAM(0x00);
        RAM(0x00) += 0x0A;
    }
    RAM(0x02D0) = 0xF8;
}
void OverheatUpdate(void) {                   /* $DD8D: engine overheat stall for rider 0 */
    uint8_t a = RAM(0x3C);
    if ((a | RAM(0x03E0)) == 0) return;
    if (a == 8) { RAM(0x03E0) = 0; RAM(0x03B6) = 5; RAM(0x9C) = 5; RAM(0x0374) = 5; HudSpriteTemplate(); return; }
    if (a < 8) { HudSpriteTemplate(); return; }
    if ((RAM(0x94) | RAM(0x98) | RAM(0x9C)) == 0) {
        if (RAM(0x58) != 0) RAM(0x90) = 0xC0;
        else { RAM(0x90) = 0; RAM(0xDC) = (RAM(0xB8) == ROMB(0xD8C4)) ? 0 : 1; }
    }
    OverheatMessage();
}

void RaceEndSequence(void) {                  /* $CA9B: end-of-race flashing and screen advance */
    uint8_t a, y, x;
    if (RAM(0x32) == 0) {
        GameStateAdvance();
        if (RAM(0x03F7) != 0) { ResetGameRam(); return; }
        RAM(0x47) = 0; return;
    }
    RAM(0xFC) = 0; RAM(0x03A9) = 0; RAM(0x03E0) = 0; RAM(0x3C) = 0;
    if ((uint8_t)(RAM(0x52) - 1) != 0) return;
    a = RAM(0x3F);
    if (!(a & 1) && !(a & 2)) {
        y = (a >> 2) & 3;
        RAM(0x0312) = 0x3F; RAM(0x0313) = 0; RAM(0x0319) = 0; RAM(0x0314) = 4;
        RAM(0x0316) = ROMB(0xC166 + y); RAM(0x0318) = ROMB(0xC170 + y);
        y = RAM(0x43);
        RAM(0x0315) = ROMB(0xC160 + y); RAM(0x0317) = ROMB(0xC16A + y);
        return;
    }
    x = 0x11;
    if (RAM(0x32) & 1) return;
    for (int8_t n = 6; n >= 0; n--) RAM(0x0304 + x++) = 0xFE;
}

/* ---- batch 14: results screen ---- */
void WriteTimeTextHeader(void) {              /* $C94B: queues the PPU text block header for a time line (type in $03) */
    uint8_t x = AdvanceBufferPos((Regs){ 0x0A, 0, 0, 0 }).x, y = RAM(0x03);
    RAM(0x0301 + x) = ROMB(0xC0EC + y);
    RAM(0x0302 + x) = ROMB(0xC0ED + y);
    RAM(0x0305 + x) = 0xFB; RAM(0x0308 + x) = 0xFB;
    RAM(0x0303 + x) = 0x07;
    RAM(0x030B + x) = 0x00;
}
void WriteTimeDigitsToBuffer(void) {          /* $C935 */
    SplitDigits3((Regs){ 0, 5, 0, 0 });
    uint8_t x = RAM(0x0300);
    for (uint8_t y = 0; y < 7; y++) RAM(0x0304 + x++) = RAM(0x03D1 + y);
    WriteTimeTextHeader();
}

void ResultsDrawLine(Regs r) {                /* $CCCA: one result sprite block; X = row */
    uint8_t x = r.x;
    RAM(0x00) = ROMB(0xC0DA + x);
    RAM(0x03) = 0x21;
    RAM(0x04) = ROMB(0xC0E8 + x);
    DrawMetasprite((Regs){ 0, x, r.y, 0 });
}

static void results_next_step(uint8_t a) { RAM(0x33) = a; RAM(0x44)++; }                 /* $CB9F */

void ResultsStepInit(void) {                  /* $CB3B */
    if (RAM(0x41) < 8) {
        RAM(0x42) = RAM(0x03F2);
        if (RAM(0x53) < 4) {
            if (RAM(0x46) != 0) {
                uint8_t t = RAM(0x43);
                if (t == 4) {
                    RAM(0x03F3)++;
                    if (!(RAM(0x03F3) & 1)) {
                        uint8_t a = RAM(0x03F8) >> 1;
                        if (a != 0) RAM(0x03F8) = a;
                    }
                } else if (t < 4) RAM(0x43)++;
            }
            RAM(0x46) = 1; RAM(0x4B) = 1;
        }
    }
    results_next_step(4);
}

void ResultsStepDrawText(void) {              /* $CB77 */
    uint8_t y = RAM(0x33), x, a;
    if (y != 0) return;
    RAM(0x03) = 4;
    x = RAM(0x0300);
    for (y = 0; y != 7; y++) RAM(0x0304 + x++) = RAM(0x03D9 + y);
    WriteTimeTextHeader();
    a = RAM(0x4B) ? 0x20 : 0x31;
    RAM(0x03AD) = a;
    results_next_step((uint8_t)(a + 3));
}

Regs ResultsDrawRank(Regs r) {                /* $CC15: blinking rank number; returns the 6502 carry in .c */
    uint8_t a = (uint8_t)(RAM(0x03AD) - 0x10), c = a >= RAM(0x33);
    if (a == RAM(0x33) && RAM(0x20) == 0) {
        a = 0x0D;
        if ((uint8_t)(RAM(0x52) - 1) == 0) { c = 0; a = adc8(RAM(0x4B), 0x0B, &c); }
        RAM(0x45) = a; r.c = c; return r;
    }
    Regs q = AdvanceBufferPos((Regs){ 7, 0, 0, 0 });
    uint8_t x = q.x, y0 = x;
    c = q.c;
    RAM(0x05) = x;
    for (int8_t y = 7; y >= 0; y--) RAM(0x0301 + x++) = ROMB(0xC134 + y);
    if (RAM(0x3F) & 0x10) { r.c = c; return r; }
    y0 = RAM(0x05);
    q = DivMod10((Regs){ RAM(0x53), 0, 0, 0 });
    RAM(0x0307 + y0) = q.a;
    q = DivMod10((Regs){ q.x, 0, 0, 0 });
    c = q.c;
    RAM(0x00) = q.a;
    if (q.x != 0) { RAM(0x0305 + y0) = q.x; RAM(0x0306 + y0) = RAM(0x00); }
    else if (RAM(0x00) != 0) RAM(0x0306 + y0) = RAM(0x00);
    r.c = c; return r;
}

void ResultsStepFinish(void) {                /* $CC6B */
    GameStateAdvance();
    if (RAM(0x4B) != 0) return;
    RAM(0x41) = (RAM(0x41) < 9) ? 0 : 8;
}

static void results_tail(uint8_t c) {         /* $CC7D: draws the result marker and animates it with the jump-arc routine */
    uint8_t y;
    RAM(0x01) = RAM(0x55);
    if (RAM(0x56) != 0) y = 0xBB;
    else if (RAM(0x2F) != 0) {
        RAM(0x0380) = 0x1F; RAM(0x038C) = 0x1F; RAM(0x0378) = 0xAF; RAM(0x037C) = 1; RAM(0x0384) = 0;
        y = 0xBD;
    } else {
        Regs q = JumpArcStep((Regs){ 0, 0, 0, c });
        RAM(0x55) = q.a; RAM(0x01) = q.a;
        if (RAM(0x03F1) < RAM(0x55)) { RAM(0x55) = RAM(0x03F1); RAM(0x2F) = 0x0A; }
        y = 0xBB;
    }
    RAM(0x02) = y;
    uint8_t x = (uint8_t)(RAM(0x53) - 1);
    if (x >= 3) x = 3;
    RAM(0x0B) = 2;
    ResultsDrawLine((Regs){ 0, x, 0, 0 });
}

void ResultsStepWait(void) {                  /* $CBA4 */
    uint8_t a = RAM(0x33);
    if (a == 0) { results_next_step(0); return; }
    if (a == RAM(0x03AD)) {                     /* $CBC9: final pose */
        if (RAM(0x20) != 0) return;
        RAM(0x2F) = 3; RAM(0x0D) = 3;
        for (int8_t x = 2; x >= 0; x--) {
            RAM(0x01) = ROMB(0xC0DE + x); RAM(0x02) = ROMB(0xC0E2 + x); RAM(0x0B) = ROMB(0xC0E5 + x);
            ResultsDrawLine((Regs){ 0, (uint8_t)x, 0, 0 });
        }
        uint8_t m = 1, x = (uint8_t)(RAM(0x53) - 1);
        RAM(0x00) = x;
        if (x < 3) { RAM(0x0D) = x; m = 2; }
        RAM(0xFB) = m; RAM(0x56) = m ^ 2;
        x = RAM(0x0D);
        RAM(0x54) = ROMB(0xC0DA + x); RAM(0x55) = ROMB(0xC0DE + x); RAM(0x03F1) = RAM(0x55);
        if (RAM(0x00) == 0) RAM(0x45) = 0x0A;
        return;
    }
    if (a > RAM(0x03AD)) return;
    if (RAM(0x4B) == 0 && (RAM(0x14) & 0xF0) != 0) {
        ResultsStepFinish();
        if (RAM(0x41) != 0) return;
        GameStateAdvance();
        return;
    }
    Regs q = ResultsDrawRank((Regs){ 0, 0, 0, 0 });
    results_tail(q.c);
}

void StateSubStepDispatch(void) {             /* $CB2C: results sub-steps 0-3 */
    uint8_t y = RAM(0x44);
    RAM(0x00) = ROMB(0xC12C + y); RAM(0x01) = ROMB(0xC130 + y);
    switch (y) {
    case 0: ResultsStepInit(); break;
    case 1: ResultsStepDrawText(); break;
    case 2: ResultsStepWait(); break;
    case 3: ResultsStepFinish(); break;
    default: break;
    }
}

/* ---- batch 15: menus, best-time tables, race result ---- */
void LoadBestTime(void) {                     /* $C522: built-in record for the current track -> $05-$07 */
    RAM(0x02) = RAM(0x43);
    uint8_t y = TimeTableIndexForTrack((Regs){ 0, 0, 0, 0 }).a;
    RAM(0x05) = ROMB(0xC091 + y); RAM(0x06) = ROMB(0xC092 + y); RAM(0x07) = ROMB(0xC093 + y);
}
void LoadSavedTimeForIndex(void) {            /* $C53E: saved best time for track $02 -> $05-$07 */
    uint8_t y = TimeTableIndexForSelection((Regs){ 0, 0, 0, 0 }).y;
    RAM(0x05) = RAM(0x0580 + y); RAM(0x06) = RAM(0x0581 + y); RAM(0x07) = RAM(0x0582 + y);
}
void LoadSavedTime(void) { RAM(0x02) = RAM(0x43); LoadSavedTimeForIndex(); }   /* $C53A */
void WriteTimeTextSaved(Regs r) {             /* $C92C: A = text type; writes the saved time of the current track to the PPU buffer */
    RAM(0x02) = RAM(0x43); RAM(0x03) = r.a;
    LoadSavedTimeForIndex();
    WriteTimeDigitsToBuffer();
}

static void menu_cursor_tail(uint8_t a) { RAM(0x0203) = a; RAM(0x0202) = 0; RAM(0x46) = 0; }   /* $C411 */
void SetMenuCursorSprite(Regs r) { RAM(0x0201) = 0xFA; menu_cursor_tail(ROMB(0xC088 + r.y)); }  /* $C409 */

void StateMenuChoice6(void) {                 /* $C3BD */
    Regs q = MenuHandleInput((Regs){ 6, 0, 0, 0 });
    if (q.x == 0) { RAM(0x0200) = ROMB(0xC08B + RAM(0x42)); return; }
    uint8_t a = RAM(0x42);
    if (a == 2) { GameStateAdvance(); return; }
    if (a > 2) {
        if (a == 5) { RAM(0x42) = a >> 1; ResetGameRam(); return; }
        RAM(0x41) = (uint8_t)(a + 9); RAM(0x42) = 0; GameStateClearSteps(); return;
    }
    RAM(0x03F2) = a; RAM(0x41)++; GameStateAdvance();
}
void StateMenuChoice5(void) {                 /* $C395 */
    uint8_t t = RAM(0x15) & 0xF3;
    t |= (uint8_t)((t & 3) << 2);
    RAM(0x15) = t;
    Regs q = MenuHandleInput((Regs){ 5, 0, 0, 0 });
    if (q.x == 0) {
        uint8_t a = ROMB(0xC083 + q.y);
        if (a != 0) { menu_cursor_tail(a); return; }
        StateMenuChoice6(); return;
    }
    RAM(0x43) = RAM(0x42);
    GameStateAdvance();
}

void ComputeRaceResult(void) {                /* $C485: place/record from the finish time $68-$6A; stores $53 and queues the result screen */
    uint8_t a, y, c, i, k;
    LoadSavedTime();
    for (i = 0; i < 3; i++) if (RAM(0x05 + i) != RAM(0x68 + i)) break;
    if (i == 3) { a = 1; goto done; }
    if (RAM(0x05 + i) >= RAM(0x68 + i)) {
        y = TimeTableIndexForSelection((Regs){ 0, 0, 0, 0 }).y;      /* LoadSavedTime left Y = table slot */
        for (k = 0; k < 3; k++) RAM(0x0580 + y++) = RAM(0x68 + k);
        a = 1; goto done;
    }
    if (RAM(0x41) < 8) {
        LoadBestTime();
        for (i = 0; i < 3; i++) if (RAM(0x05 + i) != RAM(0x68 + i)) break;
        if (i == 3 || RAM(0x05 + i) >= RAM(0x68 + i)) { a = 2; goto done; }
    }
    RAM(0x0A) = RAM(0x03F8);
    RAM(0x09) = (uint8_t)(RAM(0x0A) << 1);
    y = (uint8_t)(RAM(0x68) - RAM(0x05));
    a = 0;
    for (;;) {
        y--;
        if (y & 0x80) break;
        c = 0; a = adc8(a, 0x3C, &c);
        if (c) { a = 0xFF; goto scale; }
    }
    RAM(0x08) = a;
    {
        uint8_t v = RAM(0x69), s = RAM(0x06);
        c = v >= s; a = (uint8_t)(v - s);
        uint8_t cc = 0; a = adc8(a, RAM(0x08), &cc);
        if (c && cc) { a = 0xFF; goto scale; }
    }
    if (a < RAM(0x09)) {
        c = 0; a = adc8(a, RAM(0x09), &c);
        for (;;) {
            RAM(0x0A) >>= 1;
            if (RAM(0x0A) == 0) goto done;
            a >>= 1;
        }
    }
scale:
    a = (uint8_t)(((uint8_t)(a - RAM(0x09)) >> 1) + 4);
done:
    RAM(0x53) = a; RAM(0x45) = 0x18; RAM(0x49) = 1; RAM(0x40) = 1; RAM(0x44) = 0;
}
