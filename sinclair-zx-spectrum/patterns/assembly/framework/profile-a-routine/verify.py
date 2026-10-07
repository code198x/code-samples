#!/usr/bin/env python3
"""Build and measure the 32-byte fill examples using the real family tools.

No firmware download is needed: a zero-filled ROM satisfies machine creation,
then an Asm198x snapshot starts directly in RAM with interrupts disabled.
This is a controlled routine experiment, not a ROM boot or tape-load test.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def command(arguments):
    result = subprocess.run(arguments, cwd=ROOT, capture_output=True, text=True,
                            timeout=60)
    require(result.returncode == 0,
            f'{Path(arguments[0]).name} failed: {result.stderr.strip()}')
    return result.stdout


def relative(path):
    return os.path.relpath(path, ROOT)


def executable(value):
    found = shutil.which(value)
    require(found is not None, f'Executable not found: {value}')
    return str(Path(found).resolve())


def capture(source, output, assembler, emulator, ticks):
    require(source.is_file(), f'Source does not exist: {source}')
    output.mkdir(parents=True, exist_ok=True)
    paths = {ext: output / ('program.' + ext)
             for ext in ['bin', 'sna', 'debug198x', 'sym', 'listing.json']}
    assemble = [assembler, '--dialect', 'pasmo', '--cpu', 'z80']
    command([*assemble, '--debug=' + relative(paths['debug198x']),
             '--sym=' + relative(paths['sym']),
             '--listing-json=' + relative(paths['listing.json']),
             relative(source), '-o', relative(paths['bin'])])
    command([*assemble, '--sna', relative(source), '-o', relative(paths['sna'])])
    symbols = {name: int(value, 16) for name, value in re.findall(
        r'^(\w+) = \$([0-9a-fA-F]+)$', paths['sym'].read_text(), re.M)}
    require(all(name in symbols for name in
                ['main', 'end_main', 'fill_row', 'end_fill_row']),
            'The example needs main/end_main and fill_row/end_fill_row labels')
    routines = [{'name': name, 'ranges': [
        {'start': symbols[name], 'end': symbols['end_' + name]}]}
        for name in ['main', 'fill_row']]
    listing = json.loads(paths['listing.json'].read_text())
    request = {'action': 'profile_cycles', 'ticks': ticks,
               'routines': routines,
               'static_cycles': {'cpu': 'z80', 'listing': listing}}
    steps = [
        {'action': 'load_snapshot', 'path': relative(paths['sna'])},
        {'action': 'load_debug_info', 'path': relative(paths['debug198x'])},
        request,
        {'action': 'memory_read', 'addr': 0x8fff, 'len': 34},
        {'action': 'memory_read', 'addr': symbols['main'],
         'len': len(paths['bin'].read_bytes())},
        {'action': 'query_cpu'},
    ]
    script = output / 'script.json'
    script.write_text(json.dumps(steps, indent=2) + '\n')
    rom = output / 'unused-zero.rom'
    rom.write_bytes(bytes(16384))
    report = json.loads(command([emulator, '--rom', relative(rom),
                                 '--script', relative(script)]))
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    profile = next(o['profile'] for o in report['observations']
                   if o['kind'] == 'profile_cycles')
    memory = [o for o in report['observations'] if o['kind'] == 'memory_read']
    registers = next(o['registers'] for o in report['observations']
                     if o['kind'] == 'query_cpu')
    measured = {row['name']: row for row in profile['routines']}
    fill = measured['fill_row']
    require(fill['call_cost']['completed_calls'] == 1
            and fill['call_cost']['incomplete_calls'] == 0 and registers['halt'],
            'fill_row did not complete exactly once; check the capture window')
    require(memory[0]['bytes'] == [0] + [0x47] * 32 + [0],
            'Expected exactly 32 bytes of $47 with unchanged boundary guards')
    require(memory[1]['bytes'] == list(paths['bin'].read_bytes()),
            'Loaded code differs from the same-build binary')
    require(registers['hl'] == '$9020' and registers['b'] == '$00'
            and registers['a'] == '$47' and registers['sp'] == '$FF00'
            and not registers['iff1'], 'The caller/routine return contract failed')
    counts = profile['counts']
    instruction_ticks = sum(row['ticks'] for row in counts['addresses'].values())
    buckets = ['interrupt_ticks', 'halt_ticks', 'leading_partial_ticks',
               'trailing_partial_ticks']
    require(counts['ticks'] == ticks == report['time'], 'Capture duration differs')
    require(instruction_ticks + sum(counts[key] for key in buckets) == ticks,
            'Instruction, waiting and partial buckets do not conserve time')
    require(counts['interrupt_ticks'] == 0, 'Unexpected interrupt entry')
    require(profile['unmapped_ticks'] == 0
            and sum(row['ticks'] for row in profile['lines']) == instruction_ticks,
            'Some instruction time has no matching source line')
    require(profile['unassigned_routine_ticks'] == 0
            and sum(row['exclusive_ticks'] for row in measured.values())
            == instruction_ticks, 'Routine extents do not cover the executed code')
    tracking = profile['call_tracking']
    require(tracking['discontinuities'] == 0 and tracking['unresolved_calls'] == 0
            and not tracking['depth_limit_reached'], 'Incomplete call tracking')
    comparison = profile['static_comparison']
    require(comparison['ticks_per_cpu_cycle'] == 4
            and profile['clock'] == {'unit': 'master-cycle', 'rate': {
                'numerator_hz': 14000000, 'denominator_hz': 1}},
            'This lesson expects the 48K PAL clock contract')
    require(sum(comparison['uncomparable_ticks'].values()) == 0
            and comparison['compared_ticks'] == instruction_ticks,
            'Static comparison does not cover every executed instruction')
    require(all(row['relation'] == 'within_range' for row in comparison['addresses']),
            'Measured cost falls outside the same-build static range')
    require(measured['main']['call_cost']['inclusive_ticks'] == instruction_ticks,
            'Caller inclusive cost should include its one fill_row call')
    static_fill = next(row for row in comparison['routines']
                       if row['name'] == 'fill_row')
    require(all((ROOT / row['file']).resolve() == source
                for row in profile['lines']),
            'This teaching script expects one source file without includes')
    lines = source.read_text().splitlines()
    line_costs = [{**row, 't_states': row['ticks'] / 4,
                   'source': lines[row['line'] - 1].strip()}
                  for row in profile['lines']]
    return {
        'source': source.name, 'source_sha256': sha(source),
        'artifacts_sha256': {ext: sha(path) for ext, path in paths.items()},
        'routine_bytes': symbols['end_fill_row'] - symbols['fill_row'],
        'routine_instructions': fill['instructions'],
        'routine_ticks': fill['exclusive_ticks'],
        'routine_t_states': fill['exclusive_ticks'] / 4,
        'weighted_static_t_states': static_fill['expected_cycles'],
        'caller_exclusive_ticks': measured['main']['exclusive_ticks'],
        'caller_inclusive_ticks': measured['main']['call_cost']['inclusive_ticks'],
        'capture_ticks': ticks, **{key: counts[key] for key in buckets},
        'completed_calls': fill['call_cost']['completed_calls'],
        'buffer_hex': bytes(memory[0]['bytes'][1:-1]).hex(),
        'lines': line_costs,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--assembler', default='asm198x')
    parser.add_argument('--emulator', default='emu198x-spectrum')
    parser.add_argument('--output', type=Path, default=ROOT / 'build')
    parser.add_argument('--ticks', type=int, default=4096)
    parser.add_argument('--source', type=Path,
                        help='Measure an edited copy; keep the 32-byte fill contract')
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    # A failed rerun must not leave an old passing summary in this location.
    (output / 'results.json').unlink(missing_ok=True)
    assembler, emulator = executable(args.assembler), executable(args.emulator)
    sources = [args.source.resolve()] if args.source else [
        ROOT / 'loop.asm', ROOT / 'unrolled.asm']
    cases = [capture(src, output / src.stem, assembler, emulator, args.ticks)
             for src in sources]
    if not args.source:
        require([(c['routine_bytes'], c['routine_t_states']) for c in cases]
                == [(7, 844), (13, 532)],
                'The maintained examples differ from their explained baseline')
    summary = {
        'status': 'passed', 'mode': 'edited-source' if args.source else 'baseline',
        'assembler_version': command([assembler, '--version']).strip(),
        'assembler_sha256': sha(Path(assembler)),
        'emulator_sha256': sha(Path(emulator)),
        'target': '48K PAL; code $C000; buffer $9000; stack $FF00; interrupts disabled',
        'method': 'Asm198x snapshot start in RAM, Debug198x source join, exact profile window',
        'limits': 'Emulator observation with unused synthetic ROM; no ROM boot, tape loading, '
                  'contention, hardware or host-speed claim.',
        'cases': cases,
    }
    if len(cases) == 2:
        summary['saved_t_states'] = cases[0]['routine_t_states'] - cases[1]['routine_t_states']
        summary['extra_bytes'] = cases[1]['routine_bytes'] - cases[0]['routine_bytes']
    (output / 'results.json').write_text(json.dumps(summary, indent=2) + '\n')
    for case in cases:
        print(f"{case['source']}: {case['routine_bytes']} routine bytes, "
              f"{case['routine_t_states']:g} T-states; output and accounting PASS")
        for row in case['lines']:
            print(f"  {row['line']:3}: {row['t_states']:5g} T-states / "
                  f"{row['executions']:2} executions  {row['source']}")
    if len(cases) == 2:
        print(f"Saved {summary['saved_t_states']:g} T-states for {summary['extra_bytes']} extra bytes")
    print(f'Results: {output / "results.json"}')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, subprocess.TimeoutExpired, KeyError, StopIteration) as error:
        print(f'FAIL: {error}', file=sys.stderr)
        sys.exit(1)
