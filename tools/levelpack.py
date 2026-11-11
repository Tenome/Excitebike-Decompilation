#!/usr/bin/env python3
"""Excitebike level packs: one JSON file per community level (`*.ebpack.json`), plus the folder index the editor's online browser reads.

A pack holds only the track script (our own data: laps, pieces and runs; see tools/ebdesign.py) and text. It never contains game graphics: the editor draws
previews from the viewer's own ROM. Format ("ebpack1"):
  { "format": "ebpack1", "id": "practice-hills", "title": "...", "author": "...", "description": "...", "tags": ["jumps"],
    "license": "CC0-1.0", "created": "2026-11-10", "laps": 2, "track": "<base64 of the track script bytes>",
    "tiles":   [ {"n": 315, "d": "<base64 of the 16 bytes of tile 315>"} ],        optional: only the tiles that differ from the ROM
    "palette": [ {"i": 22, "rgb": "ff8800"} ],                                      optional: master palette colours that differ from the default
    "song":    {"request": "01", "ebm": "EBM1 ..."} }                               optional: a replacement song (tools/ebmusic.py format)
The optional parts are changes, never the game's own data: tiles are stored as differences from the ROM, so a pack that changes nothing carries nothing.

  python tools/levelpack.py pack  track.ebd out.ebpack.json --title T --author A [--description D] [--tags a,b] [--id slug] [--tiles tiles.chr] [--palette colors.pal] [--song song_01.ebm --request 01]
  python tools/levelpack.py unpack pack.ebpack.json out.ebd [--extras DIR]   (the file the game's LOAD and `--track N=` use; extras = tiles.chr, colors.pal, song_XX.ebm)
  python tools/levelpack.py validate levels/                              (every pack in the folder; exit 1 on any problem)
  python tools/levelpack.py index levels/                                 (writes levels/index.json for the online browser)"""
import base64, datetime, glob, json, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ebdesign

LIMITS = dict(title=60, author=40, description=600, tag=24, tags=8, track_bytes=2000, file_bytes=64000, song_chars=20000)
LICENSES = ('CC0-1.0', 'CC-BY-4.0', 'MIT')
SLUG = re.compile(r'^[a-z0-9][a-z0-9-]{1,47}$')

def slugify(t): return re.sub(r'-+', '-', re.sub(r'[^a-z0-9]+', '-', t.lower())).strip('-')[:48] or 'level'

def make_pack(stream, title, author, description='', tags=(), license='CC0-1.0', pid=None):
    laps, toks = ebdesign.parse(stream)
    clean = ebdesign.serialize(laps, toks)
    return dict(format='ebpack1', id=pid or slugify(title), title=title, author=author, description=description, tags=list(tags), license=license,
                created=datetime.date.today().isoformat(), laps=laps, track=base64.b64encode(clean).decode())

def problems(p, filename=None):
    """-> list of strings describing what is wrong with a pack (empty = valid)"""
    out = []
    if not isinstance(p, dict) or p.get('format') != 'ebpack1': return ['format must be "ebpack1"']
    def text(k, mx, req=True):
        v = p.get(k, '')
        if not isinstance(v, str): out.append('%s must be text' % k)
        elif req and not v.strip(): out.append('%s is required' % k)
        elif len(v) > mx: out.append('%s is longer than %d characters' % (k, mx))
        elif re.search(r'[<>\x00-\x08\x0b\x0c\x0e-\x1f]', v): out.append('%s contains < > or control characters' % k)
    text('title', LIMITS['title']); text('author', LIMITS['author']); text('description', LIMITS['description'], False)
    if not SLUG.match(str(p.get('id', ''))): out.append('id must be 2-48 characters: a-z, 0-9 and "-"')
    elif filename and os.path.basename(filename) != p['id'] + '.ebpack.json': out.append('file name must be %s.ebpack.json' % p['id'])
    if p.get('license') not in LICENSES: out.append('license must be one of ' + ', '.join(LICENSES))
    t = p.get('tags', [])
    if not isinstance(t, list) or len(t) > LIMITS['tags'] or any(not isinstance(x, str) or not re.match(r'^[a-z0-9 -]{1,%d}$' % LIMITS['tag'], x) for x in t): out.append('tags: up to %d, each a-z 0-9 space or - (max %d characters)' % (LIMITS['tags'], LIMITS['tag']))
    out += extras_problems(p)
    try: raw = base64.b64decode(p.get('track', ''), validate=True)
    except Exception: return out + ['track is not valid base64']
    if not 3 <= len(raw) <= LIMITS['track_bytes']: return out + ['track must be 3-%d bytes' % LIMITS['track_bytes']]
    laps = raw[0]
    if not 1 <= laps <= 9: out.append('laps must be 1-9')
    if p.get('laps') != laps: out.append('"laps" must equal the first byte of the track')
    i = 1; ended = False
    while i < len(raw):
        b = raw[i]; i += 1
        if b == 0: ended = True; break
        if b == 9: ended = True; break
        if b & 0x40:
            if i >= len(raw) or not 1 <= raw[i] <= 127: out.append('a run needs a count of 1-127'); break
            i += 1
        elif (b & 0x3F) >= 36 and (b & 0x3F) not in (0x30, 0x31, 0x32, 0x33): out.append('unknown piece %d' % (b & 0x3F)); break
    if not ended: out.append('the track must end with the finish line (piece 9)')
    elif raw[i - 1] != 9: out.append('the track must end with the finish line (piece 9)')
    if i < len(raw) and any(raw[i:]) and not out: out.append('extra data after the track end')
    return out

def extras_problems(p):
    out = []
    t = p.get('tiles')
    if t is not None:
        if not isinstance(t, list) or len(t) > 512: out.append('tiles: a list of up to 512 entries')
        else:
            for e in t:
                try: ok = isinstance(e, dict) and 0 <= e['n'] < 512 and len(base64.b64decode(e['d'], validate=True)) == 16
                except Exception: ok = False
                if not ok: out.append('tiles: each entry needs n (0-511) and d (base64 of 16 bytes)'); break
    c = p.get('palette')
    if c is not None:
        if not isinstance(c, list) or len(c) > 64: out.append('palette: a list of up to 64 entries')
        elif any(not (isinstance(e, dict) and isinstance(e.get('i'), int) and 0 <= e['i'] < 64 and isinstance(e.get('rgb'), str) and re.match(r'^[0-9a-f]{6}$', e['rgb'])) for e in c): out.append('palette: each entry needs i (0-63) and rgb (6 lowercase hex digits)')
    sg = p.get('song')
    if sg is not None:
        if not (isinstance(sg, dict) and isinstance(sg.get('request'), str) and re.match(r'^[0-9a-f]{2}$', sg['request']) and sg['request'] != '00' and isinstance(sg.get('ebm'), str)): out.append('song: needs request (2 hex digits) and ebm (text)')
        elif len(sg['ebm']) > LIMITS['song_chars'] or not sg['ebm'].startswith('EBM1'): out.append('song: ebm must start with EBM1 and be at most %d characters' % LIMITS['song_chars'])
        elif re.search(r'[\x00-\x08\x0b\x0c\x0e-\x1f<>]', sg['ebm']): out.append('song: ebm contains control characters or < >')
    for k in p:
        if k not in KEYS: out.append('unknown field ' + k)
    return out

KEYS = ('format', 'id', 'title', 'author', 'description', 'tags', 'license', 'created', 'laps', 'track', 'tiles', 'palette', 'song')

DEFAULT_PAL = [(84,84,84),(0,30,116),(8,16,144),(48,0,136),(68,0,100),(92,0,48),(84,4,0),(60,24,0),(32,42,0),(8,58,0),(0,64,0),(0,60,0),(0,50,60),(0,0,0),(0,0,0),(0,0,0),(152,150,152),(8,76,196),(48,50,236),(92,30,228),(136,20,176),(160,20,100),(152,34,32),(120,60,0),(84,90,0),(40,114,0),(8,124,0),(0,118,40),(0,102,120),(0,0,0),(0,0,0),(0,0,0),(236,238,236),(76,154,236),(120,124,236),(176,98,236),(228,84,236),(236,88,180),(236,106,100),(212,136,32),(160,170,0),(116,196,0),(76,208,32),(56,204,108),(56,180,204),(60,60,60),(0,0,0),(0,0,0),(236,238,236),(168,204,236),(188,188,236),(212,178,236),(236,174,236),(236,174,212),(236,180,176),(228,196,144),(204,210,120),(180,222,120),(168,226,144),(152,226,180),(160,214,228),(160,162,160),(0,0,0),(0,0,0)]

def add_extras(pack, chr_new=None, chr_rom=None, pal_new=None, song_text=None, song_request=None):
    """Attach tile differences (against the ROM's 8 KB CHR), changed master colours (a 192-byte RGB list) and a song to a pack dict."""
    if chr_new is not None:
        pack['tiles'] = [dict(n=n, d=base64.b64encode(chr_new[n*16:n*16+16]).decode()) for n in range(512) if chr_new[n*16:n*16+16] != chr_rom[n*16:n*16+16]]
        if not pack['tiles']: del pack['tiles']
    if pal_new is not None:
        pack['palette'] = [dict(i=i, rgb='%02x%02x%02x' % tuple(pal_new[i*3:i*3+3])) for i in range(64) if tuple(pal_new[i*3:i*3+3]) != DEFAULT_PAL[i]]
        if not pack['palette']: del pack['palette']
    if song_text: pack['song'] = dict(request='%02x' % song_request, ebm=song_text)
    return pack

def extract_extras(p, outdir, rom_chr=None):
    """Write a pack's tiles (applied to the ROM's CHR, if given), palette and song as the files the port and editors use."""
    os.makedirs(outdir, exist_ok=True)
    if p.get('tiles') and rom_chr:
        c = bytearray(rom_chr)
        for e in p['tiles']: c[e['n']*16:e['n']*16+16] = base64.b64decode(e['d'])
        open(os.path.join(outdir, 'tiles.chr'), 'wb').write(bytes(c))
    if p.get('palette'):
        pal = [list(c) for c in DEFAULT_PAL]
        for e in p['palette']: pal[e['i']] = [int(e['rgb'][k:k+2], 16) for k in (0, 2, 4)]
        open(os.path.join(outdir, 'colors.pal'), 'wb').write(bytes(v for c in pal for v in c))
    if p.get('song'): open(os.path.join(outdir, 'song_%s.ebm' % p['song']['request']), 'w', newline='\n').write(p['song']['ebm'])

def load_pack(path):
    return json.load(open(path, encoding='utf-8'))

def main(a):
    if not a: sys.exit(__doc__)
    if a[0] == 'pack' and len(a) >= 3:
        opt = lambda k, d='': a[a.index(k) + 1] if k in a else d
        _, stream = (None, bytes(ebdesign.read_ebd(a[1])[1]))
        laps, toks = ebdesign.parse(stream); stream = ebdesign.serialize(laps, toks)
        p = make_pack(stream, opt('--title', 'Untitled'), opt('--author', 'anonymous'), opt('--description'), [t for t in opt('--tags').split(',') if t], opt('--license', 'CC0-1.0'), opt('--id') or None)
        if '--tiles' in a or '--palette' in a or '--song' in a:
            rom_chr = ebdesign.load_rom()[1]
            add_extras(p, open(opt('--tiles'), 'rb').read() if '--tiles' in a else None, rom_chr, open(opt('--palette'), 'rb').read() if '--palette' in a else None,
                       open(opt('--song')).read() if '--song' in a else None, int(opt('--request', '01'), 16))
        e = problems(p)
        if e: sys.exit('pack is not valid:\n  ' + '\n  '.join(e))
        open(a[2], 'w', encoding='utf-8', newline='\n').write(json.dumps(p, indent=2, ensure_ascii=False) + '\n'); print('wrote', a[2])
    elif a[0] == 'unpack' and len(a) == 3:
        p = load_pack(a[1]); e = problems(p)
        if e: sys.exit('pack is not valid:\n  ' + '\n  '.join(e))
        ebdesign.write_ebd(a[2], base64.b64decode(p['track'])); print('wrote', a[2])
        if '--extras' in a:
            try: rom_chr = ebdesign.load_rom()[1]
            except Exception: rom_chr = None
            extract_extras(p, a[a.index('--extras') + 1], rom_chr); print('extras written to', a[a.index('--extras') + 1])
    elif a[0] in ('validate', 'index') and len(a) == 2:
        files = sorted(glob.glob(os.path.join(a[1], '*.ebpack.json'))); bad = 0; items = []; seen = set()
        for f in files:
            if os.path.getsize(f) > LIMITS['file_bytes']: print(f, ': file larger than', LIMITS['file_bytes'], 'bytes'); bad += 1; continue
            try: p = load_pack(f)
            except Exception as ex: print(f, ': not valid JSON (%s)' % ex); bad += 1; continue
            e = problems(p, f)
            if isinstance(p, dict) and p.get('id') in seen: e.append('duplicate id')
            if e: bad += 1; print(f, ':', '; '.join(e)); continue
            seen.add(p['id']); items.append({k: p[k] for k in ('id', 'title', 'author', 'description', 'tags', 'license', 'created', 'laps', 'track', 'tiles', 'palette', 'song') if k in p})
        if a[0] == 'index' and not bad:
            open(os.path.join(a[1], 'index.json'), 'w', encoding='utf-8', newline='\n').write(json.dumps(dict(format='ebindex1', levels=items), separators=(',', ':'), ensure_ascii=False) + '\n'); print('index.json:', len(items), 'levels')
        elif not bad: print(len(files), 'pack(s) valid')
        sys.exit(1 if bad else 0)
    else: sys.exit(__doc__)

if __name__ == '__main__': main(sys.argv[1:])
