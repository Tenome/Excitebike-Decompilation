"""Biased random input route for nes_game --input. usage: mkroute.py SEED FRAMES OUT [START_AT]
Per-seed personality: how much it walks right/left/up/down, how often it fires (A/B), how often it taps Start/Select."""
import sys, random
seed, frames, out = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
start_at = int(sys.argv[4]) if len(sys.argv) > 4 else 0
rnd = random.Random(seed); f = 0; lines = []
p_right = rnd.choice([0.2, 0.4, 0.6, 0.8]); p_left = rnd.choice([0.05, 0.15, 0.3]); p_up = rnd.choice([0.1, 0.25, 0.4]); p_down = rnd.choice([0.05, 0.2, 0.35])
p_a = rnd.choice([0.2, 0.5, 0.8]); p_b = rnd.choice([0.1, 0.4, 0.7]); p_start = rnd.choice([0.0, 0.02, 0.08]); p_sel = rnd.choice([0.0, 0.01, 0.04])
hold = rnd.choice([(3, 6, 10), (10, 20, 45), (20, 45, 90)])
while f < frames:
    b = []
    for name, p in (('RIGHT', p_right), ('LEFT', p_left), ('UP', p_up), ('DOWN', p_down), ('A', p_a), ('B', p_b), ('START', p_start), ('SELECT', p_sel)):
        if rnd.random() < p: b.append(name)
    if f < start_at: b = ['START'] if (f // 40) % 2 == 0 else []
    lines.append(f"{f} {'+'.join(b) if b else '-'}")
    f += rnd.choice(hold)
open(out, 'w').write('\n'.join(lines) + '\n')
