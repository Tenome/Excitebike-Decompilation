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
