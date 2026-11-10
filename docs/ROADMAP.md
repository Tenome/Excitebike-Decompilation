# Roadmap: matching disassembly -> C -> native PC port

1. **Matching assembly - done for both ROMs.** Byte-identical rebuild, ByteMatch report.
2. **Name everything - largely done.** Routines, RAM (rider records, track state, timers, sound engine) and modules are named; some data tables remain raw `.incbin`.
3. **Lift to C - done for all game logic.** Hand-lifted readable C for everything that runs during play, mechanical lifts (`tools/lift6502.py`) for the sound engine and data-recorder code. Verified per routine (`tools/difftest.py`) and for the whole game from reset, frame by frame (`tools/fulltest.py`), on both ROMs.
4. **Native runtime - first version done (`port/`).** The C game runs on Windows with SDL2: the PPU/APU register writes feed a scanline picture layer and a synthesizer, the controller feeds the joypad. No CPU emulation. Next: replace the register-write interface with a renderer API that reads named game state, so the picture is no longer limited to what the PPU could show.
5. **Features** (each is a layer on the C game, never the ROM): see `PORT_FEATURES.md`.
   - *Higher frame rate*: separate simulation at 60 Hz from rendering; interpolate rider positions and scroll (needs rider positions as state, not OAM).
   - *Widescreen*: the track streamer writes one column at a time into a 64-column ring; it must run further ahead and the HUD needs repositioning.
   - *More CPU riders*: rider arrays are fixed four-slot records; sprites go to a software list so the 64/8 limits disappear.
   - *Both regions*: already selected at run time (`g_pal`).
6. **Packaging**: Windows/Linux builds, asset extraction from the user's own ROM at first run (no game data in the repo).

Interim deliverable available now: the NESRecomp static recompilation (`recomp/build_native.ps1`), which already runs the whole game as native C with no per-instruction interpretation of ROM code.
