"""Convert NESRecomp --miss-log files (4k:BB:AAAA count, BB hex 4KB bank) into PRG offsets and merge them
into a coverage.json (sorted list of executed-opcode PRG offsets).
usage: python tools/miss2cov.py --merge config/us/coverage.json log1.txt log2.txt ..."""
import sys, json, os
assert sys.argv[1] == "--merge"; dst = sys.argv[2]
cov = set(json.load(open(dst))) if os.path.exists(dst) else set()
before = len(cov)
for src in sys.argv[3:]:
    for line in open(src):
        if line.startswith("#") or not line.strip(): continue
        parts = line.split()[0].split(":")
        if parts[0] != "4k": continue
        cov.add(int(parts[1], 16) * 0x1000 + (int(parts[2], 16) & 0xFFF))
json.dump(sorted(cov), open(dst, "w"))
print(f"{dst}: {before} -> {len(cov)} opcodes")
