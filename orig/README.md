# Original ROMs (not in this repository)

Place your own dumps here. The tools read them to extract data (`assets/`) and to verify the rebuilt ROM.

| Version | File | Size | Notes |
|---|---|---|---|
| us | `excitebike_us.nes` | 24,592 bytes | Excitebike (Japan, USA), NTSC; NROM-128, 16 KB PRG + 8 KB CHR, NES 2.0 header |
| eu | `excitebike_eu.nes` | 24,592 bytes | Excitebike (Europe), PAL; identical except 17 timing-table bytes and header byte 12 |

SHA-1 that `python tools/build.py` must reproduce:

| Version | SHA-1 |
|---|---|
| us | `8e807f8aa465891affc51939687009b36943aade` |
| eu | `8ba688228cd9160ea691abd0168e81cc82b2a38c` |
