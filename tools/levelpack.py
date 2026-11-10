#!/usr/bin/env python3
"""Excitebike level packs: one JSON file per community level (`*.ebpack.json`), plus the folder index the editor's online browser reads.

A pack holds only the track script (our own data: laps, pieces and runs; see tools/ebdesign.py) and text. It never contains game graphics: the editor draws
previews from the viewer's own ROM. Format ("ebpack1"):
  { "format": "ebpack1", "id": "practice-hills", "title": "...", "author": "...", "description": "...", "tags": ["jumps"],
    "license": "CC0-1.0", "created": "2026-11-10", "laps": 2, "track": "<base64 of the track script bytes>" }

  python tools/levelpack.py pack  track.ebd out.ebpack.json --title T --author A [--description D] [--tags a,b] [--id slug]
  python tools/levelpack.py unpack pack.ebpack.json out.ebd              (the file the game's LOAD and `--track N=` use)
  python tools/levelpack.py validate levels/                              (every pack in the folder; exit 1 on any problem)
  python tools/levelpack.py index levels/                                 (writes levels/index.json for the online browser)"""
import base64, datetime, glob, json, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ebdesign

LIMITS = dict(title=60, author=40, description=600, tag=24, tags=8, track_bytes=2000, file_bytes=8000)
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

def load_pack(path):
    return json.load(open(path, encoding='utf-8'))

def main(a):
    if not a: sys.exit(__doc__)
    if a[0] == 'pack' and len(a) >= 3:
        opt = lambda k, d='': a[a.index(k) + 1] if k in a else d
        _, stream = (None, bytes(ebdesign.read_ebd(a[1])[1]))
        laps, toks = ebdesign.parse(stream); stream = ebdesign.serialize(laps, toks)
        p = make_pack(stream, opt('--title', 'Untitled'), opt('--author', 'anonymous'), opt('--description'), [t for t in opt('--tags').split(',') if t], opt('--license', 'CC0-1.0'), opt('--id') or None)
        e = problems(p)
        if e: sys.exit('pack is not valid:\n  ' + '\n  '.join(e))
        open(a[2], 'w', encoding='utf-8', newline='\n').write(json.dumps(p, indent=2, ensure_ascii=False) + '\n'); print('wrote', a[2])
    elif a[0] == 'unpack' and len(a) == 3:
        p = load_pack(a[1]); e = problems(p)
        if e: sys.exit('pack is not valid:\n  ' + '\n  '.join(e))
        ebdesign.write_ebd(a[2], base64.b64decode(p['track'])); print('wrote', a[2])
    elif a[0] in ('validate', 'index') and len(a) == 2:
        files = sorted(glob.glob(os.path.join(a[1], '*.ebpack.json'))); bad = 0; items = []; seen = set()
        for f in files:
            if os.path.getsize(f) > LIMITS['file_bytes']: print(f, ': file larger than', LIMITS['file_bytes'], 'bytes'); bad += 1; continue
            try: p = load_pack(f)
            except Exception as ex: print(f, ': not valid JSON (%s)' % ex); bad += 1; continue
            e = problems(p, f)
            if isinstance(p, dict) and p.get('id') in seen: e.append('duplicate id')
            if e: bad += 1; print(f, ':', '; '.join(e)); continue
            seen.add(p['id']); items.append({k: p[k] for k in ('id', 'title', 'author', 'description', 'tags', 'license', 'created', 'laps', 'track')})
        if a[0] == 'index' and not bad:
            open(os.path.join(a[1], 'index.json'), 'w', encoding='utf-8', newline='\n').write(json.dumps(dict(format='ebindex1', levels=items), separators=(',', ':'), ensure_ascii=False) + '\n'); print('index.json:', len(items), 'levels')
        elif not bad: print(len(files), 'pack(s) valid')
        sys.exit(1 if bad else 0)
    else: sys.exit(__doc__)

if __name__ == '__main__': main(sys.argv[1:])
