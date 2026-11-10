#!/usr/bin/env python3
"""Assemble a release folder for the native port: dist/excitebike/ with the executable, SDL2.dll (Windows), docs, an example config and an empty mods/ layout.
The ROM is not included (the game reads its data and graphics from the user's own ROM). Usage:
  python tools/package.py --exe build/port/excitebike.exe [--sdl-dll path/SDL2.dll] [--zip]"""
import argparse, os, shutil, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
ap = argparse.ArgumentParser()
ap.add_argument('--exe', required=True); ap.add_argument('--sdl-dll'); ap.add_argument('--out', default=os.path.join(ROOT, 'dist', 'excitebike')); ap.add_argument('--zip', action='store_true')
a = ap.parse_args()
if not os.path.isfile(a.exe): sys.exit('executable not found: ' + a.exe)
shutil.rmtree(a.out, ignore_errors=True); os.makedirs(os.path.join(a.out, 'mods', 'audio'))
shutil.copy(a.exe, a.out)
if a.sdl_dll: shutil.copy(a.sdl_dll, a.out)
shutil.copy(os.path.join(ROOT, 'port', 'excitebike.cfg.example'), a.out)
shutil.copy(os.path.join(ROOT, 'port', 'README.md'), os.path.join(a.out, 'README.md'))
bat = ['@echo off', 'rem Track, tile and music editors in your browser (needs Python 3 and your ROM as excitebike.nes)', r'python tools\editor\serve.py excitebike.nes']
open(os.path.join(a.out, 'editors.bat'), 'w', newline='\r\n').write('\n'.join(bat) + '\n')
open(os.path.join(a.out, 'mods', 'audio', 'README.txt'), 'w').write(
    'Put WAV files here named <channel>_<request hex>.wav (music_01.wav, pulse1_04.wav, pulse2_01.wav, noise_02.wav) and start with --audio-mod mods/audio.\n')
tools = os.path.join(a.out, 'tools'); os.makedirs(os.path.join(tools, 'editor'))
for f in ('ebdesign.py', 'ebmusic.py', 'chrbmp.py'): shutil.copy(os.path.join(ROOT, 'tools', f), tools)
for f in ('index.html', 'tiles.html', 'music.html', 'serve.py'): shutil.copy(os.path.join(ROOT, 'tools', 'editor', f), os.path.join(tools, 'editor'))
exe = os.path.basename(a.exe)
open(os.path.join(a.out, 'run.bat'), 'w', newline='\r\n').write(
    '@echo off\r\nrem Put your own Excitebike ROM next to this file as excitebike.nes (or edit the path below).\r\n%s excitebike.nes --audio-mod mods/audio %%*\r\n' % exe)
open(os.path.join(a.out, 'NOTE.txt'), 'w').write(
    'This folder does not contain the game ROM. The port needs a legally obtained Excitebike ROM (NTSC or PAL) for its data tables and graphics.\n')
if a.zip: print(shutil.make_archive(a.out, 'zip', os.path.dirname(a.out), os.path.basename(a.out)))
print('packaged to', a.out)
