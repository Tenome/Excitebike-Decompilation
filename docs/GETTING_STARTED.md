# Getting started

You need your own Excitebike ROM (NTSC "Japan, USA" or PAL "Europe"). It is never included here.

1. **Build the port.** Install SDL2 development files and clang or gcc, then see `port/README.md` (Windows: the `clang` line; Linux/macOS: `make`). Or use a packaged folder (`tools/package.py`).
2. **Run it.** `excitebike excitebike.nes`. Arrows, Z = accelerate, X = turbo, Enter = Start, Shift = Select, **Tab = options menu**, F5/F9 quick save/load, F6 reload mods, F11 fullscreen.
3. **Open the editors.** `python tools/editor/serve.py excitebike.nes` opens the track, tile and music editors in your browser.
   * Tracks: build a level, save `designs.ebd` (or a `.ebpack.json` pack), run `excitebike excitebike.nes --track 1=mylevel.ebd`, press F6 after each save.
   * Tiles and colours: save `tiles.bmp` / `colors.pal`, run with `--chr-bmp tiles.bmp --palette colors.pal`.
   * Music: save `song_01.ebm` (01 = the title song) into a folder, run with `--audio-mod thatfolder`. `python tools/ebmusic.py export DIR` gives you the ROM songs to start from.
4. **Share a level.** Level packs and the community browser: `levels/README.md`.
5. **Check your changes.** `python tests/test_tools.py` for the tools; `python tools/difftest.py` and `python tools/fulltest.py` prove the C game still equals the ROM (see `docs/NOTES.md`).

Settings you change in the menu are written to `excitebike.cfg`; every key is documented in `port/excitebike.cfg.example`.
