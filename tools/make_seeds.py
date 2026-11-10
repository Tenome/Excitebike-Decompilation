"""Write NESRecomp cycle seeds (4k:BB:AAAA, BB = hex 4KB PRG bank) for every classified instruction start.
usage: python tools/make_seeds.py [--version us|jp] OUT.txt"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
out = sys.argv.pop()
import ebdis as g
code, labels, conf = g.classify_full(g.load_roots())
n = 0
with open(out, 'w') as f:
    f.write('# NESRecomp seeds generated from tools/ebdis.py classification: 4KB PRG bank (hex), CPU address, count\n')
    for p in range(len(code)):
        if code[p] == 'S': f.write(f'4k:{p >> 12:X}:{g.addr_of(p):04X} 1\n'); n += 1
print(n, 'seeds ->', out)
