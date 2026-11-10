/* ---- extra CPU riders (host feature; not part of the original game) ----
 * The game has four rider slots (arrays indexed by X). Extra riders run the game's own per-rider routines (physics, ramps, crashes, AI)
 * by swapping each extra rider's record into slot 3 around a single-rider pass, so they behave like the original CPU riders. They do not
 * collide with other riders. Drawing uses the game's own draw routine on a scratch copy of RAM, so the real game state is untouched. Included from excitebike.c. */

static const uint16_t EXTRA_CTX[] = {                 /* base addresses of the per-rider arrays (slot 3 = base + 3) */
    0x26, 0x2A, 0x36, 0x58, 0x5C, 0x60, 0x64, 0x6C, 0x70, 0x74, 0x78, 0x7C, 0x80, 0x84, 0x8C, 0x90, 0x94, 0x98, 0x9C, 0xA0, 0xA4, 0xA8, 0xAC,
    0xB0, 0xB4, 0xB8, 0xBC, 0xC0, 0xC4, 0xC8, 0xCC, 0xD0, 0xD4, 0xD8, 0xDC, 0xE0, 0xE4,
    0x0360, 0x0364, 0x0368, 0x036C, 0x0370, 0x0374, 0x0378, 0x037C, 0x0380, 0x0384, 0x0388, 0x038B, 0x0390, 0x0394, 0x0398, 0x039B, 0x03E0, 0x03E4 };
#define EXTRA_CTX_N ((int)(sizeof EXTRA_CTX / sizeof EXTRA_CTX[0]))
#define EXTRA_MAX 4
typedef struct { uint8_t v[EXTRA_CTX_N + 4]; int active; int cooldown; } ExtraRider;
static ExtraRider g_extra[EXTRA_MAX];
int g_extra_count;                                    /* 0 = original game; set by the host (--riders N) */
static uint32_t g_extra_rng = 1;

static uint8_t extra_rand(void) { g_extra_rng = g_extra_rng * 1103515245u + 12345u; return (uint8_t)(g_extra_rng >> 16); }
static void extra_load(const ExtraRider *e) {
    for (int i = 0; i < EXTRA_CTX_N; i++) RAM(EXTRA_CTX[i] + 3) = e->v[i];
    for (int i = 0; i < 4; i++) RAM(0x03CC + i) = e->v[EXTRA_CTX_N + i];
}
static void extra_store(ExtraRider *e) {
    for (int i = 0; i < EXTRA_CTX_N; i++) e->v[i] = RAM(EXTRA_CTX[i] + 3);
    for (int i = 0; i < 4; i++) e->v[EXTRA_CTX_N + i] = RAM(0x03CC + i);
}
typedef struct { uint8_t slot3[EXTRA_CTX_N + 4]; } Slot3Backup;
static void slot3_save(Slot3Backup *b) { ExtraRider t; extra_store(&t); memcpy(b->slot3, t.v, sizeof b->slot3); }
static void slot3_restore(const Slot3Backup *b) { ExtraRider t; memcpy(t.v, b->slot3, sizeof t.v); extra_load(&t); }

static void extra_spawn(ExtraRider *e, int index) {
    static uint8_t keep[0x800];
    Slot3Backup real; slot3_save(&real);
    memcpy(keep, g_ram, sizeof keep);
    ExtraRider blank; memset(&blank, 0, sizeof blank);
    extra_load(&blank);
    RiderXHi(3) = RiderSpeedHi(0) & 2;                      /* ahead of or behind the player, like SpawnCpuRiders */
    Regs q = SpawnRider((Regs){ 0, 3, (uint8_t)(1 + (index + extra_rand()) % 4), 0 });
    if (q.a != 0) { extra_store(e); e->active = 1; } else e->active = 0;
    memcpy(g_ram, keep, sizeof keep);                   /* spawn scratch writes (and the spawn-cooldown) must not leak into the game */
    slot3_restore(&real);
    e->cooldown = 60 + extra_rand();
}

static void extra_pass(ExtraRider *e) {                 /* one frame for the extra rider currently in slot 3 */
    int rlo = g_rlo, rhi = g_rhi;
    g_rlo = g_rhi = 3;
    Regs r3 = { 0, 3, 0, 0 };
    if (RAM(0x29) != 0) RAM(0x29)--;                    /* the per-rider timers the NMI would tick */
    if (RAM(0x2D) != 0) RAM(0x2D)--;
    if (TimerPrescaler == 0x0A && RAM(0x39) != 0) RAM(0x39)--;
    SetRiderTargetPitch(r3); RiderLaneFromY(r3);
    RunTrackScriptRider(r3); RunPendingTrackScripts();
    UpdateRiderStates();
    RiderCrashUpdate();
    UpdateRiderControls();
    UpdateRiderY();
    UpdateRiderGroundDistance();
    AccumulateRiderMove(r3); RiderLandingCheck(r3); RiderLaunchUpdate(r3); RiderPitchTimer(r3);
    ShiftRidersByScroll();
    AdvanceTrackPositions();
    ComputeRiderLanes();
    FetchTrackWindow();
    if (RiderActive(3) != 0 && RiderCrash(3) == 0 && RiderState(3) == 0) {   /* the AI, as UpdateAiRiders does for one rider */
        RAM(0x0F) = 3;
        AiSetPitchInput(r3);
        if (RiderAirborne(3) != 0) RiderTargetPitch(3) = RiderPitchGoal(3);
        else {
            AiMatchTargetSpeed(r3);
            if (AiScanObstacles(r3).a == 0 && RAM(0x03A6) != 0) {
                AiJumpCheck(r3);
                if (RaceEndState == 0) AiConsiderLaneChange(r3);
            }
        }
    }
    g_rlo = rlo; g_rhi = rhi;
    (void)e;
}

void ExtraRidersFrame(void) {                           /* call once after each game frame (the NMI) */
    if (g_extra_count <= 0 || !RaceActive || !RaceStarted || RaceEndState != 0 || PauseFlag || GameState == 9) return;
    static uint8_t keep[0x800];
    for (int k = 0; k < g_extra_count && k < EXTRA_MAX; k++) {
        ExtraRider *e = &g_extra[k];
        if (!e->active) {
            if (e->cooldown > 0) e->cooldown--;
            else extra_spawn(e, k);
            continue;
        }
        Slot3Backup real; slot3_save(&real);
        memcpy(keep, g_ram, sizeof keep);
        extra_load(e);
        extra_pass(e);
        int gone = (RiderActive(3) == 0) || (RiderXHi(3) == 0 && RiderXLo(3) >= 0x70 && RiderXLo(3) < 0x90);   /* passed far behind (or cleared) */
        extra_store(e);
        /* only the extra rider's own record and its effects on shared scratch stay; everything else of the real game is put back */
        uint8_t scratch[16]; memcpy(scratch, g_ram, 16);
        memcpy(g_ram, keep, sizeof keep);
        slot3_restore(&real);
        (void)scratch;
        if (gone) { e->active = 0; e->cooldown = 90 + extra_rand(); }
    }
}

int ExtraRiderSprites(WideSprite *out, int max, int width) {   /* sprites of the extra riders on screen (x may exceed 255) */
    static uint8_t keep[0x800];
    int n = 0;
    for (int k = 0; k < g_extra_count && k < EXTRA_MAX; k++) {
        ExtraRider *e = &g_extra[k];
        if (!e->active) continue;
        Slot3Backup real; slot3_save(&real);
        memcpy(keep, g_ram, sizeof keep);
        extra_load(e);
        uint8_t xhi = RiderXHi(3), xlo = RiderXLo(3);
        if (xhi == 1 || (xhi == 2 && xlo + 24 < width - 256)) {
            for (int i = 0; i < 256; i++) g_ram[0x0200 + i] = 0xF8;
            RAM(0x04) = 0x80; RAM(0x0B) = (uint8_t)(k + 1);
            DrawRider((Regs){ 0, 3, 0, 0 });
            if (RAM(0x039F) != 0) DrawRiderShadow((Regs){ 0, 3, 0, 0 });
            int base = (xhi == 2 ? 256 : 0) + xlo;
            for (int i = 0; i < 64 && n < max; i++) {
                const uint8_t *o = &g_ram[0x0200 + i * 4];
                if (o[0] >= 0xEF) continue;
                out[n].x = base + (uint8_t)(o[3] - xlo); out[n].y = o[0]; out[n].tile = o[1]; out[n].attr = o[2]; n++;
            }
        }
        memcpy(g_ram, keep, sizeof keep);
        slot3_restore(&real);
    }
    return n;
}
