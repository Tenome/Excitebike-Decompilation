#!/usr/bin/env python3
"""Checks the long-design buffer logic of c/excitebike.c through ctypes (needs a C compiler).  python tests/test_longdesign.py"""
import ctypes, os, random, shutil, subprocess, sys, tempfile, unittest
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.join(ROOT, 'tools')); import ebdesign
CC = next((c for c in (os.environ.get('CLANG'), 'clang', 'gcc', 'cc') if c and shutil.which(c)), None)

@unittest.skipUnless(CC, 'needs a C compiler')
class Long(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.TemporaryDirectory(ignore_cleanup_errors=True); dll = os.path.join(cls.tmp.name, 'eb.dll' if os.name == 'nt' else 'eb.so')
        subprocess.check_call([CC, '-shared', '-O1', '-fPIC', '-o', dll, os.path.join(ROOT, 'c', 'excitebike.c')])
        cls.lib = ctypes.CDLL(dll); cls.ram = (ctypes.c_uint8 * 0x800).in_dll(cls.lib, 'g_ram'); cls.long = ctypes.c_int.in_dll(cls.lib, 'g_design_long')
        cls.ext_len = (ctypes.c_uint16 * 6).in_dll(cls.lib, 'g_track_ext_len')
    def setUp(self):
        for i in range(0x800): self.ram[i] = 0
        self.long.value = 1; self.lib.DesignExtReset()
    def record(self, tokens, laps=2):
        """what the editor does: append bytes at $05E0+$B7, flushing when the buffer fills (as DesignCapture does)"""
        self.ram[0x05E0] = laps; self.ram[0xB7] = 1
        for b in tokens:
            self.ram[0x05E0 + self.ram[0xB7]] = b; self.ram[0xB7] += 1
            if self.long.value and self.ram[0xB7] >= 0xC0: self.lib.DesignFlush()      # the same condition DesignCapture uses
    def assembled(self):
        buf = (ctypes.c_uint8 * 2300)(); n = self.lib.DesignAssemble(buf, 2300); return bytes(buf[:n])
    def test_long_track_is_kept_whole(self):
        r = random.Random(5); toks = [('run', 0, r.randint(1, 20)) if r.random() < .6 else ('piece', r.choice([5, 7, 10, 13]), False) for _ in range(500)] + [('piece', 9, False)]
        stream = ebdesign.serialize(2, toks); self.assertGreater(len(stream), 600)
        self.record(stream[1:-1]); got = self.assembled()
        self.assertEqual(got[:len(stream) - 1], stream[:-1]); self.assertEqual(ebdesign.parse(got)[1][-1], ('piece', 9, False)); self.assertEqual(self.ram[0xB7] < 0xC0, True)
    def test_short_track_unchanged(self):
        stream = ebdesign.serialize(1, [('run', 0, 5), ('piece', 7, False), ('piece', 9, False)]); self.record(stream[1:-1])
        self.assertEqual(self.assembled(), b'')                      # nothing flushed: the plain 256-byte design is used
    def test_original_limit_when_off(self):
        self.long.value = 0; self.record([0x40, 5] * 100); self.assertEqual(self.assembled(), b''); self.assertGreaterEqual(self.ram[0xB7], 0xC0)
    def test_import(self):
        stream = ebdesign.serialize(3, [('run', 0, 7)] * 400 + [('piece', 9, False)]); buf = (ctypes.c_uint8 * len(stream)).from_buffer_copy(stream)
        self.lib.DesignExtImport(buf, len(stream)); self.assertEqual(self.assembled(), stream); self.assertEqual(self.ext_len[5], len(stream)); self.assertEqual(self.ram[0x05E0], 3)
        self.lib.DesignExtReset(); self.assertEqual(self.ext_len[5], 0)
if __name__ == '__main__': unittest.main()
