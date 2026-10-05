"""Run the maintained square-wave code in Emu198x and check what the page claims.

Each case is a complete NROM image. The CPU reads $4015 in its hold loop, so
the length-counter state comes from the machine itself; pitch, silence and
duration come from the captured PCM. Times are measured in emulated time: the
capture's sample count is divided by the frames that produced it, so a
resampler that emits fewer samples than its WAV header claims cannot move the
measured pitch. The header and effective rates are both recorded.
"""
import argparse
from array import array
import hashlib
import json
from pathlib import Path
import queue
import subprocess
import sys
import threading
import wave

ROOT = Path(__file__).resolve().parents[1]
CPU_HZ = 1789773            # NTSC CPU clock
FRAME_CYCLES = 29780.5      # NTSC CPU cycles per frame (341 * 262 - 0.5 dots / 3)
FRAMES = 120


def sha(file):
    return hashlib.sha256(Path(file).read_bytes()).hexdigest()


def expected_hz(timer):
    return CPU_HZ / (16 * (timer + 1))


class Nes:
    """A minimal MCP client for emu198x-nes --mcp."""

    def __init__(self, executable):
        self.process = subprocess.Popen([executable, '--mcp'], stdin=subprocess.PIPE,
                                        stdout=subprocess.PIPE, text=True)
        self.responses = queue.Queue()
        threading.Thread(target=self.read, daemon=True).start()
        self.sequence = 0
        self.rpc('initialize', {'protocolVersion': '2025-06-18', 'capabilities': {},
                                'clientInfo': {'name': 'square-wave', 'version': '1'}})

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
        text = result['content'][0]['text']
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            return text

    def close(self):
        self.process.stdin.close()
        self.process.wait(timeout=10)


# Each case body runs after the shared reset code and before the hold loop
# that copies $4015 into `status`. pulse1_tone is the maintained include.
TONE = '    lda #${lo:02X}\n    ldx #${hi:02X}\n    jsr pulse1_tone\n'
CASES = {
    # name: (body, timer, expect_tone, expect_status_bit0)
    'octave': ('    lda #$01\n    sta APU_STATUS\n' + TONE.format(lo=0x7E, hi=0), 0x07E, True, 1),
    'low-negate-sweep': ('    lda #$01\n    sta APU_STATUS\n' + TONE.format(lo=0x00, hi=4),
                         0x400, True, 1),
    'low-sweep-00-mutes': ('    lda #$01\n    sta APU_STATUS\n' + TONE.format(lo=0x00, hi=4) +
                           '    lda #$00\n    sta PULSE1_SWEEP  ; sweep disabled, negate clear\n',
                           0x400, False, 1),
    'timer-below-8-mutes': ('    lda #$01\n    sta APU_STATUS\n' + TONE.format(lo=0x07, hi=0),
                            0x007, False, 1),
    'load-before-enable': (TONE.format(lo=0xFD, hi=0) + '    lda #$01\n    sta APU_STATUS\n',
                           0x0FD, False, 0),
    'length-expires': ('    lda #$01\n    sta APU_STATUS\n' + TONE.format(lo=0xFD, hi=0) +
                       '    lda #%10011111    ; halt clear: the length counter (10) runs\n'
                       '    sta PULSE1_CTRL\n', 0x0FD, True, 0),
}


def caller(body):
    demo = (ROOT / 'demo.asm').read_text()
    start = demo.index('    lda #%00000001')
    end = demo.index('hold:')
    text = demo[:start] + body + '\n' + demo[end:]
    return text.replace('.include "square-wave.inc"', f'.include "{ROOT / "square-wave.inc"}"')


def assemble(source, rom):
    result = subprocess.run(['asm198x', '--dialect', 'ca65', str(source), '-o', str(rom)],
                            capture_output=True, text=True, cwd=ROOT)
    assert result.returncode == 0, result.stderr + result.stdout


def analyse(path, frames):
    with wave.open(str(path)) as stream:
        assert stream.getsampwidth() == 2 and stream.getnchannels() == 1
        header_rate = stream.getframerate()
        samples = array('h', stream.readframes(stream.getnframes()))
    if sys.byteorder != 'little':
        samples.byteswap()
    seconds = frames * FRAME_CYCLES / CPU_HZ
    rate = len(samples) / seconds          # samples per emulated second
    rising = [i for i in range(1, len(samples)) if samples[i - 1] < 0 <= samples[i]]
    tail = samples[len(samples) // 2:]
    tail_peak = max(abs(v) for v in tail)
    return {'header_rate': header_rate, 'effective_rate': rate, 'samples': samples,
            'rising': rising, 'tail_peak': tail_peak, 'peak': max(abs(v) for v in samples)}


def frequency(info, start, stop):
    edges = [i for i in info['rising'] if start <= i < stop]
    assert len(edges) >= 8, 'No measurable tone in the window'
    return info['effective_rate'] * (len(edges) - 1) / (edges[-1] - edges[0]), edges


def run_case(emulator, rom, symbols_status, out_wav):
    machine = Nes(emulator)
    try:
        machine.call('load_media', slot='cartridge-1', kind='cartridge', path=str(rom))
        machine.call('reset')
        machine.call('clear_audio_capture')
        machine.call('run_frames', frames=FRAMES)
        machine.call('save_audio_capture', path=str(out_wav))
        status = machine.call('memory_read', addr=symbols_status, len=1)['bytes'][0]
    finally:
        machine.close()
    return status


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', required=True, help='path to emu198x-nes')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    status_addr = 0x0000   # first ZEROPAGE byte in demo.asm
    report = {
        'target': 'NTSC NES, NROM, rendering off; pulse 1 only',
        'method': 'Complete ROMs in emu198x-nes --mcp; CPU reads of $4015; PCM in emulated time',
        'emulator_sha256': sha(args.emulator),
        'sources': {'demo.asm': sha(ROOT / 'demo.asm'),
                    'square-wave.inc': sha(ROOT / 'square-wave.inc')},
        'frames_per_case': FRAMES,
        'cases': [],
        'limits': 'Emulator observations; no original-hardware or listening claim.',
    }
    builds = {'held-a4': (ROOT / 'demo.asm', 0x0FD, True, 1)}
    for name, (body, timer, tone, bit0) in CASES.items():
        directory = out / name
        directory.mkdir(exist_ok=True)
        source = directory / 'caller.asm'
        source.write_text(caller(body))
        builds[name] = (source, timer, tone, bit0)
    for name, (source, timer, tone, bit0) in builds.items():
        directory = out / name
        directory.mkdir(exist_ok=True)
        rom = directory / 'program.nes'
        assemble(source, rom)
        wav = directory / 'capture.wav'
        status = run_case(args.emulator, rom, status_addr, wav)
        info = analyse(wav, FRAMES)
        entry = {'name': name, 'timer': timer, 'status_4015': status,
                 'source_sha256': sha(source), 'rom_sha256': sha(rom),
                 'wav_sha256': sha(wav), 'header_rate': info['header_rate'],
                 'effective_rate': round(info['effective_rate'], 1)}
        assert status & 1 == bit0, (name, 'status', status)
        entry['checks'] = [f'$4015 bit 0 reads {bit0} after {FRAMES} frames']
        if not tone:
            # Nothing but the filtered settling of the mixer's DC level.
            assert len(info['rising']) <= 2, (name, 'unexpected crossings', len(info['rising']))
            assert info['tail_peak'] < 50, (name, 'tail', info['tail_peak'])
            entry['checks'].append('Silent: no waveform crossings')
        elif name == 'length-expires':
            edges = info['rising']
            gap = edges[1] - edges[0]
            run = 1      # the tone's contiguous edges; the filter's settling adds a stray one
            while run < len(edges) and edges[run] - edges[run - 1] < 1.5 * gap:
                run += 1
            measured, edges = frequency(info, edges[0], edges[run - 1] + 1)
            period = info['effective_rate'] / measured
            seconds = (edges[-1] - edges[0] + period) / info['effective_rate']
            # Ten half-frame clocks at 14915 CPU cycles; the first comes up
            # to one half-frame after the load, so 75.0-83.4 ms.
            assert 0.074 < seconds < 0.085, (name, seconds)
            assert info['tail_peak'] < 50, (name, 'tail', info['tail_peak'])
            assert len(info['rising']) - run <= 1, (name, 'tone resumed')
            # Skip the first ten cycles, where the DC-blocking filter is settling.
            first = info['samples'][edges[10]:edges[13]]
            last = info['samples'][edges[-4]:edges[-1]]
            swing = lambda part: max(part) - min(part)
            assert abs(swing(last) / swing(first) - 1) < 0.1, (name, 'level changed')
            assert abs(measured / expected_hz(timer) - 1) < 0.005, (name, measured)
            entry['frequency_hz'] = round(measured, 2)
            entry['tone_seconds'] = round(seconds, 4)
            entry['checks'] += ['Tone stops after ten half-frame clocks (75-84 ms)',
                                'Level is unchanged until the cut: no fade']
        else:
            half = len(info['samples']) // 2
            measured, edges = frequency(info, half // 2, len(info['samples']))
            assert abs(measured / expected_hz(timer) - 1) < 0.005, (name, measured,
                                                                    expected_hz(timer))
            assert info['tail_peak'] > 1000, (name, 'quiet tail')
            first = info['samples'][edges[0]:edges[8]]
            last = info['samples'][edges[-9]:edges[-1]]
            swing = lambda part: max(part) - min(part)
            assert abs(swing(last) / swing(first) - 1) < 0.1, (name, 'level changed')
            entry['frequency_hz'] = round(measured, 2)
            entry['expected_hz'] = round(expected_hz(timer), 2)
            entry['checks'].append('Pitch within 0.5% of 1789773/(16*(t+1)), held to the end')
        report['cases'].append(entry)
        print('PASS', name, entry.get('frequency_hz', 'silent'), 'status', status, flush=True)
    results = {c['name']: c for c in report['cases']}
    ratio = results['octave']['frequency_hz'] / results['held-a4']['frequency_hz']
    assert abs(ratio - 2) < 0.01, ratio
    print('PASS octave ratio', round(ratio, 4))
    rates = {(c['header_rate'], c['effective_rate']) for c in report['cases']}
    report['audio_timebase'] = [{'wav_header_hz': h, 'samples_per_emulated_second': e}
                                for h, e in sorted(rates)]
    report['status'] = 'passed'
    (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
