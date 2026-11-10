/* Excitebike: routines lifted from 6502 assembly to C.
 * Each function mirrors one routine of src/<ver>/ modules and is differential-tested against the original code
 * (tools/difftest.py runs both on random state and compares RAM and result registers). */
#pragma once
#include <stdint.h>

typedef struct { uint8_t a, x, y, c; } Regs;  /* register (and carry) inputs/outputs of a lifted routine */

extern uint8_t g_ram[0x800];                  /* CPU RAM ($0000-$07FF) */
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

void RiderTerrainSpeedBias(Regs r);  /* $CDEE */
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
