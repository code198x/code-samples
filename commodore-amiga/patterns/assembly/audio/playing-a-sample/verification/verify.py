"""Cold-boot the demo and probe; check Paula writes, pitch, interrupts and cost."""
import argparse
from array import array
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import wave

ROOT = Path(__file__).resolve().parents[1]
PAL_CLOCK = 3_546_895          # colour clocks per second (HRM, Audio Hardware)
LINE = 227                     # whole colour clocks per scan line
CHIP_END = 0x80000             # A500 chip RAM: the loaded program lives below


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


class Amiga:
    def __init__(self, emulator, kickstart, disk):
        self.process = subprocess.Popen(
            [str(emulator), '--mcp', '--model', 'a500', '--kickstart', str(kickstart),
             '--disk', str(disk)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        self.sequence = 0
        self.server = self.rpc('initialize', {
            'protocolVersion': '2025-06-18', 'capabilities': {},
            'clientInfo': {'name': 'amiga-playing-a-sample', 'version': '1'}})

    def rpc(self, method, params):
        self.sequence += 1
        self.process.stdin.write(json.dumps({'jsonrpc': '2.0', 'id': self.sequence,
                                             'method': method, 'params': params}) + '\n')
        self.process.stdin.flush()
        while True:
            line = self.process.stdout.readline()
            if not line:
                raise RuntimeError('Emu198x exited before replying')
            response = json.loads(line)
            if response.get('id') == self.sequence:
                assert 'error' not in response, response
                return response['result']

    def call(self, name, **arguments):
        result = self.rpc('tools/call', {'name': name, 'arguments': arguments})
        assert not result.get('isError'), result
        return json.loads(result['content'][0]['text'])

    def boot_and_record(self, wav, frames):
        self.call('start_audio_recording', path=str(wav))
        for start in range(0, frames, 400):
            self.call('run_frames', frames=min(400, frames - start))
        self.call('stop_audio_recording')

    def program_writes(self, low, high):
        log = self.call('chipset_write_log', offset_min=low, offset_max=high, limit=8192)
        assert log['filtered_total'] < 8192, 'write log truncated'
        # Kickstart runs from ROM; the loaded program runs from chip RAM.
        return [{'cck': e['cck'], 'offset': int(e['offset'][1:], 16),
                 'value': int(e['value'][1:], 16), 'size': e['size']}
                for e in log['entries'] if int(e['pc'][1:], 16) < CHIP_END]

    def close(self):
        self.process.stdin.close()
        self.process.wait(timeout=10)


def build(source, output, build198x, vasm=None):
    executable = output / source.stem
    subprocess.run(['asm198x', '--dialect', 'vasm', '--exe', str(source), '-o',
                    str(executable)], check=True, capture_output=True, cwd=source.parent)
    if vasm:
        reference = output / (source.stem + '.vasm')
        subprocess.run([vasm, '-Fhunkexe', '-kick1hunks', '-nosym', '-quiet', '-o',
                        str(reference), source.name], check=True, capture_output=True,
                       cwd=source.parent)
        assert reference.read_bytes() == executable.read_bytes(), source.name
    disk = output / (source.stem + '.adf')
    subprocess.run([build198x, 'adf', str(executable), '-o', str(disk),
                    '--volume', source.stem.capitalize(), '--name', source.stem],
                   check=True, capture_output=True)
    return executable, disk


def louder_channel(path):
    with wave.open(str(path)) as stream:
        assert stream.getsampwidth() == 2 and stream.getnchannels() == 2
        rate = stream.getframerate()
        samples = array('h', stream.readframes(stream.getnframes()))
    if sys.byteorder != 'little':
        samples.byteswap()
    channels = [samples[0::2], samples[1::2]]
    energy = [sum(abs(x) for x in c) for c in channels]
    # Which jack carries channel 0 is not asserted here (emu198x#1514).
    return rate, channels[energy.index(max(energy))]


def onset(samples, after=0):
    return next(i for i in range(after, len(samples)) if abs(samples[i]) > 1000)


def frequency(samples, rate, start, end):
    window = samples[start:end]
    middle = (max(window) + min(window)) / 2
    rising = [i for i in range(1, len(window)) if window[i - 1] < middle <= window[i]]
    return rate * (len(rising) - 1) / (rising[-1] - rising[0])


def check_demo(emulator, kickstart, disk, out):
    machine = Amiga(emulator, kickstart, disk)
    try:
        audio = out / 'demo.wav'
        machine.boot_and_record(audio, 2000)
        writes = machine.program_writes(0x096, 0x0a8)
        colours = machine.program_writes(0x180, 0x180)
    finally:
        machine.close()
    assert [w['value'] for w in colours] == [0x0035, 0x0050], 'demo did not finish'
    assert [(w['offset'], w['value']) for w in writes[:3]] == [
        (0x09a, 0x7fff), (0x09c, 0x7fff), (0x096, 0x7fff)], writes[:3]
    tones = []
    rest = writes[3:]
    expected = [(8, 424, 16), (8, 212, 16), (16, 212, 32)]
    for length, period, size in expected:
        # Only the frame-wait's vertical-blank acknowledgements fall between.
        # The 68000 writes MOVE.L to AUD0LC as AUD0LCH, then AUD0LCL.
        group = [w for w in rest if w['offset'] != 0x09c][:7]
        assert [w['offset'] for w in group] == [
            0x0a0, 0x0a2, 0x0a4, 0x0a6, 0x0a8, 0x096, 0x096], group
        high, low, written_length, written_period, volume, start, stop = group
        location = {'value': high['value'] << 16 | low['value']}
        assert location['value'] % 2 == 0 and location['value'] < CHIP_END
        assert written_length['value'] == length and written_period['value'] == period
        assert volume['value'] == 64
        assert start['value'] == 0x8201 and stop['value'] == 0x0001
        frames = (stop['cck'] - start['cck']) / (LINE * 312.5)
        assert 49.5 < frames < 50.5, frames
        tones.append({'location': location['value'], 'length_words': length, 'period': period,
                      'bytes_per_cycle': size, 'start_cck': start['cck'],
                      'stop_cck': stop['cck'], 'frames': round(frames, 3)})
        rest = rest[rest.index(stop) + 1:]
    assert tones[1]['location'] == tones[0]['location']
    assert tones[2]['location'] == tones[0]['location'] + 16, 'wave32 follows wave16'
    rate, samples = louder_channel(audio)
    first = onset(samples)
    for tone in tones:
        def at(cck):
            return first + round((cck - tones[0]['start_cck']) / PAL_CLOCK * rate)
        measured = frequency(samples, rate, at(tone['start_cck']) + rate // 5,
                             at(tone['stop_cck']) - rate // 5)
        predicted = PAL_CLOCK / (tone['period'] * tone['bytes_per_cycle'])
        assert abs(measured / predicted - 1) < 0.001, (tone, measured, predicted)
        tone.update(predicted_hz=round(predicted, 3), measured_hz=round(measured, 3))
        print('PASS tone', tone['period'], tone['bytes_per_cycle'], round(measured, 1), flush=True)
    return {'tones': tones, 'wav_sha256': sha(audio), 'audio_rate': rate}


def check_probe(emulator, kickstart, disk, out):
    machine = Amiga(emulator, kickstart, disk)
    try:
        audio = out / 'probe.wav'
        machine.boot_and_record(audio, 2400)
        writes = machine.program_writes(0x096, 0x09c)
        scan = machine.call('memory_scan', start=0, end=CHIP_END,
                            value=int.from_bytes(b'PAUL', 'big'))
        tables = []
        for hit in scan['hits']:
            address = int(hit['addr'][1:], 16)
            data = bytes(machine.call('memory_read', addr=address, len=30)['bytes'])
            if data[:13] == b'PAULAPROBE-V1':
                tables.append(data[16:30])
    finally:
        machine.close()
    # Disk buffers can hold an unexecuted copy; choose the completed table.
    done = [t for t in tables if t[12:14] == b'\x00\x01']
    assert len(done) == 1, tables
    quiet, busy, planes = (int.from_bytes(done[0][i:i + 4], 'big') for i in (0, 4, 8))
    assert quiet > 0 and quiet == busy, (quiet, busy)
    assert planes < quiet * 0.95, ('control did not slow the loop', quiet, planes)
    print('PASS cost: loop passes over 10 frames', quiet, 'without DMA,', busy,
          'with four channels at period 124,', planes, 'with six bitplanes', flush=True)

    starts = [i for i, w in enumerate(writes) if (w['offset'], w['value']) == (0x096, 0x8201)]
    assert len(starts) == 2, writes
    first = starts[0]
    acks = []
    for w in writes[first + 1:]:
        if (w['offset'], w['value']) == (0x096, 0x0001):
            break
        if (w['offset'], w['value']) == (0x09c, 0x0080):
            acks.append(w['cck'])
    assert len(acks) == 6, acks
    enable = writes[first]['cck']
    words, period = 8, 424
    pass_cck = words * 2 * period
    last_word = (words - 1) * 2 * period
    gaps = [b - a for a, b in zip(acks, acks[1:])]
    poll = 64                                # polling loop latency allowance
    assert acks[0] - enable < 2 * LINE, acks[0] - enable
    assert abs(gaps[0] - last_word) <= LINE + poll, gaps[0]
    assert all(abs(g - pass_cck) <= LINE + poll for g in gaps[1:]), gaps
    assert abs(acks[-1] - acks[1] - 4 * pass_cck) <= LINE + poll, acks
    print('PASS interrupts: first', acks[0] - enable, 'cck after DMACON; then', gaps,
          'against', last_word, 'and', pass_cck, flush=True)

    rate, samples = louder_channel(audio)
    tone = onset(samples)
    shot = onset(samples, tone + rate // 2)
    # One cycle is 6784 cck, about 92 output samples at 48 kHz.
    cycle = round(pass_cck / PAL_CLOCK * rate)
    peaks = []
    # Scan 40 cycles: a loop would keep peaking; a one shot stops after 8.
    for i in range(shot, shot + 40 * cycle):
        window = samples[max(0, i - cycle // 2):i + cycle // 2]
        if samples[i] == max(window) and max(window) - min(window) > 10000:
            if not peaks or i - peaks[-1] > cycle // 2:
                peaks.append(i)
    assert len(peaks) == 8, len(peaks)
    print('PASS one shot: 8 cycles, then none in the next 32', flush=True)
    return {'loop_passes_no_dma': quiet, 'loop_passes_four_channels_period_124': busy,
            'loop_passes_six_lowres_bitplanes_control': planes,
            'first_request_after_dmacon_cck': acks[0] - enable, 'request_gaps_cck': gaps,
            'predicted_last_word_cck': last_word, 'predicted_pass_cck': pass_cck,
            'one_shot_cycles': len(peaks), 'wav_sha256': sha(audio)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', type=Path, required=True)
    parser.add_argument('--kickstart', type=Path, required=True)
    parser.add_argument('--build198x', default='build198x')
    parser.add_argument('--vasm', help='vasmm68k_mot, for a byte comparison')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    demo, demo_disk = build(ROOT / 'demo.asm', out, args.build198x, args.vasm)
    probe, probe_disk = build(ROOT / 'verification/probe.asm', out, args.build198x, args.vasm)
    report = {
        'status': 'passed',
        'configuration': 'A500 OCS PAL, Kickstart 1.3, cold ADF boot',
        'emulator_sha256': sha(args.emulator), 'kickstart_sha256': sha(args.kickstart),
        'sources': {p.name: sha(p) for p in [ROOT / 'demo.asm', ROOT / 'paula-sample.inc',
                                             ROOT / 'verification/probe.asm']},
        'binaries': {p.name: sha(p) for p in [demo, demo_disk, probe, probe_disk]},
        'vasm_identical': bool(args.vasm),
        'demo': check_demo(args.emulator, args.kickstart, demo_disk, out),
        'probe': check_probe(args.emulator, args.kickstart, probe_disk, out),
        'limits': 'Emulator observations only. No listening, original-hardware or '
                  'stereo-jack claim; CPU cost compares one chip-RAM loop.',
    }
    (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
