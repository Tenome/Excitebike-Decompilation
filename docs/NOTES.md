# Notes

## Memory map seen so far
| Address | Name | Notes |
|---|---|---|
| `$0000-$0001` | scratch pointer | used with `(zp),y` everywhere |
| `$10` / `$11` | `PpuCtrlShadow` / `PpuMaskShadow` | written by `SetPpuCtrl` (`$C333`) and NMI |
| `$12` / `$13` | `ScrollX` / `ScrollY` | applied after vblank; `$50` / `$51` are the split-screen (status bar) scroll |
| `$14-$17` | `Joy1Held`, `Joy1Trigger`, `Joy2Held`, `Joy2Trigger` | `ReadJoypads` `$D347`; A is bit 7 and is edge-filtered in the trigger byte |
| `$18-$1F` | `RandomState` | 64-bit shift/xor register stepped by `UpdateRandom` `$D326` |
| `$20-$3D` | countdown timers | `TickTimers` `$D310` decrements them every 10th frame |
| `$3F` | `FrameCounter` | incremented in NMI |
| `$41` | `GameState` | `GameStateDispatch` `$C2A9` jumps through the word table at `$C000` |
| `$45` | `PpuUpdateIndex` | selects a PPU write list from the tables at `$C0F6`/`$C111`; `FlushPpuUpdate` `$C27F` |
| `$80-$BC` | per-rider arrays (stride 4) | bike/rider records, to be named |
| `$0200` | `OamBuffer` | cleared to `$F8` by `ClearOam` |
| `$05CE/$05CF` | backup RAM signature (`$A5 $5A`) | when present at reset only `$0000-$04FF` is cleared, so saved designs in `$0500+` survive a soft reset |

## Hardware use
NROM, no mapper. NMI drives sprite DMA, PPU buffer flush, joypad reads and the sound engine (`$F8xx-$FFxx`, note table at `$FF00`). Reset waits two vblanks, clears RAM (partly, see above), initialises backup RAM and loops on a state byte. Routines around `$C62D-$C66E` toggle `$4016` and poll its input bit in timed loops; this looks like the Famicom data recorder interface used to save designs (to be confirmed).

## Versions
Only 17 PRG bytes differ between NTSC and PAL (`$09EB-$0A01`, `$117D`): timing/speed tables. The PAL header sets byte 12 to 1.

## Coverage
Biased random input routes on NESRecomp's seedless interpreter host (`tools/run_routes.sh`) saw 2,797 distinct opcodes executing; a second round of 11 routes x 40,000 frames added only 37, so blind play has plateaued. Static descent from them reaches 5,533 instruction starts. No gap scan candidates remain.

## Rider records (provisional names)
Four riders (index 0 = player, 1-3 = CPU) are stored as parallel zero-page arrays indexed by X. Names in `config/<ver>/ram.json` come from reading the code and are provisional:
`RiderInput` $5C (control bits), `RiderMoveX` $60 (pixels moved this frame), `RiderLane` $70, `RiderTargetSpeedLo/Hi` $74/$78, `RiderXLo/Hi` $80/$84 (bit 0 of Hi = on screen),
`RiderScreenY` $8C, `RiderSpeedLo/Hi` $90/$94, `RiderCrash` $98, `RiderState` $9C (dispatch through `$D8FF/$D905`), `RiderActive` $A8, `RiderPitch` $AC (6 = level, >= 13 crashes),
`RiderAirborne` $B0, `RiderY` $B8, `RiderHeight` $BC, `RiderTrackPos` $E0 (index into the 64-entry track ring). Sound requests are one-shot bytes: `SfxPulse1Request` $FF, `SfxPulse2Request` $FE, `SfxNoiseRequest` $FD, `EngineSoundRequest` $FC, `MusicRequest` $FB.

## C lift
`c/excitebike.c` holds routines lifted from the assembly. They keep the original arithmetic exactly (8-bit wraparound, carry chains, signed branch quirks) so `tools/difftest.py` can prove equality: it runs the original routine in `tools/sim6502.py` and the C routine on the same random RAM/registers and compares RAM, A/X/Y and carry. Only routines without hardware-register access are lifted so far (96 such routines exist; 222 done; routines whose callers do not use the result registers are compared on RAM only, and generators can bias RAM to reach rare branches).
