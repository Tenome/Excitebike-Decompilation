# Native port: options, mutators and mod support (design)

Status: design only. Nothing here is implemented yet. The point of writing it now is to decide what the C lift has to
expose, so the routines lifted today do not have to be redone later.

## Architecture the options depend on

```
 platform layer (SDL3 or similar)   window, audio device, input, files, config
        |
 renderer (own PPU-free)            tiles + sprites drawn from asset tables, any resolution, any frame rate
 audio    (own APU-free)            sound-engine output or replacement streams
        |
 game logic (lifted C)              the routines in c/excitebike.c, running at the original 60 Hz tick
        |
 game state (plain structs)         riders[N], track, scroll, timers  (no 2 KB RAM image)
```

Today the lifted C still reads and writes the 2 KB RAM image (`RAM(0x90 + x)`). That is right for proving each
routine equal to the original, and wrong for most options below. The plan is two steps per routine: first lift
byte-for-byte (done for 59 routines), then, once the surrounding code is lifted, replace the `RAM()` accesses with
named struct fields. The difftest keeps working across that step because the struct can be mapped back onto the RAM
image for comparison.

## Options, in the order they are worth building

| Option | What it needs | Difficulty |
|---|---|---|
| Frame rate above 60 | Logic stays at 60 Hz. The renderer interpolates rider position, scroll and sprites between two logic states. Needs the renderer to read positions from state, not from OAM. | Medium |
| Resolution scaling, pixel-perfect or filtered | Renderer only. Integer scale, CRT filter and aspect options. | Easy |
| Widescreen | The track is one-dimensional data, so extra columns to the right are available. The renderer needs a wider tile window. The original streams one column at a time into a 64-column ring (`DrawTrackColumn`, `TrackRenderUpdate`), so the stream must run further ahead. Sprites that appear or vanish at the screen edge need checking. | Medium to hard |
| More CPU riders | The four rider slots are four-element zero-page arrays with fixed offsets, and lane, collision and sprite code assume four. Needs `riders[N]` structs and loops over N. The lane count (5) limits how many fit side by side, so riders share lanes and the overlap test must handle it. Needs the unlimited sprite budget of the own renderer. | Hard |
| Mutators (see below) | Constants pulled out of the routines into a `Rules` struct. | Easy once the routine is lifted |
| Custom tracks | Track pieces, the 24-slot design format and the design-mode loader are already data. Add a file loader and saver for designs (replaces the tape and backup-RAM path). A longer track needs the position counters (8-bit pieces) widened. | Medium |
| Custom graphics (tiles, sprites, backgrounds) | The renderer reads from an asset table. A mod folder with PNG sheets overrides entries by name. The original CHR is extracted from the user's own ROM at first run. | Medium |
| Custom music and sound | The sound engine is a tracker-like player over note tables. Options: keep it for the original tunes, add stream playback (OGG/WAV) overrides by sound-request number, or a new music format. | Medium |
| Rebinding and gamepads | Platform layer only. | Easy |
| Replays and ghosts | The game is deterministic (one RNG, one input byte per rider per frame), so a replay is the input log plus the seed. A ghost rider is a recorded rider-0 input stream driving an extra rider. | Easy to medium |
| Netplay | Same determinism helps, but it needs the logic to be a pure function of state and input. | Later |

## Mutator ideas (all rule changes, no new assets)

- Engine: top speed, acceleration, turbo heat gain and cool-down rate, no overheating, infinite turbo.
- Physics: gravity, jump power, landing tolerance, crash threshold on landing pitch, bounce on bumps.
- Riders: CPU count, CPU skill (speed class table, lane-change rate), rubber-banding on or off, handicaps for rider 0.
- Race: lap-free point-to-point or endless track, time limit, random track every race, mirrored track, reverse direction.
- Hazards: collisions on or off, falling riders block the lane, oil or mud pieces added to random tracks.
- Fun: low gravity, double speed, ghost riders that pass through each other, big jumps only.

Each mutator maps to a field of one `Rules` struct that the lifted routines read instead of literals such as `0xAF`
(jump launch speed bias), `0x0F` (initial jump arc), `0x0D` (crash pitch) or the `Data_C0xx` speed tables. The difftest runs
with the default `Rules`, so the default behavior stays provably the original.

## Configuration

One text file next to the executable, plus a `mods/` folder. Example in `config/port_options.example.toml`.
Command-line flags override the file. Options that change the rules (mutators, rider count) are stored in replays so a
replay always plays back with the rules it was recorded with.

## Mod folder layout

```
mods/<name>/
  mod.toml            name, version, which parts it replaces
  tracks/*.ebt        track design files (24 pieces per slot, plus title)
  graphics/*.png      named sheets: riders, tiles, hud, font, title
  audio/*.ogg         replacements keyed by sound request: music_title, music_race, sfx_jump, ...
  rules.toml          mutator overrides
```

No game data ships with the repo. The port reads the user's own ROM once, extracts CHR and data tables into a cache
folder, and loads mods on top.

## Order of work

1. Finish the byte-exact lift of the pure routines (about 70 left).
2. Platform layer and own renderer for the title and race screens, driven by the recompiled game, so there is
   something to look at while the logic is lifted.
3. Replace RAM accesses with state structs, one module at a time.
4. Frame-rate interpolation and scaling.
5. Widescreen and rider count.
6. Track files, graphics overrides, audio overrides, mutators.

## Risks

- Widescreen and more riders both touch code the original written around the NES limits (256 px, 8 sprites per
  line, four-element arrays). Expect real rewrites there, verified by playing, not by the difftest.
- Rendering with an own renderer means matching the original look. Test by comparing frames with the recompiled
  build at 1x.
- The sound engine has not been read yet. Custom-music support depends on what it turns out to do.
