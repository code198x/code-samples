"""Check generated/stale/repaired DATA through the unchanged unit-08 consumer."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'verification'))
import verify


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    source = HERE.parent / 'unit-08/steps/step-01.bas'
    authoring = args.output / 'room.txt'
    generated = args.output / 'room.bas'
    original = (HERE / 'room.txt').read_text()
    checks = []

    def convert(text, succeeds=True):
        authoring.write_text(text)
        result = subprocess.run([sys.executable, str(HERE / 'map_to_data.py'),
                                 str(authoring), '-o', str(generated)],
                                capture_output=True, text=True)
        assert (result.returncode == 0) == succeeds, result.stderr
        return result

    convert(original)
    baseline = generated.read_bytes()
    assert baseline.decode().splitlines() == [line for line in source.read_text().splitlines()
                                             if 8000 <= int(line.split()[0]) <= 8070]
    review = verify.Review(args.emulator, args.output)
    review.stage = {'unit': 8, 'name': 'validation'}
    try:
        review.patch(verify.lines(source))
        stored = review.m.program_lines()

        def consume(model):
            for line in generated.read_text().splitlines():
                review.m.statement(line)
            current = review.m.program_lines()
            assert {n: v for n, v in current.items() if not 8000 <= n <= 8070} == {
                n: v for n, v in stored.items() if not 8000 <= n <= 8070}
            review.start(model)
            review.move('j')
            review.key('r')
            review.model = model
            review.check()
            review.stop()

        consume(verify.ref.initial())
        checks.append('Known generated room: grid, player, pixels, move and restart')
        result = convert(original.replace('#------#', '#--X---#', 1), False)
        assert 'row 2, column 4' in result.stderr
        assert generated.read_bytes() == baseline
        consume(verify.ref.initial())
        checks.append('Rejected X leaves old output; unchanged consumer still plays old room')
        convert(original.replace('#-P----#', '#--P---#'))
        changed = verify.ref.initial()
        changed['pc'] = 4
        consume(changed)
        checks.append('Regenerated player position reaches runtime and survives restart')
        convert(original)
        consume(verify.ref.initial())
        checks.append('Original data restored; move and restart pass again')
        evidence = {
            'status': 'passed', 'configuration': '48K Spectrum PAL, ROM keyboard entry, read-only observations',
            'server': review.m.server, 'source_sha256': verify.sha(source),
            'converter_sha256': verify.sha(HERE / 'map_to_data.py'),
            'emulator_sha256': verify.sha(Path(args.emulator)), 'checks': checks,
            'limits': 'Emulator evidence only; no original hardware or learner trial.'}
        (args.output / 'results.json').write_text(json.dumps(evidence, indent=2) + '\n')
        print(json.dumps(evidence, indent=2))
    finally:
        review.m.close()


if __name__ == '__main__':
    main()
