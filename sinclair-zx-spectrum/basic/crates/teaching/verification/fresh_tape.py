"""Package the final ROM save and exercise default LOAD from a fresh machine."""
import argparse,json,hashlib
from pathlib import Path
from verify import Review,ROOT,ref,lines,sha
from tape import keep_program
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output=a.output.resolve();tape=a.output/'crates.tap'
keep_program(tape,'crates')
r=Review(a.emulator,a.output)
try:
    r.stage=json.loads((ROOT/'roster.json').read_text())[-1];r.program=lines(ROOT/r.stage['source']);meta=json.loads((a.output/'cache/three-rooms.json').read_text());assert sha(ROOT/r.stage['source'])==meta['source_sha256']
    r.m.call('load_media',slot='tape-1',kind='tape',path=str(tape));r.m.statement('LOAD ""');r.m.call('media_transport',slot='tape-1',transport='start');r.wait('S starts. Q quits.')
    assert r.m.program_lines()=={int(n):v for n,v in meta['stored'].items()};r.capture('packaged-instructions');r.key('s');r.model=ref.initial();r.check();r.capture('packaged-room')
    for room in [1,2,3]:
        if room>1:r.key('n',180);r.model=ref.initial(room);r.check()
        for k in ref.solve(ref.initial(room)):r.move(k)
    r.capture('packaged-finish');r.key('n',180);r.model=ref.initial();r.check();r.quit()
    evidence={'status':'passed','source_sha256':r.stage['sha256'],'tape_sha256':sha(tape),'checks':['single-program-ROM-recording-preserves-header-and-payload','default-LOAD-autostarts-and-rebuilds-graphics','stored-program-equals-final-checkpoint','all-three-rooms-new-game-and-exit'],'limits':'Headless ROM keyboard events; native GOALS cue review is separate.'}
    (a.output/'fresh-tape.json').write_text(json.dumps(evidence,indent=2)+'\n')
    if (a.output/'results.json').exists():result=json.loads((a.output/'results.json').read_text())
    else:
        checkpoints=json.loads((a.output/'progress.json').read_text());roster=json.loads((ROOT/'roster.json').read_text())
        assert len(checkpoints)==len(roster)
        for item,stage in zip(checkpoints,roster):assert item=={'name':stage['name'],'source':stage['source'],'sha256':stage['sha256'],'status':'passed'}
        rom=[]
        for addr in range(0,16384,128):rom+=r.m.call('memory_read',addr=addr,len=128)['bytes']
        result={'status':'passed','configuration':'48K ZX Spectrum PAL; ROM entry and tape save/load; read-only observations','server':r.m.server,'binary_sha256':sha(Path(a.emulator)),'rom_sha256':hashlib.sha256(bytes(rom)).hexdigest(),'prototype_sha256':sha(ROOT.parent/'prototype/crates.bas'),'checkpoints':checkpoints,'checks':[],'trace':r.trace,'trace_scope':'Packaged final fresh-load run; checkpoint and fixture inputs are defined in verify.py, boundaries.py and graphics.py.','limits':'No original hardware or learner-comprehension claim. All checkpoints completed before packaging; this fresh-load run completes the tape check. GOALS cue awaits native review.'}
    result['tape_sha256']=sha(tape);result['checks'].append('packaged-default-LOAD-three-rooms-new-game-exit');(a.output/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print('PASS packaged default LOAD and all three rooms',flush=True)
finally:r.m.close()
