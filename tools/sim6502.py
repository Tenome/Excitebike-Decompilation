"""Minimal NMOS 6502 interpreter (official opcodes) used to differential-test lifted C routines against the original code.
Memory: 2 KB RAM mirrored through $0000-$1FFF, PRG-ROM at $C000-$FFFF (mirrored at $8000), everything else reads 0 and ignores writes
(PPU/APU/joypad registers are recorded in .io_writes so tests can compare them)."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

class CPU:
    def __init__(self, prg):
        self.prg = prg; self.ram = bytearray(0x800)
        self.a = self.x = self.y = 0; self.sp = 0xFF; self.pc = 0
        self.c = self.z = self.i = self.d = self.v = self.n = 0
        self.io_writes = []; self.cycles = 0; self.io_reads = {}; self.io_seq = {}; self.io_seq_i = {}; self.clear_on_status = None   # io_seq: address -> list of values returned by successive reads (wraps around)
        self.model = False; self.pad_buttons = [0, 0]; self.pad_shift = [0, 0]; self.status_reads = 0   # optional hardware model (see tools/fulltest.py)
    # -- memory
    def rd(self, a):
        a &= 0xFFFF
        if a < 0x2000: return self.ram[a & 0x7FF]
        if a >= 0x8000: return self.prg[a & 0x3FFF]
        if a == 0x2002 and self.clear_on_status is not None: self.ram[self.clear_on_status] = 0     # test aid: an NMI would have run between two status polls and cleared the PPU update index
        if self.model:
            if a == 0x2002:
                c = self.status_reads & 0xFF; self.status_reads += 1
                return ((c & 1) << 6) | (((c >> 1) & 1) << 7)
            if a in (0x4016, 0x4017):
                p = a & 1; v = self.pad_shift[p] & 1; self.pad_shift[p] = (self.pad_shift[p] >> 1) | 0x80; return v
        if a in self.io_seq:
            i = self.io_seq_i.get(a, 0); self.io_seq_i[a] = i + 1; return self.io_seq[a][i % len(self.io_seq[a])]
        if a in self.io_reads: return self.io_reads[a]
        return 0
    def wr(self, a, v):
        a &= 0xFFFF; v &= 0xFF
        if a < 0x2000: self.ram[a & 0x7FF] = v
        elif a < 0x8000:
            self.io_writes.append((a, v))
            if self.model and a == 0x4016 and not v & 1: self.pad_shift = list(self.pad_buttons)
    def rd16(self, a): return self.rd(a) | self.rd((a + 1) & 0xFFFF) << 8
    def rd16zp(self, a): return self.rd(a & 0xFF) | self.rd((a + 1) & 0xFF) << 8
    # -- stack / flags
    def push(self, v): self.wr(0x100 + self.sp, v); self.sp = (self.sp - 1) & 0xFF
    def pull(self): self.sp = (self.sp + 1) & 0xFF; return self.rd(0x100 + self.sp)
    def getp(self, b=0x30): return self.c | self.z << 1 | self.i << 2 | self.d << 3 | self.v << 6 | self.n << 7 | b
    def setp(self, p): self.c = p & 1; self.z = p >> 1 & 1; self.i = p >> 2 & 1; self.d = p >> 3 & 1; self.v = p >> 6 & 1; self.n = p >> 7 & 1
    def nz(self, v): v &= 0xFF; self.z = int(v == 0); self.n = v >> 7; return v
    # -- addressing: returns effective address (or None for implied/acc/imm handled by caller)
    def ea(self, mode):
        pc = self.pc
        if mode == 'imm': self.pc += 1; return pc
        if mode == 'zp': self.pc += 1; return self.rd(pc)
        if mode == 'zpx': self.pc += 1; return (self.rd(pc) + self.x) & 0xFF
        if mode == 'zpy': self.pc += 1; return (self.rd(pc) + self.y) & 0xFF
        if mode == 'abs': self.pc += 2; return self.rd16(pc)
        if mode == 'abx': self.pc += 2; return (self.rd16(pc) + self.x) & 0xFFFF
        if mode == 'aby': self.pc += 2; return (self.rd16(pc) + self.y) & 0xFFFF
        if mode == 'izx': self.pc += 1; return self.rd16zp(self.rd(pc) + self.x)
        if mode == 'izy': self.pc += 1; return (self.rd16zp(self.rd(pc)) + self.y) & 0xFFFF
        if mode == 'ind':
            self.pc += 2; p = self.rd16(pc)
            return self.rd(p) | self.rd((p & 0xFF00) | ((p + 1) & 0xFF)) << 8   # 6502 page-wrap bug
        raise ValueError(mode)
    def adc(self, v):
        r = self.a + v + self.c
        self.v = int((~(self.a ^ v) & (self.a ^ r) & 0x80) != 0); self.c = int(r > 0xFF); self.a = self.nz(r)
    def cmp(self, r, v): self.c = int(r >= v); self.nz(r - v)
    def step(self):
        from ebdis import TAB
        op = self.rd(self.pc); self.pc += 1
        if op not in TAB: raise RuntimeError(f'unsupported opcode {op:02X} at {self.pc - 1:04X}')
        n, m = TAB[op]
        if m == 'rel':
            off = self.rd(self.pc); self.pc += 1
            cond = {'bpl': not self.n, 'bmi': self.n, 'bvc': not self.v, 'bvs': self.v, 'bcc': not self.c, 'bcs': self.c, 'bne': not self.z, 'beq': self.z}[n]
            if cond: self.pc = (self.pc + (off - 256 if off > 127 else off)) & 0xFFFF
            return
        if m in ('imp', 'acc'):
            if m == 'acc':
                a = self.a
                if n == 'asl': self.c = a >> 7; self.a = self.nz(a << 1)
                elif n == 'lsr': self.c = a & 1; self.a = self.nz(a >> 1)
                elif n == 'rol': c = self.c; self.c = a >> 7; self.a = self.nz(a << 1 | c)
                elif n == 'ror': c = self.c; self.c = a & 1; self.a = self.nz(a >> 1 | c << 7)
                return
            if n == 'nop': pass
            elif n == 'brk': raise RuntimeError('brk')
            elif n == 'rts': self.pc = (self.pull() | self.pull() << 8) + 1
            elif n == 'rti': self.setp(self.pull()); self.pc = self.pull() | self.pull() << 8
            elif n == 'pha': self.push(self.a)
            elif n == 'php': self.push(self.getp())
            elif n == 'pla': self.a = self.nz(self.pull())
            elif n == 'plp': self.setp(self.pull())
            elif n == 'clc': self.c = 0
            elif n == 'sec': self.c = 1
            elif n == 'cli': self.i = 0
            elif n == 'sei': self.i = 1
            elif n == 'cld': self.d = 0
            elif n == 'sed': self.d = 1
            elif n == 'clv': self.v = 0
            elif n == 'tax': self.x = self.nz(self.a)
            elif n == 'tay': self.y = self.nz(self.a)
            elif n == 'txa': self.a = self.nz(self.x)
            elif n == 'tya': self.a = self.nz(self.y)
            elif n == 'tsx': self.x = self.nz(self.sp)
            elif n == 'txs': self.sp = self.x
            elif n == 'inx': self.x = self.nz(self.x + 1)
            elif n == 'iny': self.y = self.nz(self.y + 1)
            elif n == 'dex': self.x = self.nz(self.x - 1)
            elif n == 'dey': self.y = self.nz(self.y - 1)
            else: raise RuntimeError(n)
            return
        if n == 'jsr':
            t = self.rd16(self.pc); ret = self.pc + 1; self.push(ret >> 8); self.push(ret & 0xFF); self.pc = t; return
        if n == 'jmp': self.pc = self.ea(m); return
        a = self.ea(m)
        if n == 'lda': self.a = self.nz(self.rd(a))
        elif n == 'ldx': self.x = self.nz(self.rd(a))
        elif n == 'ldy': self.y = self.nz(self.rd(a))
        elif n == 'sta': self.wr(a, self.a)
        elif n == 'stx': self.wr(a, self.x)
        elif n == 'sty': self.wr(a, self.y)
        elif n == 'adc': self.adc(self.rd(a))
        elif n == 'sbc': self.adc(self.rd(a) ^ 0xFF)
        elif n == 'and': self.a = self.nz(self.a & self.rd(a))
        elif n == 'ora': self.a = self.nz(self.a | self.rd(a))
        elif n == 'eor': self.a = self.nz(self.a ^ self.rd(a))
        elif n == 'cmp': self.cmp(self.a, self.rd(a))
        elif n == 'cpx': self.cmp(self.x, self.rd(a))
        elif n == 'cpy': self.cmp(self.y, self.rd(a))
        elif n == 'bit': v = self.rd(a); self.z = int((self.a & v) == 0); self.n = v >> 7; self.v = v >> 6 & 1
        elif n == 'inc': self.wr(a, self.nz(self.rd(a) + 1))
        elif n == 'dec': self.wr(a, self.nz(self.rd(a) - 1))
        elif n in ('asl', 'lsr', 'rol', 'ror'):
            v = self.rd(a)
            if n == 'asl': self.c = v >> 7; r = v << 1
            elif n == 'lsr': self.c = v & 1; r = v >> 1
            elif n == 'rol': c = self.c; self.c = v >> 7; r = v << 1 | c
            else: c = self.c; self.c = v & 1; r = v >> 1 | c << 7
            self.wr(a, self.nz(r))
        else: raise RuntimeError(n)
    def call(self, addr, a=0, x=0, y=0, c=0, max_steps=200000, stop=None, rti=False):
        """Run the routine at addr (JSR-style) until it returns; returns (a, x, y, carry)."""
        self.a, self.x, self.y, self.c = a, x, y, c; self.sp = 0xFF
        if rti: self.push(0xFF); self.push(0xFE); self.push(0x00)     # interrupt-style return (RTI): P, then PC = $FFFE
        else: self.push(0xFF); self.push(0xFD)          # return to $FFFE (RTS adds 1)
        self.pc = addr
        for _ in range(max_steps):
            if self.pc == 0xFFFE or self.pc == stop: return self.a, self.x, self.y, self.c
            self.step()
        raise RuntimeError('routine did not return')
