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
