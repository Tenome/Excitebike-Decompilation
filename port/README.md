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

`--press "frame=buttons,..."` sets the controller from that frame on (bit 0 A, 1 B, 2 Select, 3 Start, 4 Up, 5 Down, 6 Left, 7 Right).
The ROM supplies tables, graphics and sound data at run time; nothing from it is in this repository.

Build: see `CMakeLists.txt`, or directly: `clang -O2 -o excitebike port/main.c port/ppu.c port/apu.c c/excitebike.c -I<SDL2>/include -L<SDL2>/lib/x64 -lSDL2`.

This layer is the stepping stone to the planned features (see `../docs/PORT_FEATURES.md`): widescreen, interpolation and more riders need the
game state as named structures and a renderer that reads them directly instead of PPU writes.
