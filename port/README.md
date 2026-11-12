# Native port runtime

`excitebike [rom.nes]` runs the lifted C game (`../c/excitebike.c`) directly: there is no CPU emulation. The game writes PPU/APU registers;
`ppu.c` (scanline renderer) and `apu.c` (pulse/triangle/noise synthesis) turn those writes into the picture and the sound, and `main.c` adds the
window, controller, timing and a headless screenshot mode for tests:

```
excitebike orig/excitebike_us.nes                              # play
excitebike orig/excitebike_us.nes --frames 400 --shot out.bmp --press "60=8,64=0,120=8,124=0,200=1"   # headless: Start, Start, hold A, save frame 400
```
Keys: arrows, Z = A (accelerate), X = B (turbo), Enter = Start, Shift/Backspace = Select, F5 = quick save, F9 = quick load, F11 = fullscreen, Esc = quit.
Replays: `--record file` writes the controller state of every frame, `--play file` plays it back; the game is deterministic, so a replay ends with the same RAM checksum every time (printed at exit).
`--wav out.wav` writes the sound of the run; `--unlimited-sprites` lifts the eight-sprites-per-line limit.

Widescreen: `--widescreen` (416 px, about 16:9) or `--width N` (256-512) draws the track ahead of the normal screen edge while racing: the game already streams about 20 tiles beyond the edge, so no game code changes. The status bar stays 256 wide and centred; menus stay 256 wide. Sprites are still the game's own (a rider beyond the original edge appears when it reaches it); drawing those from game state is the next step.

Track designs: the design menu's SAVE and LOAD (which drive the Famicom Data Recorder on the real console) read and write a file, `designs.ebd` or `--designs file`; the file holds the 256-byte track design plus its header, so designs can be shared.

Higher frame rate: `--fps 120` (or 180, 240) keeps the game at its own 60 Hz and draws in-between pictures: each scanline's horizontal scroll and every sprite that is the same object in the two frames are moved part of the way (one frame of added latency). Objects that change slot or look are shown as in the newer frame.

Extra riders: `--riders N` (0-4) adds CPU riders that run the game's own rider physics, ramps, crashes and AI (each is swapped into a rider slot for one pass per frame, `c/extra_riders.inc`); they collide with the real riders (`--no-extra-collisions` turns that off; not with each other), and otherwise never change the game's own state. With `--widescreen`, riders (extra ones too) are drawn beyond the original screen edge.

Graphics mods: `python tools/chrbmp.py export orig/excitebike_us.nes tiles.bmp` writes all tiles as an editable 128x256 8-bit BMP (pixel values 0-3);
edit it in any indexed-colour editor and run `excitebike --chr-bmp tiles.bmp` (or `--chr file.chr` for a raw 8 KB file). `--palette file.pal` replaces the 64 colours
(192 bytes, RGB). The ROM and the repository are never modified.

Rules (mutators): `--rule name=value` or an `excitebike.cfg` next to the executable (see `excitebike.cfg.example`) change how the game plays without changing the ROM:
`jump_power`, `crash_pitch`, `overheat`, `max_speed` (percent). The defaults are the original game's values, and with the defaults the C game is frame-identical to the ROM (`tools/fulltest.py`).

`--press "frame=buttons,..."` sets the controller from that frame on (bit 0 A, 1 B, 2 Select, 3 Start, 4 Up, 5 Down, 6 Left, 7 Right).
The ROM supplies tables, graphics and sound data at run time; nothing from it is in this repository.

Packaging: `python tools/package.py --exe <built exe> --sdl-dll <SDL2.dll> --zip` writes `dist/excitebike/` (no ROM included).

Build: see `CMakeLists.txt`, or directly: `clang -O2 -o excitebike port/main.c port/ppu.c port/apu.c port/audiomod.c c/excitebike.c -I<SDL2>/include -L<SDL2>/lib/x64 -lSDL2`.

This layer is the stepping stone to the planned features (see `../docs/PORT_FEATURES.md`): widescreen, interpolation and more riders need the
game state as named structures and a renderer that reads them directly instead of PPU writes.

## Audio mods

`--audio-mod DIR` replaces the game's music and sound effects with WAV files (PCM 8/16-bit, mono/stereo, any rate). Name a file `<channel>_<request>.wav`
with the channel `music`, `pulse1`, `pulse2` or `noise` and the request byte the game sends in two hex digits (`music_01.wav`, `pulse1_04.wav`; see the request
bytes in `c/sound.inc`). A request that has a file is played from it instead of the original sound code; `music_*` files loop until the next music request.
Requests without a file still use the original synthesized sound. The engine tone (a continuous state, not a one-shot request) is not replaceable yet.

`engine.wav` in the same folder replaces the engine tone: it loops while an engine is running and its pitch follows the game's engine request (0.5x to 1.7x speed).
The original tone is silenced while the file is in use. Because the sound variables then differ, replays recorded with an audio mod are not comparable with replays recorded without it.

## Custom tracks and the track editor

`tools/editor/index.html` is a browser editor for track designs (open it through any local web server, e.g. `python -m http.server` in `tools/editor`; first run `python tools/ebdesign.py editor-data`, which reads your own ROM and writes the data file the editor needs, `data.js`).
It shows the track as the game draws it, lets you add, delete, reorder and repeat pieces, edit laps and Selection-B-only pieces, start from any built-in track, and saves `.ebd` files.
Tracks over 255 bytes use the extended format (`EBDES2`); the original design mode cannot hold them but the port plays them.

`--track N=file.ebd` replaces built-in track N (1-5) or the designed track (6) in the port; F6 reloads the files while the game runs (a track is read when its race starts).
The track script is the game's own (`tools/ebdesign.py` documents the format: laps, pieces and runs). `python tools/ebdesign.py dump file.ebd` prints a track; `export-builtin N out.ebd` writes a built-in track as a design you can edit.

## In-game options menu

Tab (or F1) opens a menu that pauses the game: extra riders, rider contact, top speed, jump power, crash pitch, overheating, picture width, frame rate and the sprite limit. Left/Right change a value at once;
SAVE SETTINGS writes `excitebike.cfg` (read at the next start). F6 reloads the track, tile, palette and audio mod files while the game runs.

## Custom music (.ebm songs)

Besides WAV files, `--audio-mod DIR` plays `song_XX.ebm` songs (XX = the music request byte in hex) through the APU, so the port's own synthesizer plays them: four voices (two pulses, triangle, noise) with free
pitch and note lengths. `python tools/ebmusic.py export DIR` writes the ROM's eight songs as editable .ebm text (the exported title song matches the original's pitches note for note);
`tools/editor/music.html` is a piano-roll editor for them. While a custom song plays, the game's sound effects keep pulse 1 and pulse 2 when they fire. Format: see `tools/ebmusic.py`.

## Editors

`python tools/editor/serve.py excitebike.nes` (or `editors.bat` in the packaged folder) opens three browser editors that read your own ROM and write the files the port loads:
`index.html` the track editor (`.ebd`), `tiles.html` the tile and palette editor (`.chr`, `.bmp`, `.pal`), `music.html` the piano-roll music editor (`song_XX.ebm`).
Start the port with `--track N=file.ebd --chr-bmp tiles.bmp --palette colors.pal --audio-mod DIR` (or just the ones you use) and press F6 to reload them without restarting.

## Level packs

The track editor can share levels: **Level packs** (title, author, description, tags), download/import `.ebpack.json` files, a local library with previews drawn from your own ROM, a community browser that reads `levels/index.json` from a GitHub repository,
and **Submit to community…**, which opens GitHub's web editor with the level filled in so it becomes a pull request (nothing is sent without your confirmation on GitHub). The port plays packs directly: `--track 1=level.ebpack.json`.
Format, rules and the PR check: `levels/README.md`, `tools/levelpack.py`.

A level pack may also contain tile changes, colour changes and a song (see `tools/levelpack.py`); `--track N=pack.ebpack.json` applies them all, so a pack is a complete one-file mod. `python tools/levelpack.py unpack pack.ebpack.json out.ebd --extras DIR` writes them as separate files.

`--watch` reloads track, tile, palette and audio files when they change; `--autostart` presses Start and A by itself to begin a race on track 1. The editors' **Play in port** buttons use both (`tools/editor/serve.py`).

`--long-designs` (or LONG DESIGNS in the menu, `long_designs=1` in the config) lets the in-game design editor record tracks longer than the original 236 bytes: finished bytes are moved out of the game's 256-byte buffer
into a host buffer as it fills up, the race streams the whole track, and SAVE writes an extended (`EBDES2`) design that LOAD and the track editor read back. It is off by default so the C game stays equal to the ROM;
`tests/test_longdesign.py` checks the buffer logic.

## Custom track pieces

Piece numbers 36-47 are free in the game's piece table. The track editor's **Custom pieces** panel designs them (a strip of tile columns, 12 tall; copy an existing piece and change it); they are stored in level packs (`"pieces"`) and
the port streams them like the game's own pieces. A piece's behaviour comes from the tiles it uses (the game reads ramps and surfaces from the tile numbers), so new shapes built from existing tiles play correctly;
new looks come from the tile editor (a pack can carry tiles too).

## Interpolation by object

For frame rates above 60 the port interpolates between game frames. The game reports each rider and shadow it draws (`HAL_EV_SPRITES`), so the in-between pictures move a rider by how far the game moved its origin, whatever OAM slot
or animation frame it uses in each frame (riders swap slots as they pass each other). Everything else still moves by OAM slot. `tests/test_interp.py` checks it.

## Starting the game like a normal program

`excitebike.exe` needs no arguments. Double-click it (or start it from anywhere): it works from its own folder, finds your ROM there (`excitebike.nes`, or any `.nes` with "excitebike" in its name, or `orig/excitebike_us.nes`),
opens a window with the game's title menu and races in **widescreen** (416 pixels wide; `--width 256` or `width=256` in `excitebike.cfg` gives the original picture). If no ROM is found it says so in a message box.
A `mods/audio` folder next to the program is loaded automatically. The Windows build has no console window; build it with `-Wl,/subsystem:windows -Wl,/entry:mainCRTStartup` (MSVC-style linker) or `-mwindows` (MinGW).
`excitebike-editors.exe` (built from `port/editors.c`, Windows) opens the browser editors by running `tools/editor/serve.py` with Python 3; `python tools/package.py --exe ... --editors-exe ...` puts both programs in `dist/excitebike/`.

## A private build that needs no ROM file

`python tools/build_exe.py --sdl-dir <SDL2 devel folder>` reads your own ROM files (`orig/excitebike_us.nes` and/or `orig/excitebike_eu.nes`) and builds `dist/Excitebike/`: a game program with the ROM data compiled in, the editors launcher, and an editors data file made from the ROM.
It runs from any folder with no `.nes` beside it; `--region eu` (or `region=eu` in `excitebike.cfg`) selects the PAL version when both ROMs were embedded. The result contains game data: it is for your own use. Never upload or share it
(`dist/` and `build/` are git-ignored, and the repository and its CI only ever build the version that reads a ROM file).

## Widescreen: nothing pops in

The game streams the track about 52 columns ahead of the left edge and brings CPU riders and objects in from just beyond the 256-pixel edge. On a wider picture those would appear out of nowhere in the middle of the screen.
With a wide picture (`--width`, the menu's WIDTH item, or the 416 default) the port therefore (1) streams a few extra track columns at the start of a race so the track ahead is real all the way to the picture's edge, (2) lets CPU riders enter from beyond the wide edge,
and (3) draws the obstacle and the banner that scroll in from the right from beyond the wide edge too. The track ring holds 64 columns, which is exactly 512 pixels, so 512 is the widest picture; wider monitors get side bars.
At width 256 none of this runs and the game is exactly the original (the differential tests check that).
