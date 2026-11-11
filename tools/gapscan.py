"""Candidate code starts in data gaps: gap start right after a terminator, plausible chain ending in terminator."""
import sys, glob
sys.path.insert(0, '.')
import ebdis as g
def chain_info(code, p, lim):
    q = p; n = 0; bad = 0
    while q < lim:
        if code[q] is not None: return None
        d = g.decode(q)
        if d is None: return None
        op, mn, m, l, ob = d
        if any(code[q + i] is not None for i in range(l)): return None
        if m == 'rel':
            t = (g.addr_of(q) + 2 + (ob[0] - 256 if ob[0] > 127 else ob[0])) & 0xFFFF
            if t < 0x8000 or t > 0xFFFF: return None
        if mn in ('jsr', 'jmp') and m == 'abs':
            v = ob[0] | ob[1] << 8
            if not (0x8000 <= v) : return None
        if mn == 'brk': return None
        n += 1; q += l
        if mn in ('rts', 'rti', 'jmp'): return n, q
    return None
def candidates(code, min_n=3):
    out = []
    for b in range(g.NB):
        lo, hi = b * 0x4000, (b + 1) * 0x4000 - (6 if b == g.FIXED else 0)
        p = lo
        while p < hi:
            if code[p] is None and (p == lo or code[p-1] is not None):
                # previous byte belongs to code (continuation or start) and previous instruction was terminator?
                r = chain_info(code, p, hi)
                if r and r[0] >= min_n and len(set(g.PRG[p:r[1]])) > 2:
                    out.append((p, r[0], r[1] - p)); p = r[1]; continue
            p += 1
    return out
if __name__ == '__main__':
    roots = g.load_roots(glob.glob('../trace/cov_*.json'))
    code, labels, conf = g.classify_full(roots)
    c = candidates(code); print(len(c))
    import collections; print(collections.Counter(g.bank_of(p) for p, n, l in c))
    for p, n, l in c[:25]: print(f'bank{g.bank_of(p)} ${g.addr_of(p):04X} n={n} len={l}')
