#!/usr/bin/env python3
"""Whole-game differential test: runs the original ROM (tools/sim6502.py) and the lifted C game (c/excitebike.c) side by side,
frame by frame, from reset, with the same scripted controller input and the same minimal hardware model (PPU status, joypads).
After every frame the CPU RAM and the exact sequence of PPU/APU register writes (which is the picture and the sound) must be equal.
usage: python tools/fulltest.py [--version us|eu] [--frames N] [--seed S] [--clang PATH] [--idle K]"""
import argparse, ctypes, os, random, subprocess, sys
ap = argparse.ArgumentParser()
ap.add_argument('--version', default='us'); ap.add_argument('--frames', type=int, default=600); ap.add_argument('--seed', type=int, default=1)
ap.add_argument('--policy', default='random', choices=['random', 'drive'], help='drive: hold the throttle while racing so the race can finish')
ap.add_argument('--clang'); ap.add_argument('--idle', type=int, default=40, help='random-number updates between frames (the idle loop)')
a = ap.parse_args()
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..'))
sys.argv = [sys.argv[0], '--version', a.version]; sys.path.insert(0, HERE)
import ebdis, sim6502
import shutil
cc = next((p for p in (a.clang, os.environ.get('CLANG'), shutil.which('clang'), shutil.which('gcc'), shutil.which('cc')) if p), None)
if not cc: sys.exit('no C compiler found (pass --clang PATH or set CLANG)')
dll = os.path.join(ROOT, 'build', 'excitebike_c' + ('.dll' if os.name == 'nt' else '.so'))
os.makedirs(os.path.dirname(dll), exist_ok=True)
subprocess.check_call([cc, '-shared', '-O1', '-fPIC', '-o', dll, os.path.join(ROOT, 'c', 'excitebike.c')])
lib = ctypes.CDLL(dll)
class Regs(ctypes.Structure): _fields_ = [('a', ctypes.c_uint8), ('x', ctypes.c_uint8), ('y', ctypes.c_uint8), ('c', ctypes.c_uint8)]
class IoWrite(ctypes.Structure): _fields_ = [('addr', ctypes.c_uint16), ('val', ctypes.c_uint8)]
ram_c = (ctypes.c_uint8 * 0x800).in_dll(lib, 'g_ram')
io_log = (IoWrite * 8192).in_dll(lib, 'g_io_log'); io_n = ctypes.c_int.in_dll(lib, 'g_io_n')
pad_c = (ctypes.c_uint8 * 2).in_dll(lib, 'g_pad_buttons')
prg = bytes(ebdis.PRG); prg_buf = ctypes.create_string_buffer(prg, len(prg))
ctypes.c_void_p.in_dll(lib, 'g_prg').value = ctypes.addressof(prg_buf)
ctypes.c_int.in_dll(lib, 'g_pal').value = 1 if a.version == 'eu' else 0
ctypes.c_int.in_dll(lib, 'g_io_model').value = 1

cpu = sim6502.CPU(prg); cpu.model = True
rnd = random.Random(a.seed)
def c_writes(): return [(io_log[k].addr, io_log[k].val) for k in range(min(io_n.value, 8192))]
def compare(tag):
    bad = [k for k in range(0x800) if not 0x100 <= k < 0x200 and cpu.ram[k] != ram_c[k]]
    cw = c_writes(); aw = list(cpu.io_writes)
    if bad or cw != aw:
        print(f'MISMATCH {tag}')
        if bad: print('  RAM (addr, original, c):', [(hex(k), cpu.ram[k], ram_c[k]) for k in bad[:12]])
        if cw != aw:
            k = next((j for j in range(min(len(aw), len(cw))) if aw[j] != cw[j]), min(len(aw), len(cw)))
            print(f'  register writes differ at #{k} (original {len(aw)}, c {len(cw)}): original {aw[max(0,k-2):k+5]} c {cw[max(0,k-2):k+5]}')
        return False
    return True

# power-on: RAM empty on both sides, then run the reset code to the idle loop
io_n.value = 0
cpu.call(0xC184, stop=0xC1D8)
lib.ResetInit()
if not compare('after reset'): sys.exit(1)
buttons = 0; hold = 0; visited = set()
pool = [0x00, 0x00, 0x01, 0x01, 0x03, 0x08, 0x08, 0x10, 0x20, 0x40, 0x80, 0x05, 0x02]
for frame in range(a.frames):
    if hold == 0:
        buttons = rnd.choice(pool); hold = rnd.randint(1, 25)
        if a.policy == 'drive' and cpu.ram[0x41] in (2, 5, 10):
            buttons = rnd.choice([0x01, 0x01, 0x01, 0x01, 0x03, 0x11, 0x21, 0x01, 0x41, 0x81]); hold = rnd.randint(5, 40)
    hold -= 1
    cpu.io_writes.clear(); io_n.value = 0
    cpu.pad_buttons = [buttons, 0]; pad_c[0] = buttons; pad_c[1] = 0
    for _ in range(a.idle):
        cpu.call(0xD326)                      # UpdateRandom (the idle loop)
        lib.UpdateRandom()
    cpu.io_writes.clear(); io_n.value = 0
    cpu.call(0xC23B, rti=True)               # NMI
    lib.Nmi()
    visited.add(cpu.ram[0x41])
    if not compare(f'frame {frame} (buttons ${buttons:02X}, game state {cpu.ram[0x41]}, step {cpu.ram[0x44]})'): sys.exit(1)
print(f'OK: {a.frames} frames identical (RAM and every PPU/APU register write); game states visited {sorted(visited)}')
