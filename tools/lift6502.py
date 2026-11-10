#!/usr/bin/env python3
"""Mechanical 6502 -> C lifter for the routines that are too tangled to lift by hand (the sound engine, ...).
The output keeps every register and flag in a variable and every branch as a goto, so it is exactly equal to the original;
it is checked with tools/difftest.py like the hand-lifted routines and can be rewritten into cleaner C piece by piece
(the difftest keeps proving the rewrite equal).
usage: python tools/lift6502.py --version us --out c/auto_sound.inc --entries F844 F86B ... [--range F844 FFF9]
Instruction starts come from the disassembly in src/<ver>/ (so inline data is never decoded as code); entries are CPU addresses.
Functions are created for the entries and for every address that is reached from more than one function (shared tails)."""
import argparse, glob, json, os, re, sys
ap = argparse.ArgumentParser()
ap.add_argument('--version', default='us'); ap.add_argument('--out', required=True)
ap.add_argument('--entries', nargs='+', required=True); ap.add_argument('--prefix', default='')
ap.add_argument('--extern', nargs='*', default=[], help='ADDR=cname: routines already available as C (called as cname())')
a = ap.parse_args()
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..'))
sys.argv = [sys.argv[0], '--version', a.version]; sys.path.insert(0, HERE)
import ebdis
TAB, LENM, PRG = ebdis.TAB, ebdis.LENM, ebdis.PRG
def rb(addr): return PRG[addr & 0x3FFF]

# ---- instruction starts from the generated assembly ----
starts = set()
for f in glob.glob(os.path.join(ROOT, 'src', a.version, '*.asm')):
    for line in open(f):
        m = re.match(r'^\s+(?!\.)\w+.*;\s+\$([0-9A-F]{4})\b', line)
        if m and not line.strip().startswith('.'): starts.add(int(m.group(1), 16))
names = {}
nf = os.path.join(ROOT, 'config', a.version, 'names.json')
if os.path.exists(nf):
    for k, v in json.load(open(nf)).items():
        k = k.split(':')[-1]
        names[int(k, 16)] = v
externs = {int(x.split('=')[0], 16): x.split('=')[1] for x in a.extern}

def decode(addr):
    op = rb(addr)
    n, m = TAB[op]
    size = LENM[m]
    arg = 0
    if size == 2: arg = rb(addr + 1)
    elif size == 3: arg = rb(addr + 1) | rb(addr + 2) << 8
    return n, m, arg, size
def target(addr, arg):                      # relative branch target
    return (addr + 2 + (arg - 256 if arg > 127 else arg)) & 0xFFFF

# ---- function partitioning ----
entries = [int(x, 16) for x in a.entries]
def succs(addr):
    n, m, arg, size = decode(addr)
    nxt = addr + size
    if n in ('rts', 'rti'): return []
    if n == 'jmp': return [arg] if m == 'abs' else []
    if m == 'rel': return [target(addr, arg), nxt]
    if n == 'brk': return []
    return [nxt]
owner = {}
changed = True
while changed:
    changed = False; owner = {}
    for e in list(entries):
        stack = [e]
        while stack:
            p = stack.pop()
            if p in externs and p != e: continue
            if p not in starts:
                continue
            if p in owner:
                if owner[p] != e and p not in entries:
                    entries.append(p); changed = True
                continue
            if p in entries and p != e: continue
            owner[p] = e
            stack.extend(succs(p))
    for p_ in list(owner):
        n_, m_, arg_, size_ = decode(p_)
        if n_ == 'jsr' and arg_ in starts and arg_ not in entries and arg_ not in externs:
            entries.append(arg_); changed = True

def fname(addr):
    if addr in externs: return externs[addr]
    return a.prefix + names.get(addr, f'Sub_{addr:04X}')
def lab(addr): return f'L_{addr:04X}'

def ea(m, arg):
    if m == 'zp': return f'0x{arg:02X}'
    if m == 'zpx': return f'(uint8_t)(0x{arg:02X} + rx)'
    if m == 'zpy': return f'(uint8_t)(0x{arg:02X} + ry)'
    if m == 'abs': return f'0x{arg:04X}'
    if m == 'abx': return f'(uint16_t)(0x{arg:04X} + rx)'
    if m == 'aby': return f'(uint16_t)(0x{arg:04X} + ry)'
    if m == 'izx': return f'zp_ptr((uint8_t)(0x{arg:02X} + rx))'
    if m == 'izy': return f'(uint16_t)(zp_ptr(0x{arg:02X}) + ry)'
    raise ValueError(m)
def val(m, arg):
    return f'0x{arg:02X}' if m == 'imm' else f'RD({ea(m, arg)})'
def emit_instr(addr, fn_entry):
    n, m, arg, size = decode(addr)
    nxt = addr + size
    def go(t, cond=None):
        """branch/jump to t: goto within the function, tail call otherwise"""
        inside = owner.get(t) == fn_entry and t not in (set(entries) - {fn_entry})
        stmt = f'goto {lab(t)};' if inside else (f'{{ {fname(t)}(); return; }}' if t in externs or t in entries else f'/* target ${t:04X} is not code */ return;')
        return f'if ({cond}) {stmt}' if cond else stmt
    L = []
    if n in ('lda', 'ldx', 'ldy'):
        r = {'lda': 'ra', 'ldx': 'rx', 'ldy': 'ry'}[n]; L.append(f'{r} = {val(m, arg)}; SETNZ({r});')
    elif n in ('sta', 'stx', 'sty'):
        r = {'sta': 'ra', 'stx': 'rx', 'sty': 'ry'}[n]; L.append(f'WR({ea(m, arg)}, {r});')
    elif n == 'tax': L.append('rx = ra; SETNZ(rx);')
    elif n == 'tay': L.append('ry = ra; SETNZ(ry);')
    elif n == 'txa': L.append('ra = rx; SETNZ(ra);')
    elif n == 'tya': L.append('ra = ry; SETNZ(ra);')
    elif n == 'adc': L.append(f'ADC({val(m, arg)});')
    elif n == 'sbc': L.append(f'SBC({val(m, arg)});')
    elif n == 'and': L.append(f'ra &= {val(m, arg)}; SETNZ(ra);')
    elif n == 'ora': L.append(f'ra |= {val(m, arg)}; SETNZ(ra);')
    elif n == 'eor': L.append(f'ra ^= {val(m, arg)}; SETNZ(ra);')
    elif n in ('cmp', 'cpx', 'cpy'):
        r = {'cmp': 'ra', 'cpx': 'rx', 'cpy': 'ry'}[n]; L.append(f'CMP({r}, {val(m, arg)});')
    elif n == 'bit': L.append(f'BIT({val(m, arg)});')
    elif n in ('inc', 'dec'):
        d = '+ 1' if n == 'inc' else '- 1'
        L.append(f'{{ uint16_t ea_ = {ea(m, arg)}; uint8_t t_ = (uint8_t)(RD(ea_) {d}); WR(ea_, t_); SETNZ(t_); }}')
    elif n in ('inx', 'iny', 'dex', 'dey'):
        r = 'rx' if n[2] == 'x' else 'ry'; d = '+ 1' if n[:2] == 'in' else '- 1'
        L.append(f'{r} = (uint8_t)({r} {d}); SETNZ({r});')
    elif n in ('asl', 'lsr', 'rol', 'ror'):
        if m == 'acc': L.append(f'ra = SHIFT_{n.upper()}(ra);')
        else: L.append(f'{{ uint16_t ea_ = {ea(m, arg)}; uint8_t t_ = SHIFT_{n.upper()}(RD(ea_)); WR(ea_, t_); }}')
    elif n == 'clc': L.append('fc = 0;')
    elif n == 'sec': L.append('fc = 1;')
    elif n == 'clv': L.append('fv = 0;')
    elif n in ('cld', 'cli', 'sei', 'nop'): L.append('/* %s */' % n)
    elif n == 'pha': L.append('PUSH(ra);')
    elif n == 'pla': L.append('ra = PULL(); SETNZ(ra);')
    elif n == 'rts': L.append('return;')
    elif n in ('bcc', 'bcs', 'beq', 'bne', 'bmi', 'bpl', 'bvc', 'bvs'):
        cond = {'bcc': '!fc', 'bcs': 'fc', 'beq': 'fz', 'bne': '!fz', 'bmi': 'fn', 'bpl': '!fn', 'bvc': '!fv', 'bvs': 'fv'}[n]
        L.append(go(target(addr, arg), cond))
    elif n == 'jmp' and m == 'abs': L.append(go(arg))
    elif n == 'jsr': L.append(f'{fname(arg)}();')
    else: raise SystemExit(f'unsupported instruction {n} {m} at ${addr:04X}')
    # fall-through: needs an explicit jump unless the next instruction is emitted right after
    ends = n in ('rts', 'rti') or (n == 'jmp')
    return L, nxt, ends

out = []
ents = sorted(entries)
seen_protos = []
for e in ents:
    if e in externs: continue
    seen_protos.append(f'static void {fname(e)}(void);')
out.append('/* Generated by tools/lift6502.py - mechanical lift of the 6502 routines (see that file). Do not edit by hand. */')
out.extend(sorted(set(seen_protos)))
for e in ents:
    if e in externs: continue
    body = sorted(p for p, o in owner.items() if o == e)
    out.append(f'\nstatic void {fname(e)}(void) {{                        /* ${e:04X} */')
    if body[0] != e: out.append(f'    goto {lab(e)};')       # the entry is not always the lowest address of the function
    for p in body:
        n, m, arg, size = decode(p)
        L, nxt, ends = emit_instr(p, e)
        out.append(f'{lab(p)}: ' + ' '.join(L) + f'   /* ${p:04X} {n} */')
        if not ends:
            nextemit = body[body.index(p) + 1] if body.index(p) + 1 < len(body) else None
            if nextemit != nxt:
                if nxt in starts and (nxt in entries or nxt in externs) and nxt != e: out.append(f'    {fname(nxt)}(); return;')
                elif nxt in starts and owner.get(nxt) == e: out.append(f'    goto {lab(nxt)};')
                else: out.append(f'    return; /* falls into data / unreachable at ${nxt:04X} */')
    out.append('}')
# wrappers used by tests
for e in ents:
    if e in externs: continue
    nm = fname(e)
    out.append(f'void V_{nm}(Regs r) {{ ra = r.a; rx = r.x; ry = r.y; fc = r.c; {nm}(); }}')
    out.append(f'Regs W_{nm}(Regs r) {{ ra = r.a; rx = r.x; ry = r.y; fc = r.c; {nm}(); return (Regs){{ ra, rx, ry, fc }}; }}')
open(os.path.join(ROOT, a.out) if not os.path.isabs(a.out) else a.out, 'w', newline='\n').write('\n'.join(out) + '\n')
print(f'{len(ents)} functions, {len(owner)} instructions -> {a.out}')
