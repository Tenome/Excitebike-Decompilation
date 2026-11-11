#!/usr/bin/env python3
"""Compiles and runs tests/interp_test.c (needs a C compiler).  python tests/test_interp.py"""
import os, shutil, subprocess, sys, tempfile, unittest
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
CC = next((c for c in (os.environ.get('CLANG'), 'clang', 'gcc', 'cc') if c and shutil.which(c)), None)
@unittest.skipUnless(CC, 'needs a C compiler')
class Interp(unittest.TestCase):
    def test_tagged_rider_moves_by_its_origin(self):
        with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as d:
            exe = os.path.join(d, 'interp_test.exe' if os.name == 'nt' else 'interp_test')
            subprocess.check_call([CC, '-O1', '-o', exe, os.path.join(ROOT, 'tests', 'interp_test.c'), os.path.join(ROOT, 'port', 'ppu.c')])
            x, y = map(int, subprocess.check_output([exe]).split()); self.assertEqual((x, y), (110, 106))
if __name__ == '__main__': unittest.main()
