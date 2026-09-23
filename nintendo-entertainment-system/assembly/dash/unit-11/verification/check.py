#!/usr/bin/env python3
"""Build the isolated APU experiment in a disposable directory; preserve samples."""
import argparse, hashlib, json, pathlib, subprocess, tempfile
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--emulator-repo',type=pathlib.Path,required=True)
p.add_argument('--output',type=pathlib.Path,required=True)
a=p.parse_args(); root=pathlib.Path(__file__).resolve().parent
crate=a.emulator_repo.resolve()/'crates/emu198x-ricoh-apu-2a03'
with tempfile.TemporaryDirectory(prefix='dash-triangle-') as directory:
    build=pathlib.Path(directory)
    (build/'Cargo.toml').write_text('[package]\nname="dash-triangle-check"\nversion="0.1.0"\nedition="2024"\n[dependencies]\nemu198x-ricoh-apu-2a03={path='+json.dumps(str(crate))+'}\n')
    (build/'src').mkdir();(build/'src/main.rs').write_bytes((root/'triangle.rs').read_bytes())
    result=subprocess.run(['cargo','run','--release','--offline','--manifest-path',str(build/'Cargo.toml')],check=True,capture_output=True,text=True)
    a.output.mkdir(parents=True,exist_ok=True)
    (a.output/'counters.csv').write_text(result.stdout)
    identity={name:hashlib.sha256((root.parent/name).read_bytes()).hexdigest() for name in ['dash.asm','dash.nes']}
    identity['apu_source_sha256']=hashlib.sha256((crate/'src/lib.rs').read_bytes()).hexdigest()
    identity['scope']='Counter fixture only; not full NES execution, audible verification or hardware evidence'
    (a.output/'identity.json').write_text(json.dumps(identity,indent=2)+'\n')
    print(result.stdout)
    print('PASS: duration limits, deferred linear reload, disabled writes, re-enable and halt control')
