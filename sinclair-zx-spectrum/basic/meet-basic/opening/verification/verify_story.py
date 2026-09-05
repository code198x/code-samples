#!/usr/bin/env python3
"""Check A3-to-A4 edits, story layout, changed answers and a fresh tape reload."""
import argparse
import hashlib
import json
from pathlib import Path
from verify import ROOT, Spectrum


def run_story(machine, name, answers, final):
    machine.statement('RUN')
    for prompt, answer in zip(['Your name', 'Describing word', 'Animal', 'Place like moon cave'], answers):
        machine.check(f'{name}-prompt-{prompt.replace(" ", "-")}', [prompt], capture=False)
        machine.text(answer)
        machine.enter()
    n, a, b, p = answers
    output = (['AN UNEXPECTED PICNIC', '', f'In the {p}', f'{n} met the {a} {b}', '',
               f'The {b}', 'asked for a biscuit', '', 'THE END'] if final else
              [f'Hello, {n}', 'from the Spectrum', f'In the {p}', f'{n} met the {a} {b}',
               f'The {b} asked for a biscuit'])
    expected = []
    for line in output:
        expected.extend([line[i:i+32] for i in range(0, len(line), 32)] or [''])
    screen = machine.screen()
    assert [row.rstrip() for row in screen[:len(expected)]] == [row.rstrip() for row in expected], (name, screen, expected)
    assert all(not row.strip() for row in screen[len(expected):22]), (name, screen)
    machine.check(name, ['0 OK'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    paths = [ROOT/'unit-03/steps/step-02.bas', ROOT/'unit-04/steps/step-01.bas', ROOT/'unit-04/steps/step-02.bas']
    machine = Spectrum(args.emulator, args.output)
    try:
        previous = {}
        for index, path in enumerate(paths):
            lines = {line.split()[0]: line for line in path.read_text().splitlines()}
            for number in previous.keys() - lines.keys():
                machine.text(number)
                machine.enter()
            for number, line in lines.items():
                if previous.get(number) != line:
                    machine.statement(line)
            previous = lines
            if index:
                run_story(machine, f'step-{index:02}-normal', ('Sam','sleepy','dragon','moon cave'), index == 2)
        for name, answers in [
            ('changed', ('Jo','enormous','owl','old tower')),
            ('empty', ('','','','')),
            ('long', ('Alexandertheexplorer','extraordinarily','hippopotamus','forgotten underground garden')),
        ]:
            run_story(machine, name, answers, True)
        machine.statement('SAVE "story"')
        machine.check('save-prompt', ['Start tape, then press any key'], capture=False)
        machine.enter()
        machine.frames(1800)
        machine.check('saved', ['0 OK'], capture=False)
        tape = args.output/'story.tap'
        machine.call('save_tape', path=str(tape))
        evidence = machine.evidence
        machine.close()
        machine = Spectrum(args.emulator, args.output)
        machine.call('load_media', slot='tape-1', kind='tape', path=str(tape))
        machine.call('autoload_tape', slot='tape-1', max_boot_frames=150)
        machine.frames(1800)
        run_story(machine, 'reloaded', ('Ada','tiny','cat','secret garden'), True)
        result = {'status':'passed', 'server':machine.server,
                  'configuration':'Spectrum 48K; ROM keyboard edits; MCP; fresh-process tape reload',
                  'limits':'No native UI, original hardware or other emulator checked in this run. Long and empty answers are accepted, not validated.',
                  'binary_sha256':hashlib.sha256(Path(args.emulator).read_bytes()).hexdigest(),
                  'source_sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
                  'tape_sha256':hashlib.sha256(tape.read_bytes()).hexdigest(),
                  'checks':evidence + machine.evidence}
        (args.output/'story-results.json').write_text(json.dumps(result, indent=2)+'\n')
    finally:
        if machine.process.poll() is None:
            machine.close()


if __name__ == '__main__':
    main()
