"""Cold-boot both companions; observe their guest-written result tables."""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import subprocess


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', type=Path, required=True)
    parser.add_argument('--kickstart', type=Path, required=True)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--spaced', action='store_true')
    args = parser.parse_args()
    checks = {}
    for name in ['latest', 'priority']:
        disk = args.build / (name + '.adf')
        process = subprocess.Popen([str(args.emulator), '--mcp', '--model', 'a500',
                                    '--kickstart', str(args.kickstart), '--disk', str(disk)],
                                   stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        sequence = 0

        def rpc(method, params):
            nonlocal sequence
            sequence += 1
            process.stdin.write(json.dumps({'jsonrpc': '2.0', 'id': sequence,
                                           'method': method, 'params': params}) + '\n')
            process.stdin.flush()
            while True:
                response = json.loads(process.stdout.readline())
                if response.get('id') == sequence:
                    assert 'error' not in response, response
                    return response['result']

        def call(name, **arguments):
            result = rpc('tools/call', {'name': name, 'arguments': arguments})
            assert not result.get('isError'), result
            return json.loads(result['content'][0]['text'])

        try:
            server = rpc('initialize', {'protocolVersion': '2025-06-18', 'capabilities': {},
                                       'clientInfo': {'name': 'flock-ownership', 'version': '1'}})
            if args.spaced:
                call('start_audio_recording', path=str((args.build / (name + '-boot.wav')).resolve()))
            call('run_frames', frames=2000)
            if args.spaced:
                call('stop_audio_recording')
            memory = bytearray()
            for address in range(0, 512 * 1024, 256):
                memory.extend(call('memory_read', addr=address, len=256)['bytes'])
            marker = b'FLOCK-OWNERSHIP1'
            # Disk buffers may contain the unexecuted marker too. Select the
            # completed table; never assume the AmigaDOS relocation address.
            call('save_screenshot', path=str((args.build / (name + '.png')).resolve()))
            matches = []
            found = []
            for offset in range(len(memory)):
                if memory[offset:offset+16] == marker:
                    count = 55 if args.spaced else 15
                    words = struct.unpack(f'>{count+6}H', memory[offset+16:offset+16+2*(count+6)])
                    found.append((offset, words))
                    if words[count] == 1:
                        matches.append((offset, words))
            assert len(matches) == 1, found
            offset, words = matches[0]
            expected = ([18, 2, 2, 0, 1250, 5, 1, 2, 0, 2100, 18, 2, 2, 0, 1250]
                        if name == 'latest' else
                        [18, 2, 2, 0, 1250, 18, 2, 1, 1, 1250, 18, 2, 1, 1, 1250])
            if args.spaced:
                expected = [18,2,1,0,1250, 5,1,2,0,2100, 5,1,3,0,2100,
                            5,1,1,0,2100, 18,2,1,0,1250, 18,2,2,0,1250,
                            18,2,3,0,1250, 5,1,1,0,2100, 0,0,1,0,2100,
                            18,2,1,0,1250, 0,0,1,0,1250]
                if name == 'priority':
                    expected[5:15] = [12,2,1,1,1250, 6,2,1,2,1250]
                    expected[25:35] = [12,2,1,1,1250, 6,2,1,2,1250]
            assert list(words[:count]) == expected, (name, words)
            assert words[count+1] == 0, ('ownership did not end', words)
            assert words[count+4:] == ((151, 110) if args.spaced else (181, 30)), words
            call('save_screenshot', path=str((args.build / (name + '.png')).resolve()))
            checks[name] = {'source_sha256': sha(args.build / (name + '.asm')),
                            'executable_sha256': sha(args.build / name), 'adf_sha256': sha(disk),
                            'records': [list(words[i:i+5]) for i in range(0, count, 5)],
                            'owner_after_completion': words[count+1], 'server': server}
            print('PASS', name, flush=True)
        finally:
            process.stdin.close()
            process.wait(timeout=10)
    result = {'status': 'passed', 'configuration': 'A500 PAL, Kickstart 1.3, cold ADF boot',
              'record_fields': ['timer', 'priority', 'accepted', 'rejected', 'later_period'],
              'emulator_sha256': sha(args.emulator), 'kickstart_sha256': sha(args.kickstart),
              'checks': checks, 'limits': 'No original hardware, subjective listening or learner trial.'}
    (args.build / 'results.json').write_text(json.dumps(result, indent=2) + '\n')


if __name__ == '__main__':
    main()
