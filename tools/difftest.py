#!/usr/bin/env python3
"""Differential test: every lifted C routine (c/excitebike.c) against the original 6502 code (orig ROM, tools/sim6502.py).
Random CPU RAM and registers are fed to both; RAM (except the stack page) and the declared result registers must match.
usage: python tools/difftest.py [--version us|eu] [--runs N] [--clang PATH]"""
import argparse, ctypes, os, random, subprocess, sys
ap = argparse.ArgumentParser(); ap.add_argument('--version', default='us'); ap.add_argument('--runs', type=int, default=3000); ap.add_argument('--clang'); ap.add_argument('--only')
a = ap.parse_args()
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..'))
sys.argv = [sys.argv[0], '--version', a.version]; sys.path.insert(0, HERE)
import ebdis, sim6502

def find_clang():
    for c in (a.clang, os.environ.get('CLANG'), 'clang', 'gcc', 'cc'):
        if c:
            import shutil
            p = shutil.which(c) or (c if os.path.exists(c) else None)
            if p: return p
    sys.exit('no C compiler found (pass --clang PATH or set CLANG)')
dll = os.path.join(ROOT, 'build', 'excitebike_c' + ('.dll' if os.name == 'nt' else '.so'))
os.makedirs(os.path.dirname(dll), exist_ok=True)
subprocess.check_call([find_clang(), '-shared', '-O1', '-fPIC', '-o', dll, os.path.join(ROOT, 'c', 'excitebike.c')])
lib = ctypes.CDLL(dll)

class Regs(ctypes.Structure): _fields_ = [('a', ctypes.c_uint8), ('x', ctypes.c_uint8), ('y', ctypes.c_uint8), ('c', ctypes.c_uint8)]
ram_c = (ctypes.c_uint8 * 0x800).in_dll(lib, 'g_ram')
prg = bytes(ebdis.PRG); prg_buf = ctypes.create_string_buffer(prg, len(prg))
ctypes.c_void_p.in_dll(lib, 'g_prg').value = ctypes.addressof(prg_buf)

# name, asm address, C symbol, takes_regs, result regs to compare, input constraints
TESTS = [
    ('DivModByX',            0xDFA4, True,  'ax',  lambda r: dict(x=r.randint(1, 255))),
    ('DivMod10',             0xDFA2, True,  'ax',  lambda r: {}),
    ('IncMod64',             0xECBF, True,  'a',   lambda r: dict(a=r.randint(0, 255))),
    ('UpdateRandom',         0xD326, False, '',    lambda r: {}),
    ('TickTimers',           0xD310, False, '',    lambda r: {}),
    ('AddCollisionHeight',   0xE091, True,  'a',   lambda r: {}),
    ('AddCollisionWidth',    0xE098, True,  'a',   lambda r: {}),
    ('RiderBaseYFrom',       0xDC9A, True,  'a',   lambda r: dict(x=r.randint(0, 3))),
    ('RiderBaseY',           0xDC97, True,  'a',   lambda r: dict(x=r.randint(0, 3))),
    ('RiderLaneFromY',       0xDFB2, True,  'ay',  lambda r: dict(x=r.randint(0, 3))),
    ('ComputeRiderLanes',    0xD0AB, False, '',    lambda r: {}),
    ('AdvanceTrackPositions',0xE70B, False, '',    lambda r: {}),
    ('SplitDigits3',         0xDF7F, True,  'V',    lambda r: dict(x=r.choice([0x00, 0x60, 0x68, 0x10, 0x20]))),
    ('SortRidersByY',        0xE3F4, False, '',    lambda r: {}),
    ('AccumulateRiderMove',  0xDA58, True,  'ac',  lambda r: dict(x=r.randint(0, 3))),
    ('ScrollWorld',          0xDA6A, False, '',    lambda r: {}),
    ('ShiftRidersByScroll',  0xDA7A, False, '',    lambda r: {}),
    ('ScrollSplitLayer',     0xDBFE, False, '',    lambda r: {}),
    ('ComputeRiderShadowY',  0xDA15, True,  'ac',  lambda r: dict(x=r.randint(0, 3))),
    ('JumpArcStep',          0xDD6F, True,  'ac',  lambda r: dict(x=r.randint(0, 3))),
    ('RiderPitchTimer',      0xDCDE, True,  'a',   lambda r: dict(x=r.randint(0, 3))),
    ('AiMatchTargetSpeedFrom',0xCFDB, True, 'a',   lambda r: dict(x=r.randint(0, 3))),
    ('AiMatchTargetSpeed',   0xCFCB, True,  'ay',  lambda r: dict(x=r.randint(0, 3))),
    ('SetTrackRowPointer',   0xE80D, True,  'a',   lambda r: dict(y=r.randint(0, 5))),
    ('TrackPieceAt',         0xE803, True,  'ay',  lambda r: dict(y=r.randint(0, 5))),
    ('TrackPieceAtRow',      0xE7FF, True,  'ay',  lambda r: dict(x=r.randint(0, 3), y=r.randint(0, 5))),
    ('TrackPieceAtRiderLane',0xE7FC, True,  'ay',  lambda r: dict(x=r.randint(0, 3))),
    ('RiderYOverlapTest',    0xE52C, True,  'ac',  lambda r: dict(x=r.randint(0, 3), y=r.randint(0, 3))),
    ('ClearRider',           0xDB95, True,  'a',   lambda r: dict(x=r.randint(0, 3))),
    ('AdvanceBufferPos',     0xC971, True,  'axc', lambda r: {}),
    ('SetRiderTargetSpeed',  0xDB50, True,  'V',   lambda r: dict(x=r.choice([3, 3, 0, 1, 2]), y=r.randint(0, 2), ram={0x52: r.choice([0, 0, 0, 1]), 0x84+3: r.randint(0, 3) * r.choice([0, 1]), 0x94: r.choice([0, 1, 2]), 0x83: r.choice([0x00, 0x10, 0x70]) + r.randint(0, 255) % 64 * 0, 0x70: 5, 0x73: r.choice([5, 6])})),
    ('AiJumpCheck',          0xD000, True,  'V',   lambda r: dict(x=r.randint(0, 3))),
    ('AiClearPitchBits',     0xCFE3, True,  'V',   lambda r: dict(x=r.randint(0, 3))),
    ('AiSetPitchInput',      0xCFEA, True,  'V',   lambda r: dict(x=r.randint(0, 3))),
    ('SetRiderTargetPitch',  0xDCA0, True,  'V',   lambda r: dict(x=r.randint(0, 3))),
    ('RiderPitchAdjust',     0xDCC7, True,  'V',   lambda r: dict(x=r.randint(0, 3), y=r.randint(0, 255))),
    ('RiderJumpSetup',       0xDD38, True,  'V',   lambda r: dict(x=r.randint(0, 3))),
    ('RiderStartJump',       0xDD06, True,  'V',   lambda r: dict(x=r.randint(0, 3))),
    ('RiderLaunchUpdate',    0xDCF2, True,  'V',   lambda r: dict(x=r.randint(0, 3))),
    ('ClearOam',             0xD255, False, '',    lambda r: {}),
    ('RiderTerrainSpeedBias',0xCDEE, True,  'V',   lambda r: dict(x=r.randint(0, 3), ram={0xA4+i: r.choice([3, 1, 0]) for i in range(4)} | {0xC0+i: r.choice([0xE4, 0x10]) for i in range(4)} | {0xB8+i: r.choice([5, 0x10, 0x40]) for i in range(4)} | {0x70+i: r.randint(0, 5) for i in range(4)})),
    ('RiderAccelerate',      0xCE29, True,  'V',   lambda r: dict(x=r.randint(0, 3), y=r.randint(0, 2), ram={0x4C: r.randint(0, 3)})),
    ('RiderDecelerateBy',    0xCE5C, True,  'V',   lambda r: dict(x=r.randint(0, 3), y=r.randint(0, 2), ram={0x94+i: r.choice([0, 0, 1]) for i in range(4)} | {0xB0+i: r.randint(0, 3) for i in range(4)})),
    ('RiderDecelerate',      0xCE58, True,  'V',   lambda r: dict(x=r.randint(0, 3), y=r.randint(0, 2), ram={0x4C: r.randint(0, 3)})),
    ('RiderPitchWobble',     0xCE83, True,  'V',   lambda r: dict(x=r.randint(0, 3), ram={0x26+i: r.choice([0, 0, 5]) for i in range(4)} | {0xB0+i: r.randint(0, 3) for i in range(4)} | {0xAC+i: r.randint(0, 14) for i in range(4)})),
    ('AiLaneBlocked',        0xCF96, True,  'c',   lambda r: dict(x=r.randint(0, 3), y=r.choice([0, 2]), ram={0x4A: r.randint(0, 3), 0x0F: r.randint(0, 3), 0x02: r.randint(1, 5)} | {0x84+i: r.randint(0, 3) for i in range(4)} | {0x70+i: r.randint(0, 5) for i in range(4)} | {0x80+i: r.randint(0, 255) for i in range(4)})),
    ('AiTrackPieceOpen',     0xCF8B, True,  'ac',  lambda r: dict(a=r.randint(0x38, 0x41))),
    ('AiLaneChangeUp',       0xCF47, True,  'V',   lambda r: dict(x=r.randint(0, 3), ram={0x0360+i: r.randint(0, 5) for i in range(4)} | {0xE0+i: r.randint(0, 40) for i in range(4)} | {0x4A: r.randint(0, 3), 0x0F: r.randint(0, 3)})),
    ('AiLaneChangeDown',     0xCF6A, True,  'V',   lambda r: dict(x=r.randint(0, 3), ram={0x0360+i: r.randint(0, 5) for i in range(4)} | {0xE0+i: r.randint(0, 40) for i in range(4)} | {0x4A: r.randint(0, 3), 0x0F: r.randint(0, 3)})),
    ('AiConsiderLaneChange', 0xCF0C, True,  'V',   lambda r: dict(x=r.randint(0, 3), ram={0x0360+i: r.randint(0, 5) for i in range(4)} | {0xE0+i: r.randint(0, 40) for i in range(4)} | {0x4A: r.randint(0, 3), 0x0F: r.randint(0, 3)} | {0x84+i: r.choice([1, 1, 0, 3]) for i in range(4)} | {0xDC+i: r.choice([0, 0, 1]) for i in range(4)} | {0xC0+i: r.choice([0xE6, 0x10]) for i in range(4)} | {0x19+i: r.choice([0x10, 0xE5, 0xFA]) for i in range(4)} | {0x80+i: r.choice([0x10, 0x90, 0xF5]) + r.randint(0, 3) for i in range(4)})),
]

def run(name, addr, takes_regs, cmp_regs, gen, runs, seed):
    rnd = random.Random(seed); fn = getattr(lib, name)
    returns = takes_regs and 'V' not in cmp_regs
    fn.restype = Regs if returns else None
    if takes_regs: fn.argtypes = [Regs]
    for i in range(runs):
        ram = bytearray(rnd.randrange(256) for _ in range(0x800))
        regs = dict(a=rnd.randrange(256), x=rnd.randrange(256), y=rnd.randrange(256), c=rnd.randrange(2)); regs.update(gen(rnd))
        for k, v in regs.pop('ram', {}).items(): ram[k] = v          # generators may bias RAM to reach rare branches
        ram = bytes(ram)
        cpu = sim6502.CPU(prg); cpu.ram[:] = ram
        ra = cpu.call(addr, regs['a'], regs['x'], regs['y'], regs['c'])
        for k in range(0x800): ram_c[k] = ram[k]
        rc = fn(Regs(regs['a'], regs['x'], regs['y'], regs['c'])) if takes_regs else fn()
        rc = (rc.a, rc.x, rc.y, rc.c) if returns else None
        bad = [k for k in range(0x800) if not 0x100 <= k < 0x200 and cpu.ram[k] != ram_c[k]]
        badreg = [r for r, idx in (('a', 0), ('x', 1), ('y', 2), ('c', 3)) if r in cmp_regs and rc is not None and ra[idx] != rc[idx]]
        if bad or badreg:
            print(f'  FAIL {name} run {i}: src {[hex(ram[(regs["x"]+j)&0xFF]) for j in range(3)]} input {regs}  ram diffs at {[hex(k) for k in bad[:6]]}  reg diffs {badreg}  asm={ra} c={rc}')
            return False
    return True

ok = True
for n, addr, tr, cr, gen in TESTS:
    if a.only and n != a.only: continue
    r = run(n, addr, tr, cr, gen, a.runs, hash(n) & 0xFFFF)
    print(f'{"ok  " if r else "FAIL"} {n:24s} ${addr:04X}  ({a.runs} random states)')
    ok &= r
print('ALL MATCH' if ok else 'MISMATCHES FOUND'); sys.exit(0 if ok else 1)
