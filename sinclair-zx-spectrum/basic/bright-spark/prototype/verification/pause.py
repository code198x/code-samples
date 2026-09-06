#!/usr/bin/env python3
"""Compare PAUSE 50 with and without a key pressed after it has started."""
import argparse
import json
from pathlib import Path
from verify import Spectrum

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--emulator', required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
a.output.mkdir(parents=True, exist_ok=True)
results = []
for interrupt in (False, True):
    m = Spectrum(a.emulator, a.output)
    try:
        m.statement('10 PAUSE 50')
        m.statement('20 PRINT "WAIT COMPLETE"')
        m.statement('30 STOP')
        m.key('r')
        m.call('press_key', key='enter', hold_frames=1)
        m.frames(10)
        assert not any('WAIT COMPLETE' in row for row in m.screen())
        if interrupt:
            m.call('press_key', key='x', hold_frames=2)
        else:
            m.frames(2)
        frames = 12
        while not any('WAIT COMPLETE' in row for row in m.screen()):
            m.frames(1)
            frames += 1
            assert frames < 70
        results.append({'interrupt': interrupt, 'frames_after_run_enter': frames})
    finally:
        m.close()
assert results[1]['frames_after_run_enter'] + 20 < results[0]['frames_after_run_enter'], results
(a.output / 'pause.json').write_text(json.dumps({
    'status': 'passed',
    'method': 'Fresh processes; PAUSE 50; both runs advance 12 frames after RUN entry, with x held during frames 11–12 in the interrupted case. Counts include BASIC execution and PRINT, not just the PAUSE statement.',
    'checks': results,
}, indent=2) + '\n')
print(json.dumps(results))
