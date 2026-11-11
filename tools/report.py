#!/usr/bin/env python3
"""Write an objdiff-format progress report (progress/<ver>/report.json) for ByteMatch.

One unit per PRG bank (main/bank_N) plus main/chr. Code = classified instructions, split into routines at
JSR targets, vectors and named labels. Data = every other byte (PRG data runs and CHR-ROM).
The source is assembly that rebuilds the ROM byte for byte, so every item reports 100 % once tools/build.py prints MATCH;
the report refuses to be written otherwise (use --no-verify only if cc65 is unavailable).
It holds names, addresses, sizes and percentages only - no game bytes.
usage: python tools/report.py [--version us|jp] [--cc65 DIR] [--no-verify]"""
import argparse, json, os, subprocess, sys
ap = argparse.ArgumentParser(); ap.add_argument('--version', default='us', choices=['us', 'eu']); ap.add_argument('--cc65'); ap.add_argument('--no-verify', action='store_true')
a = ap.parse_args()
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..'))
sys.argv = [sys.argv[0], '--version', a.version]; sys.path.insert(0, HERE)
import ebdis as g

def measures(code, data, units=0, complete_units=0):
    tc = sum(i['size'] for i in code); mc = sum(i['size'] for i in code if i['pct'] >= 100)
    td = sum(i['size'] for i in data); md = sum(i['size'] for i in data if i['pct'] >= 100)
    fz = sum(i['size'] * i['pct'] for i in code) / tc if tc else 0.0
    cc = tc if code and mc == tc else 0; cd = td if data and md == td else 0
    return {'fuzzy_match_percent': round(fz, 4), 'total_code': str(tc), 'matched_code': str(mc),
            'matched_code_percent': round(100.0 * mc / tc, 4) if tc else 0.0,
            'total_data': str(td), 'matched_data': str(md), 'matched_data_percent': round(100.0 * md / td, 4) if td else 0.0,
            'total_functions': len(code), 'matched_functions': sum(1 for i in code if i['pct'] >= 100),
            'matched_functions_percent': round(100.0 * sum(1 for i in code if i['pct'] >= 100) / len(code), 4) if code else 0.0,
            'complete_code': str(cc), 'complete_code_percent': round(100.0 * cc / tc, 4) if tc else 0.0,
            'complete_data': str(cd), 'complete_data_percent': round(100.0 * cd / td, 4) if td else 0.0,
            'total_units': units, 'complete_units': complete_units}
def item(i):
    return {'name': i['name'], 'size': str(i['size']), 'fuzzy_match_percent': round(i['pct'], 4), 'metadata': {'virtual_address': str(i['addr'])}}

def main():
    pct = 100.0
    if not a.no_verify:
        cmd = [sys.executable, os.path.join(HERE, 'build.py'), '--version', a.version] + (['--cc65', a.cc65] if a.cc65 else [])
        r = subprocess.run(cmd, capture_output=True, text=True); print(r.stdout.strip() or r.stderr.strip())
        if r.returncode != 0: sys.exit('build does not match the original ROM; not writing a report')
    roots = g.load_roots()
    code, labels, conf = g.classify_full(roots)
    names = g.load_names()
    units = []; all_code = []; all_data = []
    mods = g.load_modules() or [(0, 'prg')]
    ranges = [(p, mods[k + 1][0] if k + 1 < len(mods) else g.PRGSIZE, n) for k, (p, n) in enumerate(mods)]
    for lo, hi, mname in ranges:
        funcs, data = [], []
        p = lo
        while p < hi:
            if code[p] is not None:                       # code run -> routines
                start = p
                while p < hi and code[p] is not None:
                    p += 1
                    if p < hi and code[p] == 'S' and g.KIND.get(p) == 'sub':
                        funcs.append((start, p)); start = p
                funcs.append((start, p))
            else:                                         # data run, split at data labels
                start = p
                while p < hi and code[p] is None and (p == start or not (p in labels and g.KIND.get(p) == 'data')): p += 1
                data.append((start, p))
        fi = [{'name': g.lname(s, names), 'size': e - s, 'pct': pct, 'addr': s + 16} for s, e in funcs]
        di = [{'name': ('Data_%04X' % g.addr_of(s)) if g.lname(s, names).startswith(('Loc', 'Sub')) else g.lname(s, names), 'size': e - s, 'pct': pct, 'addr': s + 16} for s, e in data]
        units.append((f'main/{mname}', fi, di, f'src/{a.version}/{mname}.asm'))
    units.append(('main/chr', [], [{'name': 'ChrRom', 'size': g.CHRSIZE, 'pct': pct, 'addr': 16 + g.PRGSIZE}], f'src/{a.version}/excitebike.asm'))
    out_units = []
    for name, fi, di, srcp in units:
        m = measures(fi, di, 1, 1)
        secs = []
        if fi: secs.append({'name': '.text', 'size': str(sum(i['size'] for i in fi)), 'fuzzy_match_percent': m['fuzzy_match_percent']})
        if di: secs.append({'name': '.data', 'size': str(sum(i['size'] for i in di)), 'fuzzy_match_percent': m['matched_data_percent']})
        out_units.append({'name': name, 'measures': m, 'sections': secs, 'functions': [item(i) for i in fi],
                          'metadata': {'complete': True, 'source_path': srcp}})
        all_code += fi; all_data += di
    report = {'measures': measures(all_code, all_data, len(out_units), len(out_units)), 'units': out_units, 'version': 2, 'categories': []}
    outp = os.path.join(ROOT, 'progress', a.version, 'report.json'); os.makedirs(os.path.dirname(outp), exist_ok=True)
    with open(outp, 'w', encoding='utf-8', newline='\n') as fh: json.dump(report, fh, indent=1)
    m = report['measures']
    print('report %s: %d/%d routines, %s of %s code bytes, %s data bytes, %d units' % (outp, m['matched_functions'], m['total_functions'], m['matched_code'], m['total_code'], m['total_data'], len(out_units)))
main()
