#!/usr/bin/env python3
"""Assemble src/<ver>/ with cc65 (ca65 + ld65) and compare the result byte for byte with orig/excitebike_<ver>.nes.
usage: python tools/build.py [--version us|jp] [--cc65 DIR]
cc65 is looked up in --cc65, $CC65_DIR, then PATH. Prints MATCH (exit 0) or MISMATCH (exit 1)."""
import argparse, hashlib, os, shutil, subprocess, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
def find_tool(name, hint):
    for d in (hint, os.environ.get('CC65_DIR')):
        if d:
            for sub in ('', 'bin'):
                p = os.path.join(d, sub, name)
                for cand in (p, p + '.exe'):
                    if os.path.exists(cand): return cand
    p = shutil.which(name)
    if p: return p
    sys.exit(f'{name} not found: install cc65 and put it on PATH, or pass --cc65 DIR / set CC65_DIR')
def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--version', default='us', choices=['us', 'eu']); ap.add_argument('--cc65')
    a = ap.parse_args(); v = a.version
    ca65, ld65 = find_tool('ca65', a.cc65), find_tool('ld65', a.cc65)
    src = os.path.join(ROOT, 'src', v); assets = os.path.join(ROOT, 'assets', v); out = os.path.join(ROOT, 'build', v)
    rom = os.path.join(ROOT, 'orig', f'excitebike_{v}.nes')
    if not os.path.exists(os.path.join(assets, 'prg_bank_0.bin')):
        sys.exit(f'assets/{v} is missing: run  python tools/ebdis.py --version {v}  (needs your ROM at orig/excitebike_{v}.nes)')
    os.makedirs(out, exist_ok=True)
    obj, nes = os.path.join(out, 'excitebike.o'), os.path.join(out, 'excitebike.nes')
    subprocess.check_call([ca65, os.path.join(src, 'excitebike.asm'), '-I', src, '--bin-include-dir', assets, '-o', obj, '-l', os.path.join(out, 'excitebike.lst')])
    subprocess.check_call([ld65, '-C', os.path.join(ROOT, 'config', 'excitebike.cfg'), '-o', nes, obj])
    h = lambda p: hashlib.sha1(open(p, 'rb').read()).hexdigest()
    if h(nes) == h(rom): print(f'[{v}] MATCH  sha1 {h(nes)}'); return 0
    print(f'[{v}] MISMATCH  built {h(nes)}  original {h(rom)}'); return 1
if __name__ == '__main__': sys.exit(main())
