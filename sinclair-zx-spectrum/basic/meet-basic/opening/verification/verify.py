#!/usr/bin/env python3
"""Check Meet BASIC opening checkpoints through the real 48K ROM editor.

Requires Python 3 and emu198x-spectrum --mcp, with a lawfully supplied 48K ROM
configured in Emu198x. No source injection, ROM patching or bundled firmware.
"""
import argparse
import hashlib
import json
from pathlib import Path
import queue
import subprocess
import threading

ROOT = Path(__file__).resolve().parents[1]


class Spectrum:
    def __init__(self, executable, output):
        self.output = output
        self.process = subprocess.Popen([executable, '--mcp'], stdin=subprocess.PIPE,
                                        stdout=subprocess.PIPE, text=True)
        self.responses = queue.Queue()
        self.reader = threading.Thread(target=self.read, daemon=True)
        self.reader.start()
        self.sequence = 0
        self.evidence = []
        self.server = self.rpc('initialize', {
            'protocolVersion': '2025-06-18', 'capabilities': {},
            'clientInfo': {'name': 'meet-basic-opening', 'version': '1'}})
        self.frames(150)

    def read(self):
        for line in self.process.stdout:
            self.responses.put(json.loads(line))
        self.responses.put(None)

    def rpc(self, method, params):
        self.sequence += 1
        self.process.stdin.write(json.dumps({'jsonrpc': '2.0', 'id': self.sequence,
                                            'method': method, 'params': params}) + '\n')
        self.process.stdin.flush()
        while True:
            result = self.responses.get(timeout=60)
            if result is None:
                raise RuntimeError('Emu198x exited before replying')
            if result.get('id') == self.sequence:
                if 'error' in result:
                    raise RuntimeError(result['error'])
                return result['result']

    def call(self, name, **arguments):
        result = self.rpc('tools/call', {'name': name, 'arguments': arguments})
        if result.get('isError'):
            raise RuntimeError(result)
        return json.loads(result['content'][0]['text'])

    def frames(self, count):
        self.call('run_frames', frames=count)

    def key(self, *keys):
        if len(keys) == 1:
            self.call('press_key', key=keys[0], hold_frames=3)
        else:
            self.call('press_keys', keys=list(keys), hold_frames=3)
        # Allow the ROM to notice release before another key/chord, especially
        # PRINT (P) followed by quote (SYMBOL SHIFT + P). Not a speed benchmark.
        self.frames(8)

    def text(self, text):
        symbols = {'"': 'p', '$': '4', '=': 'l', ';': 'o', ',': 'n'}
        for character in text:
            if character in symbols:
                self.key('symbol', symbols[character])
            elif character == ' ':
                self.key('space')
            elif character.isupper():
                self.key('caps', character.lower())
            elif character.islower() or character.isdigit():
                self.key(character)
            else:
                raise ValueError(f'Unmapped character: {character!r}')

    def enter(self):
        self.key('enter')
        self.frames(30)

    def statement(self, line):
        # Keywords are entered by their actual K-mode key, never spelled out.
        words = line.split(' ', 2)
        if words[0].isdigit():
            self.text(words.pop(0))
        command = words.pop(0)
        self.key({'PRINT': 'p', 'LET': 'l', 'RUN': 'r', 'LIST': 'k',
                  'SAVE': 's', 'LOAD': 'j', 'INPUT': 'i', 'CLS': 'v'}[command])
        self.text(' '.join(words))
        self.enter()

    def screen(self):
        return self.call('query', path='screen.text.lines')['result']['value']

    def check(self, name, expected, capture=True):
        lines = [line.rstrip() for line in self.screen()]
        for text in expected:
            assert any(text in line for line in lines), (name, text, lines)
        self.evidence.append({'check': name, 'expected': expected, 'screen': lines})
        print('PASS', name, flush=True)
        if capture:
            self.call('save_screenshot', path=str(self.output / f'{name}.png'))

    def checkpoint(self, unit, step, expected, previous):
        path = ROOT / f'unit-{unit:02}/steps/step-{step:02}.bas'
        source = path.read_text()
        for line in source.splitlines():
            if line not in previous.splitlines():
                self.statement(line)
        self.statement('RUN')
        lines = [line.rstrip() for line in self.screen()]
        output = [line for line in expected if not line.startswith('0 OK')]
        assert lines[:len(output)] == output, (path, lines)
        assert lines[-1].startswith('0 OK'), (path, lines[-1])
        self.check(f'unit-{unit:02}-step-{step:02}', expected)
        return source

    def close(self):
        self.process.stdin.close()
        try:
            self.process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            self.process.terminate()
            self.process.wait(timeout=5)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', default='emu198x-spectrum')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    machine = Spectrum(args.emulator, args.output)
    try:
        machine.statement('PRINT "Hello"')
        machine.check('immediate', ['Hello', '0 OK'])
        previous = ''
        for unit, step, expected in [
            (1, 1, ['Hello', '0 OK, 10:1']),
            (1, 2, ['Hello', 'from the Spectrum', '0 OK, 20:1']),
            (1, 3, ['Hello', 'to you', 'from the Spectrum']),
            (1, 4, ['Welcome', 'to you', 'from the Spectrum']),
            (2, 1, ['Hello, Sam', 'from the Spectrum']),
            (2, 2, ['Hello, Jo', 'from the Spectrum']),
        ]:
            previous = machine.checkpoint(unit, step, expected, previous)
        machine.statement('LIST')
        machine.check('list', ['10', 'LET', '15', 'PRINT', '20'])
        # Select the first stored line by LIST 10, then EDIT it and accept it.
        machine.statement('LIST 10')
        machine.key('caps', '1')
        machine.check('edit', ['10', 'LET'], capture=False)
        for _ in range(20):
            machine.key('caps', '8')  # EDIT begins near the line number; move to its end.
        machine.key('caps', '0')  # Delete the closing quote, then restore it.
        machine.key('symbol', 'p')
        machine.enter()
        machine.statement('RUN')
        machine.check('after-edit', ['Hello, Jo', '0 OK, 20:1'], capture=False)
        # An intentional runtime error, outside the saved learner program.
        machine.statement('PRINT m$')
        machine.check('unknown-variable', ['2 Variable not found'])
        machine.statement('SAVE "greeting"')
        machine.check('save-prompt', ['Start tape, then press any key'])
        machine.enter()
        machine.frames(900)
        machine.check('save-complete', ['0 OK'])
        machine.call('save_tape', path=str(args.output / 'greeting.tap'))
        first_checks = machine.evidence
        machine.close()
        # A new process rules out accidentally using the old program in RAM.
        machine = Spectrum(args.emulator, args.output)
        machine.call('load_media', slot='tape-1', kind='tape',
                     path=str(args.output / 'greeting.tap'))
        machine.call('autoload_tape', slot='tape-1', max_boot_frames=150)
        machine.frames(1200)
        machine.statement('LIST')
        machine.check('reloaded-list', ['10', 'LET', 'Jo', '15', '20'])
        listed = '\n'.join(machine.screen()).replace('\\', '').replace('>', ' ')
        for line in previous.splitlines():
            assert ' '.join(line.split()) in ' '.join(listed.split()), (line, listed)
        machine.statement('RUN')
        machine.check('reloaded-run', ['Hello, Jo', 'from the Spectrum', '0 OK, 20:1'])
        machine.checkpoint(2, 3, ['Hello, Alex', 'from the Spectrum'], previous)
        result = {'status': 'passed', 'server': machine.server,
                  'configuration': 'Spectrum 48K; ROM keyboard entry; MCP; fresh-process tape reload',
                  'limits': 'No native GUI, original hardware or other emulator verified.',
                  'tape_sha256': hashlib.sha256((args.output / 'greeting.tap').read_bytes()).hexdigest(),
                  'source_sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                                    for p in sorted(list(ROOT.glob('unit-01/steps/*.bas')) + list(ROOT.glob('unit-02/steps/*.bas')))},
                  'checks': first_checks + machine.evidence}
        (args.output / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
    finally:
        if machine.process.poll() is None:
            machine.close()


if __name__ == '__main__':
    main()
