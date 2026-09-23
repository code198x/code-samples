"""Execute controlled restart fixtures on the native C64, observing RAM only."""
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
for name in ['baseline', 'faulty', 'repaired']:
    program = args.build / (name + '.prg')
    # The native script runner imports --load after boot; the MCP launcher
    # does not apply that command-line program import.
    script = []
    for key in ['R', 'U', 'N', 'RETURN']:
        for pressed, frames in [(True, 4), (False, 3)]:
            script += [{'action':'input', 'events':[{'Key':{'name':key,'pressed':pressed}}]},
                       {'action':'run_frames','frames':frames}]
    script += [{'action':'run_frames','frames':120},
               {'action':'memory_read','addr':0x3800,'len':30}]
    for address in [0x43f,0x467,0x48f]:
        script.append({'action':'memory_read','addr':address,'len':1})
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
    rows = [values[i:i+9] for i in [3,12,21]]
    counts = [3,6,6] if name == 'faulty' else [3,3,3]
    for row,count in zip(rows,counts):
        assert row == [count,0,0,3,1,0,1,0,0x1d], (name,row)
    assert reads[1:] == [[48+c] for c in counts], reads
    checks[name]={'source_sha256':sha(args.build/(name+'.asm')),
                  'prg_sha256':sha(program),'entries':rows}
    print('PASS',name,rows,flush=True)
assert (args.build/'baseline.prg').read_bytes()==(args.build/'repaired.prg').read_bytes()
result={'status':'passed','configuration':'Native C64 PAL, BASIC RUN, controlled guest transition calls',
        'fields':['enemy_count','score','score_hi','lives','wave','kills','fall_speed','bullet_active','sprite_enable'],
        'emulator_sha256':sha(args.emulator),'checks':checks,
        'limits':'Controlled routine exercise, not three complete playthroughs, SID handover, or original-hardware verification.'}
(args.build/'results.json').write_text(json.dumps(result,indent=2)+'\n')
