#!/usr/bin/env python3
"""Syntax check of the scripts inside the browser editors (needs node).  python tests/test_editors.py
A redeclared name or a stray bracket makes a whole editor page go blank, so every inline script is checked with `node --check`."""
import os, re, shutil, subprocess, tempfile, unittest
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
NODE = shutil.which('node')

@unittest.skipUnless(NODE, 'needs node')
class EditorScripts(unittest.TestCase):
    def test_inline_scripts_parse(self):
        for name in ('index.html', 'tiles.html', 'music.html'):
            html = open(os.path.join(ROOT, 'tools', 'editor', name), encoding='utf-8').read()
            scripts = [m.group(1) for m in re.finditer(r'<script>(.*?)</script>', html, re.S)]
            self.assertTrue(scripts, name)
            for i, js in enumerate(scripts):
                with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as d:
                    p = os.path.join(d, 'x.js'); open(p, 'w', encoding='utf-8').write(js)
                    r = subprocess.run([NODE, '--check', p], capture_output=True, text=True)
                    self.assertEqual(r.returncode, 0, '%s script %d: %s' % (name, i, r.stderr))
if __name__ == '__main__': unittest.main()
