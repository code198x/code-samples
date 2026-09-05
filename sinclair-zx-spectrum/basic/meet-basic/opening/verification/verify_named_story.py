#!/usr/bin/env python3
"""Load story by name after a greeting on a tape made from two ROM SAVE captures."""
import argparse
import hashlib
import json
from pathlib import Path
from verify import Spectrum
from verify_story import run_story

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--emulator', required=True)
parser.add_argument('--greeting', type=Path, required=True)
parser.add_argument('--story', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
args.output = args.output.resolve()
args.output.mkdir(parents=True, exist_ok=True)
# TAP is a sequence of length-prefixed blocks: retain both real SAVE recordings
# byte for byte, with the greeting first. No BASIC or ROM memory is injected.
tape = args.output/'combined.tap'
tape.write_bytes(args.greeting.read_bytes() + args.story.read_bytes())
machine = Spectrum(args.emulator, args.output)
try:
    machine.call('load_media', slot='tape-1', kind='tape', path=str(tape))
    machine.statement('LOAD "story"')
    machine.call('media_transport', slot='tape-1', transport='start')
    machine.frames(3000)
    machine.check('named-load-complete', ['0 OK'])
    run_story(machine, 'named-story', ('Sam','sleepy','dragon','moon cave'), True)
    result = {'status':'passed', 'configuration':'Spectrum 48K; MCP; named ROM LOAD from a combined TAP',
              'limits':'Two existing ROM SAVE captures concatenated for this test; native menus and original hardware not exercised.',
              'binary_sha256':hashlib.sha256(Path(args.emulator).read_bytes()).hexdigest(),
              'greeting_sha256':hashlib.sha256(args.greeting.read_bytes()).hexdigest(),
              'story_sha256':hashlib.sha256(args.story.read_bytes()).hexdigest(),
              'combined_sha256':hashlib.sha256(tape.read_bytes()).hexdigest(),
              'checks':machine.evidence}
    (args.output/'named-story-results.json').write_text(json.dumps(result, indent=2)+'\n')
finally:
    machine.close()
