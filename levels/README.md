# Community levels

Custom Excitebike tracks made with the track editor (`tools/editor/index.html`). Each level is one small JSON file, `<id>.ebpack.json`.
A level contains only the track script (laps, pieces and runs) and text: no game graphics and no ROM data. The editor draws previews from the viewer's own ROM.

## Play a level

* In the editor: **Community levels**, set this repository, **Load**, then **Open** or **Add to library**.
* Or download a file and run the port with `--track 1=<file>.ebpack.json` (it replaces built-in track 1; F6 reloads it while the game runs).
* To get a design file for the game's own LOAD menu: `python tools/levelpack.py unpack <file>.ebpack.json designs.ebd` (levels over 255 bytes need the port).

## Submit a level

1. Build it in the track editor and fill in the title, author, description and tags under **Level packs**.
2. Press **Submit to community…**. GitHub opens with your level filled in; it offers to fork the repository and open a pull request. Nothing is sent until you confirm on GitHub.
   (Alternatively press **Download pack** and add the file to `levels/` yourself.)
3. A check runs on the pull request (`python tools/levelpack.py validate levels`). It must pass before a maintainer merges.

### Rules

* File name = `<id>.ebpack.json`; id is 2-48 characters of `a-z`, `0-9`, `-`.
* Title up to 60 characters, author up to 40, description up to 600, up to 8 tags (`a-z`, `0-9`, space, `-`). No `<` or `>`.
* A level may also carry changed tiles, changed colours and a replacement song (checkboxes under **Level packs**). Only the differences from the game are stored; a pack never contains the game's own graphics or music.
* A level may define custom track pieces (numbers 36-47, up to 12, each at most 400 bytes) from tiles; the track may then use them.
* The track must be valid, end with the finish line, and be at most 2000 bytes.
* License is `CC0-1.0`, `CC-BY-4.0` or `MIT`. By submitting you confirm you made the level or have the right to share it.
* Do not edit `index.json`; it is rebuilt automatically after a merge.
* Levels that copy the game's built-in tracks, or that are offensive or misleading, are not accepted.

`levels/index.json` is what the editor's community browser reads (`https://raw.githubusercontent.com/Tenome/Excitebike-Decompilation/master/levels/index.json`; the editor fills this in from the repository name).
