#!/usr/bin/env python3
"""Excitebike music: decode the ROM's songs into editable .ebm text files and read .ebm files back.

The ROM stores a song as one-byte notes (pitch in bits 1-5, length class in bit 0 and bits 6-7) for four voices (pulse 1, pulse 2, triangle, noise);
pulse 2's stream decides when the song ends. The port plays .ebm songs through the same APU registers (port/audiomod.c), with free pitch (MIDI note numbers)
and free lengths (frames), so songs can be edited with tools/editor/music.html or any text editor.

.ebm format (text, '#' starts a comment):
  EBM1
  name <text>
  voice pulse1|pulse2|tri|noise [duty 0-3] [decay 0-15]     (pulse instruments; decay 0 = constant volume 15, 1-15 = decaying envelope, larger = slower)
  n <midi note> <frames> [gate <frames>] [decay <0-15>]      a note (noise: n <period 0-15> <frames>: 0 = highest; noise decay k = envelope period k-1, 0 = constant volume)
  r <frames>                                                a rest
Voices play in parallel from the song start; the song ends when the longest voice ends.
Songs are named song_XX.ebm, XX = the music request byte in hex (01 title, 02, 04, 08, 10, 20, 40, 80 = the ROM's eight songs).

  python tools/ebmusic.py export OUTDIR      writes song_XX.ebm for every song in orig/excitebike_us.nes"""
import math, os, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
CPU = 1789773.0

def load_prg(path=None):
    d = open(path or os.path.join(ROOT, 'orig', 'excitebike_us.nes'), 'rb').read()
    return d[16:16 + 0x4000]

def R(prg, a): return prg[a - 0xC000]

def midi_of(freq): return int(round(69 + 12 * math.log2(freq / 440.0)))

def decode_song(prg, request):
    """-> dict(name, voices=[(kind, params, [events])]); events are ('n', midi, frames, gate, decay) or ('r', frames)"""
    bit = 1
    while not (request >> (bit - 1)) & 1: bit += 1
    y = R(prg, 0xFDD2 + bit)
    tempo = R(prg, 0xFDD3 + y); base = R(prg, 0xFDD4 + y) | R(prg, 0xFDD5 + y) << 8
    start = dict(pulse1=R(prg, 0xFDD6 + y), pulse2=0, tri=R(prg, 0xFDD7 + y), noise=R(prg, 0xFDD8 + y))
    byte = lambda i: R(prg, base + i)
    def length(note):
        cls = ((note & 1) << 2) | (note >> 6)
        return R(prg, 0xFF3E + cls + tempo)
    def pitch(note, div):
        idx = note & 0x3E; lo = R(prg, 0xFF01 + idx); hi = R(prg, 0xFF00 + idx)
        if lo == 0: return None
        return midi_of(CPU / (div * (((hi & 7) << 8 | lo) + 1)))
    # the song length: pulse 2's stream until its zero byte
    total = 0; i = 0
    while byte(i) != 0: total += length(byte(i)); i += 1
    voices = []
    def stream(kind, idx):
        ev = []; t = 0
        while t < total:
            n = byte(idx); idx += 1; f = length(n)
            if t + f > total: f = total - t
            t += f
            ev.append((n, f))
        return ev
    # pulse 1 (melody)
    if start['pulse1'] != 0:
        evs = []
        for n, f in stream('pulse1', start['pulse1']):
            p = pitch(n, 16); evs.append(('n', p, f, f, 0) if p is not None else ('r', f))
        duty, decay = (1, 15) if request & 0x60 else (0, 5)
        voices.append(('pulse1', dict(duty=duty, decay=decay), evs))
    # pulse 2 (harmony): muted in the two fanfares
    if not request & 0x60:
        evs = []
        for n, f in stream('pulse2', 0):
            p = pitch(n, 16)
            decay = 7 if f >= 0x10 else (4 if f >= 8 else 2)
            evs.append(('n', p, f, f, decay) if p is not None else ('r', f))
        voices.append(('pulse2', dict(duty=2, decay=7), evs))
    # triangle (bass): sounds min(length-1, 12) frames, or the whole length in the $20 fanfare
    if start['tri'] != 0:
        evs = []
        for n, f in stream('tri', start['tri']):
            p = pitch(n, 32)
            gate = f if request == 0x20 else min(max(f - 1, 0), 12)
            evs.append(('n', p, f, gate, 0) if p is not None else ('r', f))
        voices.append(('tri', {}, evs))
    # noise (percussion): only in the songs that have it
    if request & 0x1B:
        evs = []
        for n, f in stream('noise', start['noise']):
            a = n & 0x3E
            evs.append(('n', 2 if a == 0x20 else 0, f, f, 0) if a else ('r', f))
        voices.append(('noise', dict(decay=1), evs))
    return dict(name='ROM song %02X' % request, voices=voices, total=total)

def song_text(song):
    out = ['EBM1', 'name ' + song['name']]
    for kind, par, evs in song['voices']:
        line = 'voice ' + kind
        if 'duty' in par: line += ' duty %d' % par['duty']
        if 'decay' in par: line += ' decay %d' % par['decay']
        out.append(line)
        for e in evs:
            if e[0] == 'r': out.append('r %d' % e[1])
            else:
                s = 'n %d %d' % (e[1], e[2])
                if e[3] != e[2]: s += ' gate %d' % e[3]
                if e[4] and kind == 'pulse2' and e[4] != par.get('decay'): s += ' decay %d' % e[4]
                out.append(s)
    return '\n'.join(out) + '\n'

def write_ebm(song, path):
    open(path, 'w', newline='\n').write(song_text(song))

def read_ebm(path):
    song = dict(name='', voices=[]); cur = None
    for ln in open(path).read().splitlines():
        ln = ln.split('#')[0].strip()
        if not ln or ln == 'EBM1': continue
        w = ln.split()
        if w[0] == 'name': song['name'] = ln[5:]
        elif w[0] == 'voice':
            par = {}
            for i in range(2, len(w) - 1, 2): par[w[i]] = int(w[i + 1])
            cur = (w[1], par, []); song['voices'].append(cur)
        elif w[0] == 'r': cur[2].append(('r', int(w[1])))
        elif w[0] == 'n':
            frames = int(w[2]); gate = frames; decay = cur[1].get('decay', 0)
            for i in range(3, len(w) - 1, 2):
                if w[i] == 'gate': gate = int(w[i + 1])
                elif w[i] == 'decay': decay = int(w[i + 1])
            cur[2].append(('n', int(w[1]), frames, gate, decay))
    return song

if __name__ == '__main__':
    a = sys.argv[1:]
    if len(a) == 2 and a[0] == 'export':
        os.makedirs(a[1], exist_ok=True); prg = load_prg(); seen = {}
        for req in (1, 2, 4, 8, 0x10, 0x20, 0x40, 0x80):
            s = decode_song(prg, req); write_ebm(s, os.path.join(a[1], 'song_%02x.ebm' % req))
            print('song_%02x.ebm: %d voices, %.1f s' % (req, len(s['voices']), s['total'] / 60.0988))
    else: sys.exit(__doc__)
