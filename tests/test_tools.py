#!/usr/bin/env python3
"""Tests for the track, music and level-pack tools. ROM-dependent tests are skipped when orig/excitebike_us.nes is missing.
  python tests/test_tools.py"""
import base64, json, os, sys, tempfile, unittest
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ebdesign, ebmusic, levelpack
ROM = os.path.join(ROOT, 'orig', 'excitebike_us.nes'); HAVE_ROM = os.path.exists(ROM)

def sample_stream(laps=2):
    toks = [('run', 0, 16), ('piece', 0x30, False), ('run', 0, 8), ('piece', 7, False), ('run', 0, 4), ('piece', 8, True), ('piece', 0x31, False), ('piece', 9, False)]
    return ebdesign.serialize(laps, toks)

class Design(unittest.TestCase):
    def test_roundtrip(self):
        s = sample_stream(); laps, toks = ebdesign.parse(s)
        self.assertEqual(laps, 2); self.assertEqual(ebdesign.serialize(laps, toks), s)
        self.assertEqual(toks[-1], ('piece', 9, False)); self.assertIn(('piece', 8, True), toks)
    def test_missing_finish_is_added(self):
        s = ebdesign.serialize(1, [('run', 0, 5)]); self.assertEqual(list(s[-2:]), [9, 0])
    def test_ebd_file(self):
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, 'a.ebd'); ebdesign.write_ebd(p, sample_stream()); zp, des = ebdesign.read_ebd(p)
            self.assertEqual(len(open(p, 'rb').read()), 6 + 64 + 256); self.assertEqual(bytes(des[:len(sample_stream())]), sample_stream())
    def test_too_long(self):
        with self.assertRaises(ValueError): ebdesign.write_ebd('x', bytes(300))
    @unittest.skipUnless(HAVE_ROM, 'needs the ROM')
    def test_builtin_tracks_roundtrip(self):
        prg, _ = ebdesign.load_rom(ROM)
        for n in range(5):
            s = ebdesign.builtin_track(prg, n); laps, toks = ebdesign.parse(s); self.assertEqual(ebdesign.serialize(laps, toks)[:len(s)], s)

class Pack(unittest.TestCase):
    def pack(self, **kw):
        p = levelpack.make_pack(sample_stream(), 'My Level', 'me', 'text', ['jumps'], 'CC0-1.0'); p.update(kw); return p
    def test_valid(self): self.assertEqual(levelpack.problems(self.pack()), [])
    def test_bad_fields(self):
        for kw, word in ((dict(title=''), 'title'), (dict(title='<b>'), 'title'), (dict(id='A'), 'id'), (dict(license='GPL'), 'license'),
                         (dict(tags=['Bad Tag']), 'tags'), (dict(laps=7), 'laps'), (dict(track='!!'), 'base64'), (dict(format='x'), 'format')):
            e = levelpack.problems(self.pack(**kw)); self.assertTrue(any(word in x for x in e), (kw, e))
    def test_no_finish_line(self):
        s = bytes([1, 0x40, 4, 0]); e = levelpack.problems(self.pack(track=base64.b64encode(s).decode(), laps=1)); self.assertTrue(e)
    def test_bad_run_count(self):
        s = bytes([1, 0x40, 0, 9]); self.assertTrue(levelpack.problems(self.pack(track=base64.b64encode(s).decode(), laps=1)))
    def test_file_and_index(self):
        with tempfile.TemporaryDirectory() as d:
            p = self.pack(); open(os.path.join(d, p['id'] + '.ebpack.json'), 'w').write(json.dumps(p))
            with self.assertRaises(SystemExit) as c: levelpack.main(['index', d])
            self.assertEqual(c.exception.code, 0); idx = json.load(open(os.path.join(d, 'index.json'))); self.assertEqual(idx['levels'][0]['id'], 'my-level')
    def test_wrong_filename(self):
        with tempfile.TemporaryDirectory() as d:
            p = self.pack(); open(os.path.join(d, 'other.ebpack.json'), 'w').write(json.dumps(p))
            with self.assertRaises(SystemExit) as c: levelpack.main(['validate', d])
            self.assertEqual(c.exception.code, 1)
    def test_repo_levels_valid(self):
        with self.assertRaises(SystemExit) as c: levelpack.main(['validate', os.path.join(ROOT, 'levels')])
        self.assertEqual(c.exception.code, 0)

class Music(unittest.TestCase):
    def test_parse_and_write(self):
        text = 'EBM1\nname t\nvoice pulse1 duty 1 decay 5\nn 60 8\nr 4\nn 64 8 gate 4\nvoice tri\nn 48 12\n'
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, 'song_01.ebm'); open(p, 'w').write(text); s = ebmusic.read_ebm(p)
            self.assertEqual([v[0] for v in s['voices']], ['pulse1', 'tri']); self.assertEqual(s['voices'][0][2][1], ('r', 4)); self.assertEqual(s['voices'][0][2][2][3], 4)
            q = os.path.join(d, 'b.ebm'); ebmusic.write_ebm(s, q); self.assertEqual(ebmusic.read_ebm(q)['voices'], s['voices'])
    @unittest.skipUnless(HAVE_ROM, 'needs the ROM')
    def test_rom_songs(self):
        prg = ebmusic.load_prg(ROM)
        for req in (1, 2, 4, 8, 0x10, 0x20, 0x40, 0x80):
            s = ebmusic.decode_song(prg, req); self.assertGreater(s['total'], 0)
            for kind, par, evs in s['voices']: self.assertEqual(sum(e[1] if e[0] == 'r' else e[2] for e in evs), s['total'], (req, kind))
    @unittest.skipUnless(HAVE_ROM, 'needs the ROM')
    def test_title_melody(self):
        s = ebmusic.decode_song(ebmusic.load_prg(ROM), 1); notes = [e[1] for e in s['voices'][0][2] if e[0] == 'n'][:3]; self.assertEqual(notes, [60, 64, 67])

if __name__ == '__main__': unittest.main(verbosity=1)
