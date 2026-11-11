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
