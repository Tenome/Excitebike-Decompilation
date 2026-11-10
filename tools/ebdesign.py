#!/usr/bin/env python3
"""Excitebike track designs: parse, edit and write them, read the built-in tracks, and export the data the browser editor needs.

A track (the built-in ones in ROM at $ED3A.. and a design at $05E0) is a byte stream:
  byte 0        laps
  then tokens:  0x00                end of track
                0x40|k, n          run: piece PIECE_OF_RUN[k] repeated n times (k=0 is the flat track; the table is at $F4C6)
                p  (bit 7 clear)   one piece p (0-35, 9 = the finish line, which ends the track: column lists at $F063/$F087; 0x30-0x33: markers such as the start gate)
                p | 0x80           the same, only used in Selection B (extra obstacles)
A design file (.ebd, written by the port) is "EBDES1" + 64 bytes of zero page from $60 + the 256 bytes of the design at $05E0.

  python tools/ebdesign.py dump <file.ebd | builtin:N>
  python tools/ebdesign.py export-builtin N out.ebd
  python tools/ebdesign.py editor-data [--ppu build/port/race.ppu]     writes tools/editor/data.js from the ROM (needs your own ROM)"""
import base64, json, os, struct, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
ROM_PATH = os.path.join(ROOT, 'orig', 'excitebike_us.nes')
MAGIC = b'EBDES1'
DESIGN_SIZE = 256

def load_rom(path=ROM_PATH):
    d = open(path, 'rb').read(); return d[16:16 + 0x4000], d[16 + 0x4000:16 + 0x6000]

def R(prg, a): return prg[a - 0xC000]

def builtin_track(prg, n):                              # n = 0..5: ROM scripts at $ED3A (tracks 1-5, then the design script)
    p = R(prg, 0xED3A + n) | R(prg, 0xED40 + n) << 8
    if p < 0xC000: return None
    return bytes(parse_end(prg, p))

def parse_end(prg, p):
    out = [R(prg, p)]; p += 1
    while True:
        b = R(prg, p); out.append(b); p += 1
        if b == 0 or b == 9: return out                  # piece 9 is the finish line: the track ends there (the game restarts the script for the next lap)
        if b & 0x40: out.append(R(prg, p)); p += 1

def parse(stream):
    """-> (laps, tokens); a token is ('run', k, n) or ('piece', p, b_only) or ('end',)"""
    laps = stream[0]; i = 1; toks = []
    while i < len(stream):
        b = stream[i]; i += 1
        if b == 0: toks.append(('end',)); break
        if b == 9: toks.append(('piece', 9, False)); break
        if b & 0x40:
            if i >= len(stream): break
            toks.append(('run', b & 0x0F, stream[i])); i += 1
        else: toks.append(('piece', b & 0x3F, bool(b & 0x80)))
    return laps, toks

def serialize(laps, toks):
    out = bytearray([laps])
    for t in toks:
        if t[0] == 'run': out += bytes([0x40 | t[1], t[2]])
        elif t[0] == 'piece': out.append(t[1] | (0x80 if t[2] else 0))
        else: out.append(0)
    if not toks or toks[-1] not in (('end',), ('piece', 9, False)): out.append(9)
    out.append(0)
    return bytes(out)

def read_ebd(path):
    d = open(path, 'rb').read()
    if d[:6] != MAGIC or len(d) < 6 + 64 + DESIGN_SIZE: raise ValueError('not an EBDES1 design file')
    return bytearray(d[6:70]), bytearray(d[70:70 + DESIGN_SIZE])

def write_ebd(path, stream, zp=None):
    if len(stream) > DESIGN_SIZE: raise ValueError('track stream is %d bytes; the game holds %d' % (len(stream), DESIGN_SIZE))
    zp = bytes(zp) if zp else bytes(64)
    open(path, 'wb').write(MAGIC + zp + bytes(stream).ljust(DESIGN_SIZE, b'\0'))

def describe(stream, prg=None):
    laps, toks = parse(stream); lines = ['laps %d' % laps]
    for t in toks:
        if t[0] == 'run': lines.append('  run  piece %-2d x%d' % (R(prg, 0xF4C6 + t[1]) if prg else t[1], t[2]))
        elif t[0] == 'piece': lines.append('  one  piece %-2d%s' % (t[1], '  (B only)' if t[2] else ''))
        else: lines.append('  end')
    return '\n'.join(lines)

def piece_columns(prg, idx):                           # column lists of a piece: [(start, [tiles...]), ...]; tiles fill buffer slots start..14
    p = R(prg, 0xF063 + idx) | R(prg, 0xF087 + idx) << 8; cols = []
    while True:
        s = R(prg, p)
        if s == 0: return cols
        n = 0x0F - s; cols.append((s, [R(prg, p + 1 + k) for k in range(n)])); p += 1 + n

def editor_data(ppu_path=None):
    prg, chr_ = load_rom()
    pal = list(range(16)); tilepal = {}
    if ppu_path and os.path.exists(ppu_path):
        d = open(ppu_path, 'rb').read(); vram, pal = d[:2048], list(d[2048:2080])
        votes = {}
        for nt in (0, 0x400):
            for row in range(30):
                for col in range(32):
                    t = vram[nt + row * 32 + col]; at = vram[nt + 960 + (row // 4) * 8 + col // 4]
                    q = (at >> (((row // 2) & 1) * 4 + ((col // 2) & 1) * 2)) & 3
                    votes.setdefault(t, [0, 0, 0, 0])[q] += 1
        tilepal = {t: v.index(max(v)) for t, v in votes.items()}
    pieces = [piece_columns(prg, i) for i in range(36)]
    return dict(chr=base64.b64encode(chr_).decode(), pal=pal, tilepal={str(k): v for k, v in tilepal.items()}, pieces=pieces,
                runs=[R(prg, 0xF4C6 + k) for k in range(16)], builtin=[list(builtin_track(prg, n) or []) for n in range(5)],
                canned=[list(parse_canned(prg, k)) for k in range(5)])

def parse_canned(prg, k):                              # design-menu macros ($F4F5/$F4FA): token streams for rough sections etc.
    p = R(prg, 0xF4F5 + k) | R(prg, 0xF4FA + k) << 8; out = []
    while R(prg, p) != 0: out.append(R(prg, p)); p += 1
    return out

if __name__ == '__main__':
    a = sys.argv[1:]
    if not a: sys.exit(__doc__)
    prg, _ = load_rom()
    if a[0] == 'dump':
        if a[1].startswith('builtin:'): s = builtin_track(prg, int(a[1][8:]) - 1)
        else: s = bytes(read_ebd(a[1])[1])
        print(describe(s, prg)); print('stream bytes:', len(s) if a[1].startswith('builtin') else len(serialize(*parse(s))))
    elif a[0] == 'export-builtin':
        write_ebd(a[2], builtin_track(prg, int(a[1]) - 1)); print('wrote', a[2])
    elif a[0] == 'editor-data':
        ppu = a[a.index('--ppu') + 1] if '--ppu' in a else os.path.join(ROOT, 'build', 'port', 'race.ppu')
        os.makedirs(os.path.join(ROOT, 'tools', 'editor'), exist_ok=True)
        open(os.path.join(ROOT, 'tools', 'editor', 'data.js'), 'w').write('window.EB_DATA = ' + json.dumps(editor_data(ppu)) + ';\n'); print('wrote tools/editor/data.js')
    else: sys.exit(__doc__)
