"""Execute random-consumer ordering fixtures on the native C64, observing RAM only."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--emulator', type=Path, required=True)
parser.add_argument('--build', type=Path, required=True)
args = parser.parse_args()
checks = {}
for name in ['before', 'after', 'before-repeat', 'after-repeat']:
    source_name = name.removesuffix('-repeat')
    program = args.build / (source_name + '.prg')
    # The native script runner imports --load after boot; the MCP launcher
    # does not apply that command-line program import.
    script = []
    for key in ['R', 'U', 'N', 'RETURN']:
        for pressed, frames in [(True, 4), (False, 3)]:
            script += [{'action':'input', 'events':[{'Key':{'name':key,'pressed':pressed}}]},
                       {'action':'run_frames','frames':frames}]
    script += [{'action':'run_frames','frames':120},
               {'action':'memory_read','addr':0x3800,'len':91}]
    script.append({'action':'save_screenshot','path':str((args.build/(name+'.png')).resolve())})
    script_path = args.build/(name+'.script.json')
    script_path.write_text(json.dumps(script,indent=2)+'\n')
    run = subprocess.run([str(args.emulator),'--model','pal','--load',str(program),
                          '--script',str(script_path)],capture_output=True,text=True,check=True)
    report = json.loads(run.stdout)
    (args.build/(name+'.report.json')).write_text(json.dumps(report,indent=2)+'\n')
    reads = [o['bytes'] for o in report['observations'] if o['kind']=='memory_read']
    values = reads[0]
    assert values[0] == 1, (name, values)
    assert values[1:3] == [12,60], values
    rows = [values[i:i+5] for i in range(3,63,5)]
    events = [values[i:i+2] for i in range(65,91,2)]
    assert values[63] == 26, values
    consumers = ([0,1] if source_name == 'before' else [1,0]) + [1]*11
    seed = 1
    expected_events = []
    spawn_bytes = []
    for consumer in consumers:
        seed = ((seed << 1) & 255) ^ (0x1d if seed & 128 else 0)
        expected_events.append([consumer,seed])
        if consumer:
            spawn_bytes.append(seed)
        else:
            assert values[64] == seed
    assert events == expected_events, (name,events)
    for row,seed in zip(rows,spawn_bytes):
        position = 24 + seed + (seed >> 3)
        high = position >> 8
        assert row == [seed,position & 255,high,position & 255,0xab | (high << 2)], (name,row)
        assert row[4] & 0xfb == 0xab, ('unrelated sprite bits',name,row)
    checks[name]={'source_sha256':sha(args.build/(source_name+'.asm')),
                  'prg_sha256':sha(program),'spawns':rows,'draws':events,'cosmetic_byte':values[64]}
    print('PASS',name,rows,flush=True)
for policy in ['before','after']:
    assert checks[policy]['spawns'] == checks[policy+'-repeat']['spawns']
    assert checks[policy]['draws'] == checks[policy+'-repeat']['draws']
assert checks['before']['spawns'][0][0] == 4
assert checks['after']['spawns'][0][0] == 2
assert checks['before']['spawns'][1:] == checks['after']['spawns'][1:]
assert [e[1] for e in checks['before']['draws']] == [e[1] for e in checks['after']['draws']]
first = 1
result={'first_divergent_spawn':first,'status':'passed','configuration':'Native C64 PAL, BASIC RUN, seed 1; one cosmetic draw moved across first spawn; identical RUN key schedule',
        'fields':['rng_byte','logical_x_low','logical_x_high','vic_x_low','d010'],
        'emulator_sha256':sha(args.emulator),'checks':checks,
        'limits':'Controlled consumer-order experiment; no gameplay replay, timing equivalence, separate generators or original-hardware verification.'}
(args.build/'results.json').write_text(json.dumps(result,indent=2)+'\n')
