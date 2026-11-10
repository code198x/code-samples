#!/usr/bin/env python3
"""Build the isolated APU experiment in a disposable directory; preserve samples.

The experiment depends on Emu198x's published APU crate at the version below,
fetched from crates.io and checked against its recorded package digest, so
the run needs no Emu198x checkout.
"""
import argparse
import hashlib
import json
import pathlib
import subprocess
import tempfile

CRATE = 'emu198x-ricoh-apu-2a03'
VERSION = '0.6.0'


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output', type=pathlib.Path, required=True)
    a = p.parse_args()
    root = pathlib.Path(__file__).resolve().parent
    with tempfile.TemporaryDirectory(prefix='dash-triangle-') as directory:
        build = pathlib.Path(directory)
        (build / 'Cargo.toml').write_text(
            '[package]\nname="dash-triangle-check"\nversion="0.1.0"\nedition="2024"\n'
            f'[dependencies]\n{CRATE}="={VERSION}"\n')
        (build / 'src').mkdir()
        (build / 'src/main.rs').write_bytes((root / 'triangle.rs').read_bytes())
        result = subprocess.run(['cargo', 'run', '--release', '--quiet',
                                 '--manifest-path', str(build / 'Cargo.toml')],
                                check=True, capture_output=True, text=True)
        lock = (build / 'Cargo.lock').read_text()
        checksum = next(
            block.split('checksum = "')[1].split('"')[0]
            for block in lock.split('[[package]]')
            if f'name = "{CRATE}"' in block and f'version = "{VERSION}"' in block)
        metadata = json.loads(subprocess.run(
            ['cargo', 'metadata', '--format-version', '1', '--manifest-path',
             str(build / 'Cargo.toml')], check=True, capture_output=True, text=True).stdout)
        package = next(p for p in metadata['packages'] if p['name'] == CRATE)
        source = pathlib.Path(package['manifest_path']).parent / 'src/lib.rs'
    a.output.mkdir(parents=True, exist_ok=True)
    (a.output / 'counters.csv').write_text(result.stdout)
    identity = {
        'dash.nes': hashlib.sha256((root.parent / 'dash.nes').read_bytes()).hexdigest(),
        'apu_crate': {'name': CRATE, 'version': VERSION,
                      'crates_io_checksum': checksum,
                      'lib_rs_sha256': hashlib.sha256(source.read_bytes()).hexdigest()},
        'scope': 'Counter fixture only; not full NES execution, audible verification or hardware evidence',
    }
    (a.output / 'identity.json').write_text(json.dumps(identity, indent=2) + '\n')
    print(result.stdout)
    print('PASS: duration limits, deferred linear reload, disabled writes, re-enable and halt control')


if __name__ == '__main__':
    main()
