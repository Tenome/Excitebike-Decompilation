/* Excitebike: routines lifted from 6502 assembly to C.
 * Each function mirrors one routine of src/<ver>/ modules and is differential-tested against the original code
 * (tools/difftest.py runs both on random state and compares RAM and result registers). */
#pragma once
#include <stdint.h>

typedef struct { uint8_t a, x, y, c; } Regs;  /* register (and carry) inputs/outputs of a lifted routine */

extern uint8_t g_ram[0x800];                  /* CPU RAM ($0000-$07FF) */
typedef struct { uint16_t addr; uint8_t val; } IoWrite;
extern IoWrite g_io_log[8192];                /* hardware-register writes in order (see excitebike.c) */
extern int g_io_n;
extern uint8_t g_io_reads[0x8000];            /* values returned by hardware-register reads */
extern int g_io_model;                        /* 1 = built-in minimal hardware model (tools/fulltest.py) */
extern uint8_t g_pad_buttons[2];              /* buttons the joypad model shifts out (bit 0 = A ... bit 7 = Right) */
extern void (*g_hal_write)(uint16_t addr, uint8_t val);   /* host hooks for the PC port (NULL in the tests) */
extern uint8_t (*g_hal_read)(uint16_t addr);
extern void (*g_hal_event)(int event, int arg);
enum { SND_MUSIC = 0, SND_NOISE = 1, SND_PULSE2 = 2, SND_PULSE1 = 3 };
extern int (*g_hal_sound)(int chan, int value);   /* a sound request is about to run; return nonzero to replace it (audio mods) */
enum { HAL_EV_DELAY = 1 };                    /* the code busy-waits for `arg` CPU cycles */
typedef struct {
    uint8_t jump_power;          /* speed bonus added when a jump starts (original $AF) */
    uint8_t crash_pitch;         /* pitch value at which a rider crashes (original $0D) */
    uint8_t overheat;            /* 1 = the engine overheats at a full temperature gauge (original) */
    uint16_t max_speed_pct;      /* player top speed in percent of the original (100) */
} Rules;
extern Rules g_rules;
typedef struct { int x; uint8_t y, tile, attr; } WideSprite;
int WideRiderSprites(WideSprite *out, int max, int width);   /* host helper: riders beyond the right edge, for widescreen */
extern int g_extra_count;                     /* number of extra CPU riders (host feature, 0 = original) */
void ExtraRidersFrame(void);                 /* run the extra riders for one frame (after Nmi) */
int ExtraRiderSprites(WideSprite *out, int max, int width);
extern int g_pal;                             /* set to 1 for the European (PAL) ROM */
extern const uint8_t *g_prg;                  /* 16 KB PRG-ROM, CPU $C000-$FFFF (supplied by the host from the user's ROM) */
#define ROMB(addr) (g_prg[(addr) & 0x3FFF])

Regs DivModByX(Regs r);       /* $DFA4  A / X -> A remainder, X quotient (uses $0F) */
Regs DivMod10(Regs r);        /* $DFA2  A / 10 */
Regs IncMod64(Regs r);        /* $ECBF  A = (A + 1) mod 64 */
void UpdateRandom(void);      /* $D326  64-bit shift-register RNG in $18-$1F */
void TickTimers(void);        /* $D310  prescaled countdown timers $21-$3D */
Regs AddCollisionHeight(Regs r);   /* $E091 */
Regs AddCollisionWidth(Regs r);    /* $E098 */
Regs RiderBaseY(Regs r);      /* $DC97 / $DC9A  ($03F1 or A) - RiderHeight[x] - RiderY[x] */
Regs RiderBaseYFrom(Regs r);
Regs RiderLaneFromY(Regs r);  /* $DFB2 */
void ComputeRiderLanes(void); /* $D0AB */
void AdvanceTrackPositions(void); /* $E70B */
void SplitDigits3(Regs r);    /* $DF7F  three bytes at $00,x.. -> decimal digits at $03D1-$03D7 */
void SortRidersByY(void);     /* $E3F4 */

Regs AccumulateRiderMove(Regs r);  /* $DA58 */
void ScrollWorld(void);            /* $DA6A */
void ShiftRidersByScroll(void);    /* $DA7A */
void ScrollSplitLayer(void);       /* $DBFE */
Regs ComputeRiderShadowY(Regs r);  /* $DA15 */
Regs JumpArcStep(Regs r);          /* $DD6F  (carry-in significant) */
Regs RiderPitchTimer(Regs r);      /* $DCDE */
Regs AiMatchTargetSpeed(Regs r);   /* $CFCB / $CFDB */
Regs AiMatchTargetSpeedFrom(Regs r);   /* $CFDB */
Regs SetTrackRowPointer(Regs r);   /* $E80D */
Regs TrackPieceAt(Regs r);         /* $E803 */
Regs TrackPieceAtRow(Regs r);      /* $E7FF */
Regs TrackPieceAtRiderLane(Regs r);/* $E7FC */
Regs RiderYOverlapTest(Regs r);    /* $E52C */
Regs ClearRider(Regs r);           /* $DB95 */
Regs AdvanceBufferPos(Regs r);     /* $C971 */

Regs AccumulateRiderMove(Regs r);  /* $DA58 */
void ScrollWorld(void);            /* $DA6A */
void ShiftRidersByScroll(void);    /* $DA7A */
void ScrollSplitLayer(void);       /* $DBFE */
Regs ComputeRiderShadowY(Regs r);  /* $DA15 */
Regs JumpArcStep(Regs r);          /* $DD6F  (carry-in significant) */
Regs RiderPitchTimer(Regs r);      /* $DCDE */
Regs AiMatchTargetSpeed(Regs r);   /* $CFCB */
Regs AiMatchTargetSpeedFrom(Regs r);   /* $CFDB */
Regs SetTrackRowPointer(Regs r);   /* $E80D */
Regs TrackPieceAt(Regs r);         /* $E803 */
Regs TrackPieceAtRow(Regs r);      /* $E7FF */
Regs TrackPieceAtRiderLane(Regs r);/* $E7FC */
Regs RiderYOverlapTest(Regs r);    /* $E52C */
Regs ClearRider(Regs r);           /* $DB95 */
Regs AdvanceBufferPos(Regs r);     /* $C971 */

void SetRiderTargetSpeed(Regs r);  /* $DB50 */
void AiJumpCheck(Regs r);          /* $D000 */
void AiClearPitchBits(Regs r);     /* $CFE3 */
void AiSetPitchInput(Regs r);      /* $CFEA */
void SetRiderTargetPitch(Regs r);  /* $DCA0 */
void RiderPitchAdjust(Regs r);     /* $DCC7 */
void RiderJumpSetup(Regs r);       /* $DD38 */
void RiderStartJump(Regs r);       /* $DD06 */
void RiderLaunchUpdate(Regs r);    /* $DCF2 */
void ClearOam(void);               /* $D255 */

Regs RiderTerrainSpeedBias(Regs r);  /* $CDEE */
void RiderAccelerate(Regs r);        /* $CE29 */
void RiderDecelerateBy(Regs r);      /* $CE5C */
void RiderDecelerate(Regs r);        /* $CE58 */
void RiderPitchWobble(Regs r);       /* $CE83 */
Regs AiLaneBlocked(Regs r);          /* $CF96 */
Regs AiTrackPieceOpen(Regs r);       /* $CF8B */
void AiLaneChangeUp(Regs r);         /* $CF47 */
void AiLaneChangeDown(Regs r);       /* $CF6A */
void AiConsiderLaneChange(Regs r);   /* $CF0C */

void RiderState1Gate(Regs r);        /* $D933 */
void RiderState2MoveToLane(Regs r);  /* $D953 */
void RiderState3Wait(Regs r);        /* $D983 */
void RiderState5Finish(Regs r);      /* $D9F6 */

void ResetGameRam(void);                  /* $CA85 */
Regs TimeTableIndexForTrack(Regs r);      /* $CB13 */
Regs TimeTableIndexForSelection(Regs r);  /* $CB06 */
void SaveInputToRider0(void);             /* $CA1B */
void RiderState4Release(Regs r);          /* $D9D3 */

void RiderControlStep(Regs r);       /* $CD59 */
void UpdateRaceClock(void);          /* $DF30 */
void UpdateEngineSound(void);        /* $DEE2 */

Regs AiScanObstacles(Regs r);        /* $D018 */
void UpdateAiRiders(void);           /* $CED0 */
void UpdateRiderControls(void);      /* $CD1F */

Regs SpawnRider(Regs r);             /* $DAE3 */
void SpawnCpuRiders(void);           /* $DA9F */
void HandleLostRider(void);          /* $DBC4 */

void RiderLaunchFromRest(Regs r);        /* $DCFA */
void TrackScriptOpcode(Regs r);          /* $E794 */
void RunPendingTrackScripts(void);       /* $E927 */
void RunTrackScriptRider(Regs r);        /* $E73B */
void RunTrackScripts(void);              /* $E733 */

void DrawMetasprite(Regs r);         /* $D1C7 */
void ClearSpriteBlock(Regs r);       /* $E4AD */
void EraseRiderSpriteRange(void);    /* $E49B */
void ErasePassedRiderSprites(void);  /* $E456 */
Regs RiderSpriteFrame(Regs r);       /* $E1F9 */
void DrawRider(Regs r);              /* $E1A3 */
void DrawRiderShadow(Regs r);        /* $E26A */
void DrawRiders(void);               /* $E17F */
void DrawSkidSmoke(Regs r);          /* $E2F6 */
void DrawJumpShadows(void);          /* $EA44 */
void UpdateTempGauge(void);          /* $E359 */
void DetectRiderOverlap(void);       /* $E4C8 */

void RiderCrashUpdate(void);         /* $DDD1 */
void CheckTrackEdge(void);           /* $DEBB */
void UpdateExhaustSprites(void);     /* $DE31 */

void RiderLandingCheck(Regs r);      /* $DC1A */
void RiderCollisions(void);          /* $DFD5 */
void BikeVsObstacleCheck(void);      /* $E09F */
void UpdateRiderGroundDistance(void);/* $E836 */
void UpdateRiderY(void);             /* $E96C */
void RiderStateDispatch(Regs r);     /* $D924 */
void UpdateRiderStates(void);        /* $D918 */
Regs MenuHandleInput(Regs r);        /* $C7DE */

void GameStateClearSteps(void);      /* $C3B1 */
void GameStateAdvance(void);         /* $C3AF */
void HudSpriteTemplate(void);        /* $CD13 */
void OverheatMessage(void);          /* $CCDD */
void OverheatUpdate(void);           /* $DD8D */
void RaceEndSequence(void);          /* $CA9B */

void WriteTimeTextHeader(void);      /* $C94B */
void WriteTimeDigitsToBuffer(void);  /* $C935 */
void ResultsDrawLine(Regs r);        /* $CCCA */
void ResultsStepInit(void);          /* $CB3B */
void ResultsStepDrawText(void);      /* $CB77 */
Regs ResultsDrawRank(Regs r);        /* $CC15 */
void ResultsStepFinish(void);        /* $CC6B */
void ResultsStepWait(void);          /* $CBA4 */
void StateSubStepDispatch(void);     /* $CB2C */

void LoadBestTime(void);             /* $C522 */
void LoadSavedTimeForIndex(void);    /* $C53E */
void LoadSavedTime(void);            /* $C53A */
void WriteTimeTextSaved(Regs r);     /* $C92C */
void SetMenuCursorSprite(Regs r);    /* $C409 */
void StateMenuChoice6(void);         /* $C3BD */
void StateMenuChoice5(void);         /* $C395 */
void ComputeRaceResult(void);        /* $C485 */

void TrackColumnPointer05(Regs r);   /* $F82E */
void TrackColumnPointer07(Regs r);   /* $F839 */
Regs DesignEndRecord(Regs r);        /* $F826 */
Regs DesignMarkRecord(Regs r);       /* $F821 */
void ClearColumnBuffer(void);        /* $F676 */
Regs CopyColumnBytes(Regs r);        /* $F681 */
void WriteColumnToRows(void);        /* $F64E */
void DrawTrackColumn(void);          /* $F6FB */
Regs DesignCheckSlotFree(Regs r);    /* $ECC9 */
void DesignLoadPiece(void);          /* $EC75 */
void DesignScrollStep(void);         /* $EC99 */
void CopyBackupToDesign(void);       /* $EC3B */
void DrawDesignCursorSprite(Regs r); /* $EC25 */
void DesignBlinkCursor(void);        /* $EC5D */

void TrackRenderUpdate(void);        /* $F4FF */
void DesignPlayback(void);           /* $F68D */
void DesignCapture(void);            /* $F755 */
void DesignModeUpdate(void);         /* $EB17 */

void FetchTrackWindow(void);         /* $D0C6 */
void QueueNametableRect(void);       /* $D2A3 */
void CopyTimeDigitsToHud(void);      /* $D0F4 */
void InitHudBuffer(void);            /* $D11F */
void DrawFinishGate(void);           /* $EAC5 */
void UpdateTrackObstacle(void);      /* $E0E6 */
void UpdateScrollingBanner(void);    /* $E2AF */
void MoveRiders(void);               /* $DA26 */

void ResetSavedTimes(void);          /* $C229 */
void InitBackupRam(void);            /* $C1FD */
void CopyTrackDesignToBackup(void);  /* $C621 */
void TapeCountBit(void);             /* $C68A */
void TapeSelectBlockA(void);         /* $C716 */
void TapeSelectBlockB(void);         /* $C726 */
void StateDesignEnd(void);           /* $C43D */
void StateDesignSaveCheck(void);     /* $C41C */
void ClearRaceZeroPage(void);        /* $C869 */
void StartRaceSetup(void);           /* $C875 */

void SetPpuCtrl(Regs r);             /* $C333 */
void DisableNmi(void);               /* $C32F */
void WaitVblankEndEnableNmi(void);   /* $C339 */
void DisableRendering(void);         /* $D24F */
void ResetPpuScroll(void);           /* $D1A9 */
void ClearNametable(void);           /* $D260 */
void ClearNametables(void);          /* $D23B */
void InitScreenState(void);          /* $C318 */
void ApplySplitScroll(void);         /* $D1B3 */
void WaitSprite0ThenResetScroll(void); /* $D19B */
void SplitScreenScrollHandler(void); /* $D14E */
void RunPpuWriteList(void);          /* $D3C1 */
void FlushPpuUpdateAt(Regs r);       /* $C289 */
void FlushPpuUpdate(void);           /* $C27F */
void InitHudSprite(Regs r);          /* $ECE4 */
void ClearRiderSprites(void);        /* $D13F */
void ReadJoypadPort(Regs r);         /* $D35B */
void ReadJoypads(void);              /* $D347 */

void ResultScreenActivate(void);     /* $C514 */
void ResultScreenActivateKeep(void); /* $C518 */
void SetupPpuUpdateTrack(void);      /* $C551 */
void SetupPpuUpdate06(void);         /* $C55E */
void SetupPpuUpdate05(void);         /* $C562 */
void SetupPpuUpdate0E(void);         /* $C566 */
void SetupPpuUpdate04(void);         /* $C56A */
void SetupPpuUpdate09(void);         /* $C571 */
void SetupPpuUpdate11(void);         /* $C582 */
void SetupPpuUpdate17(void);         /* $C5A3 */
void SetupMenuCursorTrack5(void);    /* $C575 */
void SetupTimeTextSaved0(void);      /* $C5A7 */
void SetupDesignTimes(void);         /* $C586 */
void SetupTrackPicker(void);         /* $C5AC */
void DesignShowSlotSprite(void);     /* $EC47 */
void SetupDesignMode(void);          /* $C5C2 */
void SetupTitleSubMenu(void);        /* $C3F3 */
void SetupTitleScreen(void);         /* $C2BD */
void SetupResultsPpu(void);          /* $C455 */
void StateRaceEndWait(void);         /* $C465 */
void StateTitleMenu(void);           /* $C346 */
void HandlePause(void);              /* $CA38 */
void RacePreUpdate(void);            /* $CA08 */
void ClearOverlappedRiderSprites(void); /* $E42B */
void StateDesignFrame(void);         /* $C97C */
void StateRaceFrame(void);           /* $C99A */

void RaceSetupScreen(void);          /* $C820 */
void GameStateDispatch(void);        /* $C2A9 */
void Nmi(void);                      /* $C23B  per-frame entry point */
void ResetInit(void);                /* $C184 */
int MainLoopStep(void);              /* $C1D8 */
