"""Tracing 6502 disassembler for Excitebike (NROM-128: 16 KB PRG at $C000, 8 KB CHR).
Reads coverage JSON (executed opcode file offsets) + annotations, classifies code/data, emits ca65 source
that re-assembles byte-identically.
usage: python tools/ebdis.py [--version us|eu]
  reads  orig/excitebike_<ver>.nes (your own ROM), config/<ver>/{coverage,names,ram,hints}.json
  writes src/<ver>/*.asm (instructions + labels; data is .incbin of assets/<ver>/, git-ignored) and assets/<ver>/*.bin"""
import sys, os, json, re, glob
HERE = os.path.dirname(os.path.abspath(__file__)); PROJ = os.path.abspath(os.path.join(HERE, '..'))
VER = 'us'
if '--version' in sys.argv:
    i = sys.argv.index('--version'); VER = sys.argv[i + 1]; del sys.argv[i:i + 2]
assert VER in ('us', 'eu'), VER
CONF = os.path.join(PROJ, 'config', VER); SRCDIR = os.path.join(PROJ, 'src', VER); ASSETS = os.path.join(PROJ, 'assets', VER)
ROMPATH = os.path.join(PROJ, 'orig', f'excitebike_{VER}.nes')
ROM = open(ROMPATH, 'rb').read()
PRGSIZE = ROM[4] * 0x4000; CHRSIZE = ROM[5] * 0x2000
PRG = ROM[16:16 + PRGSIZE]
NB = PRGSIZE // 0x4000; FIXED = NB - 1
VECOFF = PRGSIZE - 6
# ---------- opcode table: op -> (mnemonic, mode) ----------
def build_table():
    T = {}
    c1 = ['ora','and','eor','adc','sta','lda','cmp','sbc']
    m1 = ['izx','zp','imm','abs','izy','zpx','aby','abx']
    for a in range(8):
        for b in range(8):
            if a == 4 and b == 2: continue
            T[a*32 + b*4 + 1] = (c1[a], m1[b])
    c2 = ['asl','rol','lsr','ror','stx','ldx','dec','inc']
    for a in range(8):
        T[a*32+0x06] = (c2[a], 'zp'); T[a*32+0x0E] = (c2[a], 'abs')
        if a not in (4, 5): T[a*32+0x16] = (c2[a], 'zpx'); T[a*32+0x1E] = (c2[a], 'abx')
        if a < 4: T[a*32+0x0A] = (c2[a], 'acc')
    T[0x96] = ('stx','zpy'); T[0xB6] = ('ldx','zpy'); T[0xBE] = ('ldx','aby'); T[0xA2] = ('ldx','imm')
    for op, m in ((0x24,'bit zp'),(0x2C,'bit abs'),(0x4C,'jmp abs'),(0x6C,'jmp ind'),(0x84,'sty zp'),(0x8C,'sty abs'),
                  (0x94,'sty zpx'),(0xA0,'ldy imm'),(0xA4,'ldy zp'),(0xAC,'ldy abs'),(0xB4,'ldy zpx'),(0xBC,'ldy abx'),
                  (0xC0,'cpy imm'),(0xC4,'cpy zp'),(0xCC,'cpy abs'),(0xE0,'cpx imm'),(0xE4,'cpx zp'),(0xEC,'cpx abs'),(0x20,'jsr abs')):
        n, md = m.split(); T[op] = (n, md)
    for op, n in ((0x10,'bpl'),(0x30,'bmi'),(0x50,'bvc'),(0x70,'bvs'),(0x90,'bcc'),(0xB0,'bcs'),(0xD0,'bne'),(0xF0,'beq')): T[op] = (n, 'rel')
    for op, n in ((0x00,'brk'),(0x08,'php'),(0x18,'clc'),(0x28,'plp'),(0x38,'sec'),(0x40,'rti'),(0x48,'pha'),(0x58,'cli'),
                  (0x60,'rts'),(0x68,'pla'),(0x78,'sei'),(0x88,'dey'),(0x8A,'txa'),(0x98,'tya'),(0x9A,'txs'),(0xA8,'tay'),
                  (0xAA,'tax'),(0xB8,'clv'),(0xBA,'tsx'),(0xC8,'iny'),(0xCA,'dex'),(0xD8,'cld'),(0xE8,'inx'),(0xEA,'nop'),(0xF8,'sed')): T[op] = (n, 'imp')
    return T
TAB = build_table()
LENM = {'imp':1,'acc':1,'imm':2,'zp':2,'zpx':2,'zpy':2,'izx':2,'izy':2,'rel':2,'abs':3,'abx':3,'aby':3,'ind':3}
HW = {0x2000:'PPU_CTRL',0x2001:'PPU_MASK',0x2002:'PPU_STATUS',0x2003:'OAM_ADDR',0x2004:'OAM_DATA',0x2005:'PPU_SCROLL',
      0x2006:'PPU_ADDR',0x2007:'PPU_DATA',0x4000:'APU_PL1_VOL',0x4001:'APU_PL1_SWEEP',0x4002:'APU_PL1_LO',0x4003:'APU_PL1_HI',
      0x4004:'APU_PL2_VOL',0x4005:'APU_PL2_SWEEP',0x4006:'APU_PL2_LO',0x4007:'APU_PL2_HI',0x4008:'APU_TRI_LINEAR',
      0x400A:'APU_TRI_LO',0x400B:'APU_TRI_HI',0x400C:'APU_NOISE_VOL',0x400E:'APU_NOISE_LO',0x400F:'APU_NOISE_HI',
      0x4010:'APU_DMC_FREQ',0x4011:'APU_DMC_RAW',0x4012:'APU_DMC_START',0x4013:'APU_DMC_LEN',0x4014:'OAM_DMA',
      0x4015:'APU_SND_CHN',0x4016:'JOYPAD1',0x4017:'JOYPAD2'}
RAMN = {}
_rf = os.path.join(CONF, 'ram.json')
if os.path.exists(_rf): RAMN = {int(k, 16): v for k, v in json.load(open(_rf)).items()}
KIND = {}
IDX = {}   # p -> set of banks-of-referrers (indexed abs operand targets)
RANK = {'sub': 3, 'loc': 2, 'data': 1}
def mark(p, k):
    if RANK[k] > RANK.get(KIND.get(p), 0): KIND[p] = k
def p_of(bank, addr): return bank * 0x4000 + (addr & 0x3FFF)
def bank_of(p): return p >> 14
def addr_of(p): return 0xC000 + (p & 0x3FFF)
def resolve(cur_p, target):
    """CPU target -> PRG offset, or None if unknown/not ROM."""
    if target >= 0xC000: return p_of(0, target)     # $8000-$BFFF is the same 16 KB mirrored; left numeric so bytes stay exact
    return None
def decode(p):
    op = PRG[p]
    if op not in TAB: return None
    n, m = TAB[op]; l = LENM[m]
    if (p & 0x3FFF) + l > 0x4000: return None
    return op, n, m, l, PRG[p+1:p+l]
def load_roots(files=None):
    """Executed opcode offsets (PRG-relative) recorded from play: config/<ver>/coverage.json.
    The jp version also inherits us coverage wherever the instruction bytes are identical."""
    roots = set(json.load(open(os.path.join(CONF, 'coverage.json'))))
    if VER != 'us':
        usrom = os.path.join(PROJ, 'orig', 'excitebike_us.nes'); usc = os.path.join(PROJ, 'config', 'us', 'coverage.json')
        if os.path.exists(usrom) and os.path.exists(usc):
            us = open(usrom, 'rb').read()[16:16 + PRGSIZE]
            for p in json.load(open(usc)):
                op = us[p]
                if op in TAB:
                    l = LENM[TAB[op][1]]
                    if us[p:p + l] == PRG[p:p + l]: roots.add(p)
    return roots
def parse_loc(x):
    b, a = x.split(':'); return p_of(int(b), int(a, 16))
def load_hints():
    f = os.path.join(CONF, 'hints.json')
    h = json.load(open(f)) if os.path.exists(f) else {}
    code = [parse_loc(x) for x in h.get('code', [])]
    forbid = set()
    for r in h.get('data', []):          # "bank:start-end" inclusive, CPU addresses
        b, rng = r.split(':'); lo, hi = [int(v, 16) for v in rng.split('-')]
        for a in range(lo, hi + 1): forbid.add(p_of(int(b), a))
    return code, forbid
def classify(roots, extra_code=()):
    hint_code, forbid = load_hints(); extra_code = list(extra_code) + hint_code
    code = [None] * len(PRG)          # None=data, else instruction start offsets flag 'S' / 'c' for continuation
    labels = set()
    work = sorted(roots) + list(extra_code)
    vec = [PRG[VECOFF + i*2] | PRG[VECOFF + 1 + i*2] << 8 for i in range(3)]
    for v in vec:
        if v >= 0xC000: work.append(p_of(0, v))
    seen_exec = set(roots)
    conflicts = []
    while work:
        p = work.pop()
        while True:
            if p is None or p >= len(PRG) or code[p] == 'S': break
            d = decode(p)
            if d is None: break
            op, n, m, l, ob = d
            if any(p + i in forbid for i in range(l)): break
            if any(code[p+i] for i in range(l)):
                conflicts.append(p); break
            code[p] = 'S'
            for i in range(1, l): code[p+i] = 'c'
            tgt = None
            if m == 'rel':
                t = (addr_of(p) + 2 + (ob[0] - 256 if ob[0] > 127 else ob[0])) & 0xFFFF
                tgt = resolve(p, t)
            elif n in ('jsr', 'jmp') and m == 'abs':
                tgt = resolve(p, ob[0] | ob[1] << 8)
            if tgt is not None:
                labels.add(tgt); work.append(tgt); mark(tgt, 'sub' if n == 'jsr' else 'loc')
            elif m in ('abs', 'abx', 'aby') and n not in ('jsr', 'jmp'):
                dp = resolve(p, ob[0] | ob[1] << 8)
                if dp is not None:
                    labels.add(dp); mark(dp, 'data')
                    if m in ('abx', 'aby'): IDX.setdefault(dp, set()).add(p)
            if n in ('rts', 'rti', 'jmp', 'brk'): break
            p += l
    return code, labels, conflicts

# ---------- pointer-table discovery ----------
TABLES = {}   # p -> dict(kind='word'|'split', n, trick, other=p_hi)
def _plaus(p, need=3):
    q = p; cnt = 0; lim = (p >> 14 << 14) + 0x4000
    while q < lim and cnt < 16:
        d = decode(q)
        if d is None: return False
        op, n, m, l, ob = d
        if m == 'rel':
            t = (addr_of(q) + 2 + (ob[0] - 256 if ob[0] > 127 else ob[0])) & 0xFFFF
            if t < 0x8000: return False
        cnt += 1; q += l
        if n in ('rts', 'rti', 'jmp'): return cnt >= need
        if n == 'brk': return False
    return cnt >= need
def _entry_ok(q, v, code, need=1):
    t = resolve(q, v)
    return t is not None and code[t] != 'c' and _plaus(t, need), t
def discover_tables(code):
    """Pointer tables found via paired indexed loads (word interleaved, or split lo/hi). Returns list of new code roots."""
    new = []
    idx = sorted(IDX)
    S = set(idx)
    for p in idx:
        if p in TABLES or code[p] == 'S' or code[p] == 'c': continue
        # interleaved: p (lo) and p+1 (hi) both indexed
        if (p + 1) in S and (p >> 14) == ((p + 1) >> 14):
            for trick in (0, 1):
                tg = []; q = p
                while q + 1 < (p >> 14 << 14) + 0x4000 and len(tg) < 128 and code[q] is None and code[q+1] is None:
                    ok, t = _entry_ok(q, (PRG[q] | PRG[q+1] << 8) + trick, code)
                    if not ok: break
                    tg.append(t); q += 2
                if len(tg) >= 3:
                    TABLES[p] = dict(kind='word', n=len(tg), trick=trick, tg=tg); new += tg; break
            continue
        # split lo/hi: another indexed label p2 > p within 128 bytes; entries (PRG[p+i], PRG[p2+i])
        for p2 in idx:
            if p2 <= p or p2 - p > 128 or (p2 >> 14) != (p >> 14): continue
            n = p2 - p
            for trick in (0, 1):
                tg = []
                for i in range(n):
                    if code[p+i] is not None or code[p2+i] is not None: break
                    ok, t = _entry_ok(p + i, (PRG[p+i] | PRG[p2+i] << 8) + trick, code)
                    if not ok: break
                    tg.append(t)
                if len(tg) == n and n >= 3:
                    TABLES[p] = dict(kind='split', n=n, trick=trick, tg=tg, hi=p2); new += tg; break
            if p in TABLES: break
            # data-pointer variant: every (lo, hi) pair is a ROM address that is not code
            if n >= 4 and all(code[p+i] is None and code[p2+i] is None for i in range(n)):
                dt = []
                for i in range(n):
                    v = PRG[p+i] | PRG[p2+i] << 8
                    t = resolve(p + i, v) if 0xC000 <= v < 0xFFFA else None
                    if t is None or code[t] is not None: dt = None; break
                    dt.append(t)
                if dt and len(set(dt)) >= max(3, n // 2):
                    TABLES[p] = dict(kind='split', n=n, trick=0, tg=dt, hi=p2, data=True); break
        if p in TABLES: continue
        # plain word table: needs two load sites of the label (low byte, then high byte), >=3 consecutive pointers,
        # mostly into already-known code (anchored), at least 3 distinct
        if len(IDX.get(p, ())) < 2: continue
        for trick in (0, 1):
            tg = []; q = p
            while q + 1 < (p >> 14 << 14) + 0x4000 and len(tg) < 128 and code[q] is None and code[q+1] is None and (q == p or q not in S):
                ok, t = _entry_ok(q, (PRG[q] | PRG[q+1] << 8) + trick, code, 2)
                if not ok: break
                tg.append(t); q += 2
            if len(tg) >= 3 and len(set(tg)) >= 3 and sum(1 for x in tg if code[x] == 'S') * 10 >= len(tg) * 6:
                TABLES[p] = dict(kind='word', n=len(tg), trick=trick, tg=tg); new += tg; break
    return new
HEUR = set()
def classify_full(roots):
    import gapscan
    TABLES.clear(); IDX.clear(); HEUR.clear(); extra = []
    for _ in range(8):
        code, labels, conf = classify(roots, extra)
        new = [t for t in discover_tables(code) if code[t] != 'S']
        for p, n, l in gapscan.candidates(code, 3):
            if n >= 6 or (p & 0x3FFF) == 0:
                new.append(p); HEUR.add(p)
        if not new: break
        extra = list(set(extra) | set(new))
    for t in TABLES.values():
        for x in t['tg']: labels.add(x); mark(x, 'data' if t.get('data') else 'sub')
    return code, labels, conf
# ---------- emission ----------
MODFILES = []   # (name, start_p, end_p) filled by emit
def load_comments():
    f = os.path.join(CONF, 'comments.json')
    return {int(k, 16): v for k, v in json.load(open(f)).items()} if os.path.exists(f) else {}
def load_modules():
    f = os.path.join(CONF, 'modules.json')
    m = json.load(open(f)) if os.path.exists(f) else {}
    return sorted((p_of(0, int(k, 16)), v) for k, v in m.items())
def load_names():
    f = os.path.join(CONF, 'names.json')
    return json.load(open(f)) if os.path.exists(f) else {}
def lname(p, names):
    key = f'{addr_of(p):04X}' if True else ''
    if key in names: return names[key]
    pre = {'sub': 'Sub', 'loc': 'Loc', 'data': 'Data'}.get(KIND.get(p), 'Loc')
    return f'{pre}_{addr_of(p):04X}' 
def fmt_operand(p, n, m, ob, labels, names):
    if m == 'imp': return n
    if m == 'acc': return n + ' a'
    v = ob[0] if len(ob) == 1 else ob[0] | ob[1] << 8
    if m == 'imm': return f'{n} #${v:02X}'
    if m == 'rel':
        t = (addr_of(p) + 2 + (v - 256 if v > 127 else v)) & 0xFFFF
        tp = resolve(p, t)
        if tp is None or tp not in labels: return None
        if CODE[0][tp] == 'c': return f'{n} *{(t - addr_of(p)):+d}'
        return f'{n} {lname(tp, names)}'
    sym = None
    if m in ('abs', 'abx', 'aby', 'ind'):
        tp = resolve(p, v)
        if v in HW: sym = HW[v]
        elif v in RAMN and m != 'ind': sym = ('a:' if v < 0x100 else '') + RAMN[v]
        elif tp is not None and tp in labels: sym = lname(tp, names)
        elif v < 0x100: sym = f'${v:04X}' if m == 'ind' else f'a:${v:02X}'
        else: sym = f'${v:04X}'
    elif m in ('izx', 'izy'):
        sym = RAMN.get(v, f'${v:02X}')
    else:
        sym = 'z:' + RAMN[v] if v in RAMN else f'z:${v:02X}'
    return {'abs': f'{n} {sym}', 'abx': f'{n} {sym},x', 'aby': f'{n} {sym},y', 'ind': f'{n} ({sym})',
            'zp': f'{n} {sym}', 'zpx': f'{n} {sym},x', 'zpy': f'{n} {sym},y', 'izx': f'{n} ({sym},x)', 'izy': f'{n} ({sym}),y'}[m]
CODE = [None]
def emit(code, labels, outdir):
    CODE[0] = code
    names = load_names()
    os.makedirs(outdir, exist_ok=True)
    vec = [PRG[VECOFF + i*2] | PRG[VECOFF + 1 + i*2] << 8 for i in range(3)]
    vecp = [p_of(0, v) if v >= 0xC000 else None for v in vec]
    for tp, nm in zip(vecp, ('Nmi', 'Reset', 'Irq')):
        if tp is not None: names.setdefault(f'{addr_of(tp):04X}', nm); labels.add(tp); mark(tp, 'sub')
    equ = []                       # labels that fall inside an instruction -> equates
    stats = {}
    comments = load_comments()
    mods = load_modules(); MODSTART = {p: n for p, n in mods}
    if not mods: MODSTART = {p_of(0, 0xC000): 'prg'}
    MODFILES.clear(); finished = []
    for b in range(NB):
        lines = []; cur_mod = None
        p = b * 0x4000; end = p + 0x4000
        if b == FIXED: end -= 6        # vectors emitted separately
        ncode = 0; done = set()
        while p < end:
            if p in MODSTART and MODSTART[p] != cur_mod:
                if cur_mod is not None: finished.append((cur_mod, lines, mod_p0, p))
                cur_mod = MODSTART[p]; mod_p0 = p
                lines = [f'; Module {cur_mod}: ${addr_of(p):04X}-', '.segment "PRG"', '']
            if p in labels and code[p] != 'c':
                cm = comments.get(addr_of(p))
                if cm: lines += ['', *[f'; {t}' for t in cm.split('\n')]]
                lines.append(f'{lname(p, names)}:'); done.add(p)
            if code[p] == 'S':
                op, n, m, l, ob = decode(p)
                text = fmt_operand(p, n, m, ob, labels, names)
                if text is None:
                    lines.append(f'  .byte {", ".join(f"${x:02X}" for x in PRG[p:p+l])}  ; ${addr_of(p):04X} {n} (target outside bank)')
                else:
                    lines.append(f'  {text:<28} ; ${addr_of(p):04X}' + ('  [heuristic code]' if p in HEUR else ''))
                p += l; ncode += l; continue
            tb = TABLES.get(p)
            hi = next((t for t in TABLES.values() if t['kind'] == 'split' and t['hi'] == p), None)
            sfx = lambda t: '-1' if t['trick'] else ''
            if tb and tb['kind'] == 'word' and all(p + 2 * i + 1 < end for i in range(tb['n'])):
                lines.append(f'  .addr ' + ', '.join(lname(x, names) + sfx(tb) for x in tb['tg']) + f'  ; ${addr_of(p):04X} pointer table')
                for i in range(1, 2 * tb['n']):
                    if p + i in labels: pass
                p += 2 * tb['n']; continue
            if tb and tb['kind'] == 'split':
                lines.append(f'  .byte ' + ', '.join('<(' + lname(x, names) + sfx(tb) + ')' for x in tb['tg']) + f'  ; ${addr_of(p):04X} pointer table (low bytes)')
                p += tb['n']; continue
            if hi:
                lines.append(f'  .byte ' + ', '.join('>(' + lname(x, names) + sfx(hi) + ')' for x in hi['tg']) + f'  ; ${addr_of(p):04X} pointer table (high bytes)')
                p += hi['n']; continue
            # data run
            q = p
            while q < end and code[q] is None and (q == p or (q not in labels and q not in MODSTART)) and q - p < 16: q += 1
            if q == p: q = p + 1
            # data stays out of the repository: it is read from assets/<ver>/prg_bank_N.bin (extracted from your ROM)
            while q < end and code[q] is None and q not in labels and q not in MODSTART and (q - p) < 0x400 and not (TABLES.get(q) or any(t['kind'] == 'split' and t['hi'] == q for t in TABLES.values())): q += 1
            lines.append(f'  .incbin "prg_bank_{b}.bin", ${p & 0x3FFF:04X}, ${q - p:X}  ; ${addr_of(p):04X}')
            p = q
        for lp in sorted(labels):
            if bank_of(lp) == b and lp not in done:
                equ.append(f'{lname(lp, names)} = ${addr_of(lp):04X}')
        if b == FIXED:
            lines += ['', '.segment "PRG"', '; hardware vectors']
            lines.append('  .addr ' + ', '.join(lname(t, names) if t is not None else f'${v:04X}' for t, v in zip(vecp, vec)))
            # NOTE: segment already active; first line emitted before vectors
        stats[b] = ncode
        finished.append((cur_mod, lines, mod_p0, b * 0x4000 + 0x4000))
    for old_f in glob.glob(os.path.join(outdir, '*.asm')): os.remove(old_f)
    for name, ls, p0, p1 in finished:
        open(os.path.join(outdir, f'{name}.asm'), 'w').write(chr(10).join(ls) + chr(10)); MODFILES.append((name, p0, p1))
    hw = ['; Hardware register equates'] + [f'{n} = ${a:04X}' for a, n in sorted(HW.items())]
    hw += ['', '; RAM variables'] + [f'{n} = ${a:04X}' for a, n in sorted(RAMN.items())]
    open(os.path.join(outdir, 'hardware.inc'), 'w').write('\n'.join(hw) + '\n')
    open(os.path.join(outdir, 'inside_instr.inc'), 'w').write('; labels that point inside an instruction\n' + '\n'.join(equ) + '\n')
    hdr = ROM[:16]
    main = ['; Excitebike (%s) - NES, NROM-128. GENERATED by tools/ebdis.py; edit config/%s/*.json instead.' % ('Japan/USA, NTSC' if VER == 'us' else 'Europe, PAL', VER),
            '.setcpu "6502"', '.include "hardware.inc"', '', '.segment "HEADER"',
            '.byte "NES", $1A', f'.byte ${hdr[4]:02X}                        ; PRG-ROM size in 16KB units', f'.byte ${hdr[5]:02X}                        ; CHR-ROM size in 8KB units',
            f'.byte ${hdr[6]:02X}                        ; flags 6: mapper 0 (NROM), vertical mirroring', f'.byte ${hdr[7]:02X}                        ; flags 7: NES 2.0',
            '.byte ' + ', '.join(f'${x:02X}' for x in hdr[8:12]) + '                ; NES 2.0 mapper MSB/submapper, PRG/CHR size MSB, RAM sizes',
            f'.byte ${hdr[12]:02X}                        ; CPU/PPU timing (0 = NTSC, 1 = PAL)',
            f'.byte ${hdr[13]:02X}, ${hdr[14]:02X}', f'.byte ${hdr[15]:02X}                        ; default expansion device', '',
            '.include "inside_instr.inc"'] + [f'.include "{n}.asm"' for n, _, _ in MODFILES] + ['', '.segment "TILES"', '.incbin "chr.bin"']
    open(os.path.join(outdir, 'excitebike.asm'), 'w').write(chr(10).join(main) + chr(10))
    return stats
def write_assets():
    os.makedirs(ASSETS, exist_ok=True)
    for b in range(NB): open(os.path.join(ASSETS, f'prg_bank_{b}.bin'), 'wb').write(PRG[b * 0x4000:(b + 1) * 0x4000])
    open(os.path.join(ASSETS, 'chr.bin'), 'wb').write(ROM[16 + PRGSIZE:16 + PRGSIZE + CHRSIZE])
if __name__ == '__main__':
    os.makedirs(SRCDIR, exist_ok=True); write_assets()
    roots = load_roots()
    code, labels, conf = classify_full(roots)
    st = emit(code, labels, SRCDIR)
    print(f'[{VER}] roots', len(roots), 'code bytes per bank', st, 'conflicts', len(conf))
