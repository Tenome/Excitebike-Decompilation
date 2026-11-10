# Roadmap: matching disassembly -> C -> native PC port

1. **Matching assembly (done for both ROMs).** Byte-identical rebuild, ByteMatch report.
2. **Name everything.** Routines, RAM (rider records, track state, timers, sound engine), data tables; split `bank_0.asm` into modules (boot, input, PPU, track, riders, HUD, menus, sound, design mode). Remaining 5 KB of data: decode into typed tables.
3. **Lift to C.** One routine at a time, checked against the original with frame hashes (`nes_game --hash-out`) exactly like the recompiler's oracle: the C routine and the assembly must give identical RAM/PPU state per frame.
4. **Native runtime with a platform layer (no emulator).** Replace PPU register writes with a renderer API (tiles, sprites, scroll, palette) and the APU writes with a mixer API; the game logic stays in C. Render sprites and background through the host renderer (OpenGL/SDL) instead of emulated scanlines.
5. **Features** (each is a mod layer on the C game, never the ROM):
   - *Higher frame rate*: separate simulation at 60 Hz from rendering; interpolate rider positions and scroll.
   - *Widescreen*: the track is a horizontal strip; the renderer needs to extend the visible lanes' scenery and track pieces beyond 256 px (the track generator already produces upcoming pieces off-screen), and the HUD needs repositioning.
   - *More CPU riders*: rider arrays are stride-4 records with a fixed slot count and the OAM limit is 64 sprites with 8 per scanline; the C port moves sprites to a software list so the limit disappears.
   - *Both regions*: PAL/NTSC timing tables selected at run time.
6. **Packaging**: Windows/Linux builds, asset extraction from the user's own ROM at first run (no game data in the repo).

Interim deliverable available now: the NESRecomp static recompilation (`recomp/build_native.ps1`), which already runs the whole game as native C with no per-instruction interpretation of ROM code.
