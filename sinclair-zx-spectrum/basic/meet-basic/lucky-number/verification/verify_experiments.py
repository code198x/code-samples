#!/usr/bin/env python3
"""Check the optional B1 experiments and numeric-input distinctions in B2."""
import argparse
import hashlib
import json
from pathlib import Path
from verify import ROOT, Spectrum

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--emulator', required=True)
p.add_argument('--output', type=Path, required=True)
args = p.parse_args()
args.output = args.output.resolve()
args.output.mkdir(parents=True, exist_ok=True)
m = Spectrum(args.emulator, args.output)
try:
    source = (ROOT / 'unit-05/steps/step-03.bas').read_text()
    for line in source.splitlines():
        m.statement(line)
    for guess, answer in [('11', 'Too high'), ('6.5', 'Too low'), ('3+4', 'Correct!')]:
        m.statement('RUN'); m.text(guess); m.enter()
        m.result('numeric-'+guess, ['Guess a whole number 1 to 10', answer], finished=True)
    m.statement('10 LET secret=2')
    for guess, answer in [('1', 'Too low'), ('2', 'Correct!'), ('3', 'Too high')]:
        m.statement('RUN'); m.text(guess); m.enter()
        m.result('secret-2-'+guess, ['Guess a whole number 1 to 10', answer], finished=True)
    m.statement('RUN'); m.text('cat'); m.enter()
    m.check('undefined-word-input', ['2 Variable not found'], capture=False)
    m.statement('RUN'); m.text('3+'); m.enter()
    # A malformed expression stays editable; remove + and complete it with 2.
    m.key('caps','0'); m.text('+2'); m.enter()
    m.result('corrected-input-expression', ['Guess a whole number 1 to 10', 'Too high'], finished=True)
    source2 = (ROOT / 'unit-06/steps/step-03.bas').read_text()
    for line in source2.splitlines():
        m.statement(line)
    m.statement('RUN')
    for guess in ['-1','0.9','10.1']:
        m.text(guess); m.enter()
        m.result('rejected-'+guess, ['Whole number from 1 to 10'])
    m.text('3+4');m.enter()
    m.result('expression-is-one-guess', ['Correct!', 'Guesses: 1'], finished=True, stopped=True)
    result={'status':'passed','server':m.server,'configuration':'Spectrum 48K; ROM keyboard entry through MCP',
            'limits':'No native GUI or original hardware verified.',
            'binary_sha256':hashlib.sha256(Path(args.emulator).read_bytes()).hexdigest(),
            'source_sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(ROOT.glob('unit-*/steps/*.bas'))},
            'checks':m.evidence}
    (args.output/'experiments.json').write_text(json.dumps(result,indent=2)+'\n')
finally:
    m.close()
