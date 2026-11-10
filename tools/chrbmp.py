#!/usr/bin/env python3
"""Export the graphics (CHR) of your ROM as an editable indexed BMP and turn an edited BMP back into CHR data.
  python tools/chrbmp.py export orig/excitebike_us.nes tiles.bmp      # 128x256 8-bit BMP: pattern table 0 on top, table 1 below;
                                                                       # 16 tiles per row, pixel values 0-3 (palette index = colour number)
  python tools/chrbmp.py import tiles.bmp tiles.chr                   # back to 8 KB CHR (check: export then import gives the original bytes)
The native port loads such a BMP with `--chr-bmp tiles.bmp`, so tiles and sprites can be redrawn without touching the ROM.
The BMP palette only helps editing (greys); the in-game colours come from the game's palettes."""
import struct, sys

def chr_from_rom(path):
    d = open(path, 'rb').read()
    assert d[:4] == b'NES\x1a', 'not an iNES file'
    prg = d[4] * 0x4000
    return d[16 + prg:16 + prg + d[5] * 0x2000]

def chr_to_pixels(chr_data):
    w, h = 128, 256
    px = bytearray(w * h)
    for table in range(2):
        for tile in range(256):
            base = table * 0x1000 + tile * 16
            tx, ty = tile % 16, tile // 16 + table * 16
            for row in range(8):
                lo, hi = chr_data[base + row], chr_data[base + 8 + row]
                for c in range(8):
                    bit = 7 - c
                    px[(ty * 8 + row) * w + tx * 8 + c] = ((lo >> bit) & 1) | (((hi >> bit) & 1) << 1)
    return px

def pixels_to_chr(px):
    w = 128
    out = bytearray(0x2000)
    for table in range(2):
        for tile in range(256):
            base = table * 0x1000 + tile * 16
            tx, ty = tile % 16, tile // 16 + table * 16
            for row in range(8):
                lo = hi = 0
                for c in range(8):
                    v = px[(ty * 8 + row) * w + tx * 8 + c] & 3
                    lo = (lo << 1) | (v & 1); hi = (hi << 1) | (v >> 1)
                out[base + row] = lo; out[base + 8 + row] = hi
    return bytes(out)

def write_bmp(path, px, w=128, h=256):
    pal = [(0x00, 0x00, 0x00), (0x70, 0x70, 0x70), (0xB0, 0xB0, 0xB0), (0xFF, 0xFF, 0xFF)]
    rowsize = (w + 3) & ~3
    data = b''.join(bytes(px[(h - 1 - y) * w:(h - y) * w]) + bytes(rowsize - w) for y in range(h))
    pal_bytes = b''.join(bytes([b, g, r, 0]) for r, g, b in pal) + bytes(4 * 252)
    off = 14 + 40 + len(pal_bytes)
    hdr = b'BM' + struct.pack('<IHHI', off + len(data), 0, 0, off)
    info = struct.pack('<IiiHHIIiiII', 40, w, h, 1, 8, 0, len(data), 2835, 2835, 256, 4)
    open(path, 'wb').write(hdr + info + pal_bytes + data)

def read_bmp(path):
    d = open(path, 'rb').read()
    off = struct.unpack('<I', d[10:14])[0]; w, h = struct.unpack('<ii', d[18:26]); bpp = struct.unpack('<H', d[28:30])[0]
    assert bpp == 8 and w == 128 and abs(h) == 256, 'expected a 128x256 8-bit BMP'
    rowsize = (w + 3) & ~3; rows = []
    for y in range(abs(h)): rows.append(d[off + y * rowsize: off + y * rowsize + w])
    if h > 0: rows.reverse()
    return bytearray(b''.join(rows))

if __name__ == '__main__':
    if len(sys.argv) == 4 and sys.argv[1] == 'export':
        write_bmp(sys.argv[3], chr_to_pixels(chr_from_rom(sys.argv[2]))); print('wrote', sys.argv[3])
    elif len(sys.argv) == 4 and sys.argv[1] == 'import':
        open(sys.argv[3], 'wb').write(pixels_to_chr(read_bmp(sys.argv[2]))); print('wrote', sys.argv[3])
    else:
        sys.exit(__doc__)
