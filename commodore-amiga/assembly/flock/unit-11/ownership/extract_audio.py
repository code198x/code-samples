"""Keep a short, unnormalised excerpt of each native companion recording."""
import argparse
from array import array
import hashlib
import json
from pathlib import Path
import sys
import wave

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('build', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
records = {}
for name in ['latest', 'priority']:
    source = args.build / (name + '-boot.wav')
    with wave.open(str(source), 'rb') as stream:
        params = stream.getparams()
        assert params.sampwidth == 2
        pcm = stream.readframes(params.nframes)
    samples = array('h', pcm)
    if sys.byteorder != 'little':
        samples.byteswap()
    # Fixed threshold locates the first cue, rather than trimming quiet tails
    # individually or changing the relative volume/duration of later cues.
    first = next(i // params.nchannels for i, sample in enumerate(samples) if abs(sample) > 300)
    start = max(0, first - params.framerate // 5)
    end = start + params.framerate * 4
    assert end <= params.nframes
    output = args.output / ('ownership-' + name + '.wav')
    with wave.open(str(output), 'wb') as stream:
        stream.setparams(params)
        stride = params.nchannels * params.sampwidth
        stream.writeframes(pcm[start*stride:end*stride])
    records[name] = {'input_sha256': hashlib.sha256(pcm).hexdigest(),
                     'output_sha256': hashlib.sha256(output.read_bytes()).hexdigest(),
                     'first_cue_sample': first, 'start_sample': start, 'end_sample': end,
                     'sample_rate': params.framerate, 'channels': params.nchannels}
(args.build / 'audio-excerpts.json').write_text(json.dumps(records, indent=2) + '\n')
