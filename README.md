# Excitebike: matching disassembly and native port (NES)

A work-in-progress **matching decompilation** of *Excitebike* (Nintendo, 1984/1985) for the Famicom/NES. The source is ca65 assembly that rebuilds each ROM **byte for byte**; the long-term goal is readable C source and a complete native PC port (Windows/Linux, no emulation) with extras such as widescreen, more CPU riders and a higher frame rate.

This repository contains no game files. You need your own ROMs.

| Version | ROM | Notes |
|---|---|---|
| `us` | Excitebike (Japan, USA) (En), NTSC | NROM-128: 16 KB PRG at `$C000`, 8 KB CHR, vertical mirroring |
| `eu` | Excitebike (Europe), PAL | same code; 17 timing-table bytes differ, header byte 12 = PAL |

| | |
|---|---|
| Code found | 11,299 of 16,384 PRG bytes in 216 routines (2,797 opcodes seen executing; the rest reached statically). The remaining 5 KB is data: tables, track pieces, text |
| Byte identity | `python tools/build.py --version us|eu` prints `MATCH` |
| Native build | `recomp/build_native.ps1` statically recompiles the classified code to C with [NESRecomp](https://github.com/mstan/nesrecomp); over 120,000 random-input frames the native build matched the interpreter hash for hash with 0 % of ROM cycles interpreted |
| Lifted to C | 40 routines in `c/excitebike.c`, each differential-tested against the original 6502 code on thousands of random states (`tools/difftest.py`) |
| Not done yet | the rest of the C lift, a PPU/APU-free runtime, the PC features (see `docs/ROADMAP.md`) |

The ByteMatch report counts **byte-exact assembly source**: instructions and `.incbin` data both count as matching, so the numbers start at 100 %. Progress from here is understanding: names, structured data, C.

## Building

```
# put your ROMs in orig/ (see orig/README.md); install cc65 (ca65 + ld65) and Python 3.10+
python tools/ebdis.py --version us     # extract assets/us/ from your ROM and (re)generate src/us/
python tools/build.py --version us     # ca65 + ld65, compares with orig/excitebike_us.nes; prints MATCH
python tools/report.py --version us    # verify, then write progress/us/report.json
# same with --version eu
```
cc65 is found through `--cc65 DIR`, `$CC65_DIR` or `PATH`. Edit `config/<ver>/*.json` (names, RAM names, hints), not the generated `src/`.

## Layout

| Path | Contents |
|---|---|
| `src/<ver>/` | generated ca65, one file per module (`boot`, `game_states`, `tape`, `riders`, `rider_draw`, `track_scripts`, `design_mode`, `track_render`, `sound`, ...) plus `excitebike.asm` (header, includes) and `hardware.inc` (PPU/APU registers and RAM names) |
| `config/<ver>/` | `coverage.json` (opcodes executed in play, PRG offsets), `names.json`, `ram.json`, `modules.json` (file split), `comments.json` (routine headers), `hints.json`; `config/excitebike.cfg` is the ld65 layout |
| `assets/<ver>/` | data extracted from your ROM (git-ignored) |
| `tools/` | `ebdis.py` tracing disassembler/emitter, `build.py`, `report.py`, `gapscan.py`, `sim6502.py` + `difftest.py` (lift verification), coverage tools (`mkroute.py`, `miss2cov.py`, `run_routes.sh`), `make_seeds.py` |
| `c/` | routines lifted to C (`excitebike.c/.h`) |
| `progress/<ver>/report.json` | objdiff-format report for ByteMatch (published by `.github/workflows/report.yml` as `us_report` / `eu_report`) |
| `recomp/` | native Windows build script |
| `docs/` | `NOTES.md` findings, `ROADMAP.md` port plan |
