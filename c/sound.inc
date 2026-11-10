/* Sound engine, hand-written parts. The rest of the engine (pulse 1 and 2/triangle effects and the music player) is the mechanical lift in
 * auto_sound.inc; pieces move here as they are rewritten, each proved equal to the original by tools/difftest.py (V_SoundUpdate, V_SoundNoiseSfx).
 *
 * Sound state (RAM): $F0 pulse-1 effect running, $F1 pulse-2 effect running, $F2 noise effect running, $F3 engine pitch step, $F4 music playing,
 * $07F6/$07F7 noise effect step and loop request, $07FF DMC volume ramp. Requests arrive as one-shot bytes: $FB music, $FC engine, $FD noise,
 * $FE pulse 2, $FF pulse 1; SoundUpdate clears them after one pass. */
#define SND_NOISE_VOL 0x400C
#define SND_NOISE_LO  0x400E
#define SND_NOISE_HI  0x400F

static uint8_t take_request_bit(uint16_t addr) { uint8_t c = RAM(addr) & 1; RAM(addr) >>= 1; return c; }   /* LSR on the request byte: the code consumes its bits */

/* Noise channel effects. Three effects, each with a start and a "continue each frame" entry:
 *   0 (request bit 0): rumble that fades along $FB76/$FBA4 (0x2E steps), can chain into effect 1
 *   1 (request bit 1): short hit; volume envelope from $FBD3
 *   2 (request bit 2): decay from $FBF2 (12 steps) */
static void SoundNoiseSfx(void) {                       /* $FC3D */
    enum { E0_START, E0_RUN, E1_START, E1_RUN, E2_RUN, E2_START, TAIL } at;
    uint8_t y, a, step, c;
restart:
    y = RAM(0xFD); a = RAM(0xF2);
    if (take_request_bit(0xFD)) at = E0_START;
    else {
        c = a & 1; a >>= 1;
        if (c) at = E0_RUN;
        else if (take_request_bit(0xFD)) at = E1_START;
        else {
            c = a & 1; a >>= 1;
            if (c) at = E1_RUN;
            else {
                c = a & 1; a >>= 1;
                if (c) at = E2_RUN;
                else if (take_request_bit(0xFD)) at = E2_START;
                else return;
            }
        }
    }
    switch (at) {
    case E0_START: RAM(0xF2) = y; RAM(0x07F6) = 0x2E; /* fall through */
    case E0_RUN:
        if (y != 0) RAM(0x07F7) = y & 2;
        step = RAM(0x07F6);
        WR(SND_NOISE_VOL, ROMB(0xFB76 + step));
        WR(SND_NOISE_LO, ROMB(0xFBA4 + step));
        if (ROMB(0xFBA4 + step) == 0) { y = step; goto e1_start; }    /* a zero entry ends the rumble and starts effect 1 (the step is now in Y) */
        goto tail;
    case E1_START:
    e1_start:
        RAM(0xF2) = y; RAM(0x07F6) = 0; RAM(0x07F7) = 0;
        WR(SND_NOISE_LO, 0x0E);
        /* fall through */
    case E1_RUN:
        a = ROMB(0xFBD3 + (RAM(0x07F6) >> 3));
        WR(SND_NOISE_VOL, a);
        if (a == 0) goto restart;                        /* silent entry: the original falls back into the start of this routine */
        goto tail;
    case E2_START: RAM(0xF2) = y; RAM(0x07F6) = 0x0C; WR(SND_NOISE_LO, 0x0D); /* fall through */
    case E2_RUN:
        step = RAM(0x07F6);
        WR(SND_NOISE_VOL, ROMB(0xFBF2 + step));
        if (step == 8) WR(SND_NOISE_LO, 0x0E);
        goto tail;
    default: break;
    }
tail:                                                    /* $FC75: trigger the channel, advance the step; at the end start the queued effect or stop */
    WR(SND_NOISE_HI, 0x08);
    RAM(0x07F6)--;
    if (RAM(0x07F6) != 0) return;
    y = RAM(0x07F7);
    if (y != 0) goto e1_start;
    RAM(0xF2) = 0;
}

/* Pulse 2 and triangle pitch. Input registers: A = pitch number (top 3 bits = octave, low 5 bits = step within it), X = pulse 2 volume/duty,
 * Y = pulse 2 sweep. The period is $7FF shifted down by the octave, then reduced by the step bits one shifted-copy at a time (a table-free
 * semitone approximation). The triangle plays the same note an octave... one and a half times the period lower, unless a pulse effect is running. */
static void SetPulse2Pitch(void) {                      /* $FAF7 */
    uint8_t note = ra, hi, lo, x, y, t, c;
    WR(0x4004, rx); WR(0x4005, ry);
    RAM(0x07F9) = note;
    RAM(0x00) = hi = 0x07; RAM(0x01) = lo = 0xFF;
    for (int n = note >> 5; n > 0; n--) { lo = (uint8_t)((lo >> 1) | ((hi & 1) << 7)); hi >>= 1; }
    RAM(0x00) = hi; RAM(0x01) = lo;
    c = hi & 1; x = hi >> 1; y = (uint8_t)((lo >> 1) | (c << 7));
    t = (uint8_t)(note << 3); RAM(0x07F9) = t;
    do {
        c = x & 1; x >>= 1; y = (uint8_t)((y >> 1) | (c << 7));          /* x:y = x:y / 2 */
        c = t >> 7; t = (uint8_t)(t << 1); RAM(0x07F9) = t;
        if (c) {                                         /* this step bit is set: period -= x:y */
            uint8_t l = RAM(0x01), h = RAM(0x00);
            uint8_t borrow = l < y;
            RAM(0x01) = (uint8_t)(l - y);
            RAM(0x00) = (uint8_t)(h - x - borrow);
        }
    } while (t != 0);
    WR(0x4006, RAM(0x01));
    WR(0x4007, RAM(0x00));
    if (RAM(0xF1) == 0 && (RAM(0xF7) | RAM(0xFA)) != 0) return;
    {
        uint8_t h2, l2, c2, sum, hsum;
        c2 = RAM(0x00) & 1; RAM(0x00) >>= 1;
        RAM(0x01) = (uint8_t)((RAM(0x01) >> 1) | (c2 << 7));              /* period / 2 */
        h2 = RAM(0x00) >> 1; c2 = RAM(0x00) & 1;
        l2 = (uint8_t)((RAM(0x01) >> 1) | (c2 << 7));                     /* period / 4 */
        sum = (uint8_t)(l2 + RAM(0x01)); c = (unsigned)l2 + RAM(0x01) > 0xFF;
        hsum = (uint8_t)(h2 + RAM(0x00) + c);
        WR(0x400A, sum);
        WR(0x400B, hsum);
        WR(0x4008, 0x04);
    }
}

static void SoundUpdate(void) {                         /* $F844: runs every NMI */
    ra = 0xC0; SETNZ(ra);                                /* the original loads A with $C0 and keeps it: the pulse routines below read A on entry */
    WR(0x4017, ra);
    SoundPulse1Sfx();
    SoundPulse2TriangleSfx();
    SoundNoiseSfx();
    SoundMusic();
    RAM(0xFF) = 0; RAM(0xFE) = 0; RAM(0xFD) = 0; RAM(0xFB) = 0;      /* the requests last one pass */
    if (RAM(0x07FF) != 0) { WR(0x4011, RAM(0x07FF)); RAM(0x07FF)--; }  /* DMC volume ramp */
}
void V_SoundUpdate(Regs r) { ra = r.a; rx = r.x; ry = r.y; fc = r.c; SoundUpdate(); }
void V_SoundNoiseSfx(Regs r) { ra = r.a; rx = r.x; ry = r.y; fc = r.c; SoundNoiseSfx(); }
void V_SetPulse2Pitch(Regs r) { ra = r.a; rx = r.x; ry = r.y; fc = r.c; SetPulse2Pitch(); }
