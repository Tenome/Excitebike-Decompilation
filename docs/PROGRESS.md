# Progress reports (ByteMatch)

[ByteMatch](https://bytematch.dev/) shows the project's progress. It imports the project's decomp.dev history (this project has none) and reads the CI runs on `master` for artifacts named `<VERSION>_report`.
Until a CI run has produced them, the project page says "No progress reports yet".

## What is published

| Artifact | File | Meaning |
|---|---|---|
| `us_report`, `eu_report` | `progress/us/report.json`, `progress/eu/report.json` | the assembly source rebuilds the ROM byte for byte: every routine and data run counts as matching |
| `us_c_report`, `eu_c_report` | `progress/us_c/report.json`, `progress/eu_c/report.json` | C lifting: a routine is 100 % when its C passes the differential test against the original 6502 code, 50 % when it exists as C but is not individually tested, 0 % otherwise |

The reports hold routine names, addresses, sizes and percentages only; there are no game bytes in them. The ROMs cannot be on GitHub, so the reports are generated on your machine and committed;
the workflow `.github/workflows/report.yml` checks them and uploads them as the artifacts above on every push to `master`.

## Refreshing them

```
python tools/build.py --version us            # must print MATCH (also --version eu)
python tools/report.py --version us           # progress/us/report.json   (also eu)
python tools/difftest.py --version us --json config/us/verified.json     # which routines pass (a few minutes; also eu with fewer runs)
python tools/report.py --version us --c       # progress/us_c/report.json (also eu)
git add progress config && git commit -m "Refresh progress reports" && git push origin master
```

Then open the Actions tab: the "Progress report" run publishes the artifacts, and ByteMatch picks them up within a few minutes of a successful run on `master`.

## How a routine earns 100 % in the C report

A routine counts as verified when `tools/difftest.py` runs the original 6502 routine and its C twin on the same random machine states (RAM, registers, the cassette/PPU/APU inputs) and finds the same RAM, the same result registers and the same ordered
hardware writes. A test counts only if enough runs completed (the original code can run off into data on impossible random states; those runs are skipped and a test with too few compared runs is reported as `TOO FEW COMPLETED RUNS`).

Details worth knowing:

* **Small helpers and the track-script handlers** (`V_ts_op_*`, `V_lane_piece_open`, `V_music_length`, ...) are exported with a `V_` prefix in `c/excitebike.c` and `c/sound.inc` only so the test can reach them.
* **The data-recorder (tape) code** is tested with a scripted cassette input: the test feeds the same sequence of `$4016` values to both sides (`io_seq` in `tools/sim6502.py` and `g_io_seq` in `c/excitebike.c`), including valid tape blocks with good and bad checksums. `TapeLoadDesigns` also needs the NMI to clear `PpuUpdateIndex`;
  both sides treat a read of `$2002` as the point where an NMI would have done that (`clear_on_status` / `g_clear_on_status`). The long write routines run only a few random states because the Python simulator needs millions of instructions for each.
* **`PpuBufferAdvance`** is verified below the buffer-full mark only. At the full mark the original pops two return addresses and returns into garbage; the C code terminates the buffer instead (documented in `c/excitebike.c`). The game never queues that much text.
* **`RiderState0Racing`** is a bare `rts` in the original; its C twin is an empty function.
* **Code that sits in front of a routine's entry point** (`Loc_FA4F`, `Loc_FBFF`) belongs to the same C function as the routine after it (`SoundPulse2TriangleSfx`, `SoundNoiseSfx`); `INSIDE` in `tools/report.py` credits it to that routine's test. `$C656` is the shared tail of the two pulse writers and is exercised through them.
