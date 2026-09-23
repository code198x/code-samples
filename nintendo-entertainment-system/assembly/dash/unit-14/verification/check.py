#!/usr/bin/env python3
"""Measure Dash's unchanged NMI paths through the native NES MCP interface."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
UNIT = HERE.parent
spec = importlib.util.spec_from_file_location('intro_timing', UNIT.parents[1] / 'meet-the-machine/verification/timing.py')
intro = importlib.util.module_from_spec(spec)
spec.loader.exec_module(intro)

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    rom = UNIT / 'dash.nes'
    rebuilt = args.output / 'dash.nes'
    subprocess.run(['asm198x', '--dialect', 'ca65', str(UNIT / 'dash.asm'), '-o', str(rebuilt)], check=True)
    assert rebuilt.read_bytes() == rom.read_bytes(), 'Baseline rebuild differs'
    data = rom.read_bytes()
    nmi = int.from_bytes(data[16+0x7ffa:16+0x7ffc], 'little')
    def code(pc):
        return data[16+pc-0x8000:16+pc-0x8000+3]
    rows = []
    m = intro.Machine(str(args.emulator.resolve()), rom)
    try:
        m.call('run_frames', frames=5)
        assert m.query('ppu.mask') == 30
        for name, game_over, drawn in [('playing', 0, 0), ('first_game_over', 1, 0), ('already_drawn', 1, 1)]:
            for repeat in range(4):
                m.call('run_until_pc', addr=nmi, max_steps=100000)
                # Diagnostic setup at handler entry, not a play-through claim.
                m.call('poke_byte', addr=11, value=game_over)
                m.call('poke_byte', addr=12, value=drawn)
                start = m.query('machine.master_clock')
                registers = {r:m.query('cpu.'+r) for r in ('a','x','y','sp')}
                trace = []
                static_cycles = 0
                dma_cycles = 0
                writes = 0
                for _ in range(100):
                    pc = m.query('cpu.pc')
                    raw = code(pc)
                    before = m.query('machine.master_clock')
                    result = m.call('step', instructions=1)
                    ticks = m.query('machine.master_clock') - before
                    assert ticks % 3 == 0
                    costs = {0x48:3, 0x8a:2, 0x98:2, 0xa9:2, 0x8d:4,
                             0x2c:4, 0xa5:3, 0x18:2, 0x69:2, 0x85:3,
                             0x68:4, 0xa8:2, 0xaa:2, 0x40:6}
                    if raw[0] in (0xf0, 0xd0):
                        fallthrough = pc + 2
                        taken = result['pc'] != fallthrough
                        expected = 2 + int(taken) + int(taken and (fallthrough >> 8) != (result['pc'] >> 8))
                    else:
                        expected = costs[raw[0]]
                    static_cycles += expected
                    stall = ticks//3 - expected
                    if stall:
                        assert pc == nmi + 15 and stall in (513, 514), (pc, stall)
                        dma_cycles += stall
                    if raw[:3] == bytes([0x8d, 7, 0x20]):
                        writes += 1
                    trace.append({'pc':hex(pc), 'opcode':hex(raw[0]), 'cycles_with_stalls':ticks//3,
                                  'next_pc':hex(result['pc'])})
                    if raw[0] == 0x40:
                        break
                else:
                    raise AssertionError('Handler did not return')
                elapsed = (m.query('machine.master_clock') - start)//3
                assert {r:m.query('cpu.'+r) for r in registers} == {**registers, 'sp':(registers['sp']+3)&255}
                assert static_cycles == {'playing':119, 'first_game_over':193, 'already_drawn':124}[name]
                assert dma_cycles in (513, 514)
                assert writes == (11 if name == 'first_game_over' else 2)
                assert 241 <= m.query('ppu.scanline') < 261
                rows.append({'path':name, 'repeat':repeat, 'handler_cycles_with_dma':elapsed,
                             'instruction_cycles':static_cycles, 'dma_cycles':dma_cycles, 'ppudata_writes':writes,
                             'entry_dot_clock':start, 'return_scanline':m.query('ppu.scanline'),
                             'return_dot':m.query('ppu.dot'), 'trace':trace})
                print(name, elapsed, flush=True)
        result = {'configuration':'NES NTSC, rendering enabled, DMC disabled; flags injected at NMI entry',
                  'boundary':'First PHA through completed RTI; excludes interrupt entry and notification latency',
                  'server':m.server, 'emulator_sha256':sha(args.emulator),
                  'assembler':subprocess.check_output(['asm198x','--version'],text=True,stderr=subprocess.STDOUT).strip(),
                  'source_sha256':sha(UNIT/'dash.asm'), 'rom_sha256':sha(rom), 'nmi':hex(nmi), 'measurements':rows}
        (args.output/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    finally:
        m.close()

if __name__ == '__main__':
    main()
