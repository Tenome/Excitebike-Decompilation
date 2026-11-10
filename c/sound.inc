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

/* Note output. A = pitch index (even numbers 0-$3E): the period comes from two tables ($FF01 low byte, $FF00 high byte + length trigger).
 * A zero low byte means a rest: nothing is written and Z stays set (the callers test it). The channel is selected by the register offset
 * (0 = pulse 1 at $4002, 4 = pulse 2 at $4006, 8 = triangle at $400A). The table addresses are 16-bit sums, so large indices wrap into RAM. */
static void play_note_on(uint8_t chan) {
    uint8_t idx = ra;
    rx = chan; ry = idx;
    ra = rd16mem((uint16_t)(0xFF01 + idx)); SETNZ(ra);
    if (ra == 0) return;
    WR((uint16_t)(0x4002 + chan), ra);
    ra = (uint8_t)(rd16mem((uint16_t)(0xFF00 + idx)) | 0x08); SETNZ(ra);
    WR((uint16_t)(0x4003 + chan), ra);
}
static void PlayPulse1Note(void) { play_note_on(0); }                    /* $F871 */
static void PlayPulse2Note(void) { play_note_on(4); }                    /* $F885 */
static void PlayTriangleNote(void) { play_note_on(8); }                  /* $F889 */
static void SetPulse1Regs(void) { WR(0x4000, rx); WR(0x4001, ry); PlayPulse1Note(); }   /* $F86B: X = volume/duty, Y = sweep, then the note in A */

/* Music player. Songs are streams of one-byte notes in ROM; the byte holds the pitch (bits 1-5) and a length class (bit 0 and bits 6-7)
 * that is turned into a frame count through a table, offset by the song's tempo ($07F0). Four voices share one stream pointer ($F8/$F9):
 * pulse 1 (melody, index $07E0), pulse 2 (harmony, index $07E4), triangle (bass, index $FA) and noise (percussion, index $07EC);
 * the voices read the stream at different positions, so each song table entry gives the start index of every voice. $F4 = song (request bit) playing. */
static uint8_t music_length(uint8_t note) {            /* Sub_FF53: frames the note lasts */
    uint8_t cls = (uint8_t)(((note & 1) << 2) | (note >> 6));
    return rd16mem((uint16_t)(0xFF3E + (uint8_t)(cls + RAM(0x07F0))));      /* 16-bit address: a large tempo offset wraps into RAM, as on the console */
}
static uint8_t music_byte(uint8_t index) { return rdp(RAM(0xF8), RAM(0xF9), index); }
static int play_note(void (*voice)(void), uint8_t note) { ra = note & 0x3E; voice(); return !fz; }   /* 1 when the pitch exists (not a rest) */

static void SoundMusic(void) {                          /* $FC8D */
    uint8_t a = RAM(0xFB), y, v, x;
    if (a != 0) {                                        /* a new song starts */
        RAM(0xF4) = a;
        y = 0; do { y++; } while (!((a >> (y - 1)) & 1));
        y = ROMB(0xFDD2 + y);
        RAM(0x07F0) = ROMB(0xFDD3 + y); RAM(0xF8) = ROMB(0xFDD4 + y); RAM(0xF9) = ROMB(0xFDD5 + y);
        RAM(0x07E0) = ROMB(0xFDD6 + y); RAM(0xFA) = ROMB(0xFDD7 + y); RAM(0x07EC) = ROMB(0xFDD8 + y);
        RAM(0x07E5) = RAM(0x07E1) = RAM(0x07E9) = RAM(0x07ED) = 1;
        RAM(0x07E4) = 0;
        RAM(0x07FB)++;
    } else if (RAM(0xF4) == 0) return;

    y = RAM(0x07E0);                                     /* pulse 1: melody */
    if (y != 0) {
        RAM(0x07E1)--;
        if (RAM(0x07E1) == 0) {
            RAM(0x07E0)++;
            v = music_byte(y);
            RAM(0x07E1) = music_length(v);
            if (!play_note(PlayPulse1Note, v)) x = 0x10;
            else x = (RAM(0xF4) & 0x60) ? 0x4F : 0x05;
            WR(0x4000, x);
            y = 0x7F;
            if (RAM(0xF4) & 1) y = ROMB(0xFC89 + (RAM(0x07FB) & 3));
            WR(0x4001, y);
        }
    }
    RAM(0x07E5)--;                                       /* pulse 2: harmony */
    if (RAM(0x07E5) == 0) {
        y = RAM(0x07E4); RAM(0x07E4)++;
        v = music_byte(y);
        if (v == 0) { RAM(0xFA) = 0; RAM(0xF4) = 0; WR(0x4000, 0x90); return; }      /* end of the song: silence pulse 1 and stop */
        RAM(0x07E5) = music_length(v);
        if ((RAM(0xF4) & 0x60) == 0) {
            if (!play_note(PlayPulse2Note, v)) x = 0x10;
            else x = RAM(0x07E5) >= 0x10 ? 0x87 : (RAM(0x07E5) >= 0x08 ? 0x84 : 0x82);
            WR(0x4004, x); WR(0x4005, 0x7F);
        }
    }
    y = RAM(0xFA);                                       /* triangle: bass */
    if (y != 0) {
        RAM(0x07E9)--;
        if (RAM(0x07E9) == 0) {
            RAM(0xFA)++;
            v = music_byte(y);
            RAM(0x07E9) = music_length(v);
            a = (uint8_t)(RAM(0x07E9) - 1);
            if (a >= 0x0C) a = 0x0C;
            a = (uint8_t)(a << 2);
            if (RAM(0xF4) == 0x20) a = 0x81;
            WR(0x4008, a);
            if (!play_note(PlayTriangleNote, v)) WR(0x4008, 0);
        }
    }
    if ((RAM(0xF4) & 0x1B) != 0) {                       /* noise: percussion */
        RAM(0x07ED)--;
        if (RAM(0x07ED) == 0) {
            y = RAM(0x07EC); RAM(0x07EC)++;
            v = music_byte(y);
            RAM(0x07ED) = music_length(v);
            a = v & 0x3E;
            if (a != 0) { WR(SND_NOISE_VOL, 0); WR(SND_NOISE_LO, a == 0x20 ? 2 : 0); WR(SND_NOISE_HI, 8); }
        }
    }
}

/* Pulse 1 effects. A request bit starts an effect; while it runs, $F0 holds its bit and $F5 counts its frames down. Music ($F4) silences them.
 * Effects by request bit: 0 jump blip, 1 menu blip, 2 landing thump with a falling sweep, 3/4/5 short sweeps, 6 long decaying tone.
 * The leftover X register matters in one place (effect 6 passes it through), as in the original. */
static void pulse1_end(void) { RAM(0xF0) = 0; WR(0x4000, 0x90); }                                /* $F93E */
static void pulse1_tail(void) { RAM(0xF5)--; if (RAM(0xF5) == 0) pulse1_end(); }                  /* $F93A */
static void pulse1_sweep_tail(uint8_t sweep) { WR(0x4001, sweep); RAM(0xF6) = 6; pulse1_tail(); } /* $F933 */
static void pulse1_hold_sweep(void) { if (RAM(0xF6) == 4) WR(0x4001, 0x9A); }                    /* $F95F */
static void pulse1_short_start(uint8_t req) {                                                     /* $F94E: effects 4 and 5 share this setup */
    rx = 0x9C; ra = 0; ry = req; SetPulse1Regs();
    RAM(0xF6) = 4; WR(0x4001, 0x9A);
}

static void SoundPulse1Sfx(void) {                      /* $F8D4 */
    enum { A_START, A_RUN, B_START, C_RUN, C_START, D_START, D_RUN, E_START, E_RUN, F_START, F_RUN, G_START, G_RUN } ev;
    uint8_t y, a, c;
    ry = RAM(0xF4); SETNZ(ry);
    if (ry != 0) return;
    y = RAM(0xFF); a = RAM(0xF0);
    ry = y; SETNZ(ry);
    if (take_request_bit(0xFF)) ev = A_START;
    else {
        c = a & 1; a >>= 1;
        if (c) ev = A_RUN;
        else if (take_request_bit(0xFF)) ev = B_START;
        else {
            c = a & 1; a >>= 1;
            if (c) ev = A_RUN;                           /* effect 1 running: only the common countdown */
            else {
                c = a & 1; a >>= 1;
                if (c) ev = C_RUN;
                else if (take_request_bit(0xFF)) ev = C_START;
                else if (take_request_bit(0xFF)) ev = D_START;
                else {
                    c = a & 1; a >>= 1;
                    if (c) ev = D_RUN;
                    else if (take_request_bit(0xFF)) ev = E_START;
                    else {
                        c = a & 1; a >>= 1;
                        if (c) ev = E_RUN;
                        else if (take_request_bit(0xFF)) ev = F_START;
                        else {
                            c = a & 1; a >>= 1;
                            if (c) ev = F_RUN;
                            else if (take_request_bit(0xFF)) ev = G_START;
                            else {
                                c = a & 1; a >>= 1;
                                if (c) ev = G_RUN; else return;
                            }
                        }
                    }
                }
            }
        }
    }
    switch (ev) {
    case A_START: RAM(0xF0) = y; RAM(0xF5) = 1; rx = 0x80; ry = 0x9C; ra = 4; SetPulse1Regs(); return;
    case A_RUN: pulse1_tail(); return;
    case B_START: RAM(0xF0) = y; RAM(0xF5) = 0x10; rx = 0x85; ry = 0x85; ra = 0x30; SetPulse1Regs(); pulse1_tail(); return;
    case C_START: RAM(0xF0) = y; RAM(0xF5) = 9; ra = 4; PlayPulse1Note(); /* fall through */
    case C_RUN:
        a = RAM(0xF5);
        if (a == 4) { pulse1_end(); return; }
        WR(0x4001, a >= 7 ? 0x84 : 0x8B);
        WR(0x4000, a | 0x90);
        pulse1_tail(); return;
    case D_START:
        RAM(0xF0) = y; RAM(0xF5) = 6; rx = 0x9C; ra = 0x3C; ry = y; SetPulse1Regs();
        RAM(0xF6) = 3; WR(0x4001, 0x9A); return;
    case D_RUN:
        RAM(0xF6)--;
        if (RAM(0xF6) == 0) { pulse1_sweep_tail(0x93); return; }
        if (RAM(0xF6) == 3) WR(0x4001, 0x9A);
        return;
    case E_START: RAM(0xF0) = y; RAM(0xF5) = 3; pulse1_short_start(y); return;
    case E_RUN:
        RAM(0xF6)--;
        if (RAM(0xF6) == 0) { pulse1_sweep_tail(0x93); return; }
        pulse1_hold_sweep(); return;
    case F_START: RAM(0xF0) = y; RAM(0xF5) = 2; pulse1_short_start(y); return;
    case F_RUN:
        RAM(0xF6)--;
        if (RAM(0xF6) == 0) { pulse1_sweep_tail(0x94); return; }
        pulse1_hold_sweep(); return;
    case G_START: RAM(0xF0) = y; RAM(0xF5) = 0x21; ry = 0xBC; ra = 0x30; SetPulse1Regs(); /* fall through (X is whatever the caller left) */
    case G_RUN: {
        a = RAM(0xF5);
        if (a == 0x15) WR(0x4001, 0x7F);
        c = a & 1;
        uint8_t v = c ? rd16mem((uint16_t)(0xF9A2 + (a >> 1))) : 0x13;
        WR(0x4000, v);
        if (v != 0) pulse1_tail();
        return; }
    }
}

/* Pulse 2 / triangle: one-shot effects (request $FE: a 21-step blip sequence from $FA24/$FA39) and the engine sound, a tone that follows the
 * engine request ($FC, bit 7 = player's bike) with a small vibrato from $F9B3. $F3 = current pitch step, $F7 = vibrato index, $07F8 = steps until
 * the pitch is re-evaluated, $07F3 = frames left in the blip step, $F1 = blip step. */
static void pulse2_blip_step(uint8_t y) {              /* $FA5E */
    uint8_t x = ROMB(0xFA24 + y), a = (x == 0x80) ? 2 : 1;
    RAM(0x07F3) = a;
    rx = x; ry = 0x7F; ra = ROMB(0xFA39 + y);
    SetPulse2Pitch();
}
static void pulse2_silence(void) { WR(0x4004, 0x90); }                                          /* $FA8F */

static void SoundPulse2TriangleSfx(void) {             /* $FA74 */
    uint8_t y, a, d, c;
    y = RAM(0xFE); ry = y; SETNZ(ry);
    if (y != 0) { RAM(0xF1) = 0x15; pulse2_blip_step(0x15); return; }
    y = RAM(0xF1);
    if (y != 0) {
        RAM(0x07F3)--;
        if (RAM(0x07F3) != 0) { pulse2_silence(); return; }
        RAM(0xF1)--;
        if (RAM(0xF1) == 0) { pulse2_silence(); return; }
        pulse2_blip_step(y);
        return;
    }
    a = RAM(0xFC) & 0x7F;
    if (a == 0) {                                       /* no engine sound: stop it once */
        if (RAM(0xF3) == 0) return;
        RAM(0xF3) = 0; RAM(0xF7) = 0; RAM(0x07F8) = 0;
        pulse2_silence();
        return;
    }
    y = RAM(0xF7); RAM(0xF7)++;
    if (y == RAM(0x07F8)) {                             /* time to move the pitch step toward the requested speed */
        if (a >= 0x30) { RAM(0xF3) = 0x30; goto from_table; }
        c = a >= RAM(0xF3); d = (uint8_t)(a - RAM(0xF3));
        if (d == 0) goto from_table;
        if (!c) {
            RAM(0xF3)--;
            if (d >= 0xF8) goto short_wait;
            RAM(0xF3)--;
            if (RAM(0xF3) != 0) goto short_wait;
        }
        RAM(0xF3)++;                                    /* $FAB3 */
        if (d >= 0x08) RAM(0xF3)++;
    short_wait:
        a = 1; goto set_wait;
    from_table:
        a = ROMB(0xF9F4 + RAM(0xF3));
    set_wait:
        RAM(0x07F8) = a; RAM(0xF7) = 0;
    }
    a = (uint8_t)(RAM(0x07FF) + 4);                     /* DMC volume ramp target */
    if (a < 0x40) RAM(0x07FF) = a;
    y = RAM(0xF7);
    a = (uint8_t)(ROMB(0xF9C4 + RAM(0xF3)) + ROMB(0xF9B3 + y));
    if (RAM(0xFC) & 0x80) { rx = ROMB(0xF9BF + y); ry = 0x89; }
    else { rx = ROMB(0xF9B9 + y); ry = 0x7F; }
    ra = a;
    SetPulse2Pitch();
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
void V_SoundMusic(Regs r) { ra = r.a; rx = r.x; ry = r.y; fc = r.c; SoundMusic(); }

void V_SetPulse1Regs(Regs r) { ra = r.a; rx = r.x; ry = r.y; fc = r.c; SetPulse1Regs(); }
void V_PlayPulse1Note(Regs r) { ra = r.a; rx = r.x; ry = r.y; fc = r.c; PlayPulse1Note(); }
void V_PlayPulse2Note(Regs r) { ra = r.a; rx = r.x; ry = r.y; fc = r.c; PlayPulse2Note(); }
void V_PlayTriangleNote(Regs r) { ra = r.a; rx = r.x; ry = r.y; fc = r.c; PlayTriangleNote(); }
void V_SoundPulse1Sfx(Regs r) { ra = r.a; rx = r.x; ry = r.y; fc = r.c; SoundPulse1Sfx(); }
void V_SoundPulse2TriangleSfx(Regs r) { ra = r.a; rx = r.x; ry = r.y; fc = r.c; SoundPulse2TriangleSfx(); }
