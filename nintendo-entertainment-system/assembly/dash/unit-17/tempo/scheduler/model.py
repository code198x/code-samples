#!/usr/bin/env python3
"""Exact-rate scheduler comparison; independently labelled host audio model."""
import argparse
import csv
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('baseline', HERE.parent/'compare.py')
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',required=True,type=Path)
    args=parser.parse_args()
    args.output.mkdir(parents=True,exist_ok=True)
    source=HERE.parents[1]/'dash.asm'
    assert base.hashlib.sha256(source.read_bytes()).hexdigest()==base.BASELINE
    rows=base.phrase(source.read_text())
    _,events,total=base.ticks(rows,50)
    result={'target_updates_per_second':50,'source_sha256':base.BASELINE,'rates':{}}
    for rate,elapsed in [(50,6),(60,5)]:
        phase=0
        service_frames=[0]
        frame=0
        while len(service_frames)<=total:
            frame+=1
            phase+=elapsed
            if phase>=6:
                phase-=6
                service_frames.append(frame)
            assert 0<=phase<6
        deadlines=[event['update'] for event in events]+[total]
        mapped=[]
        trace=[]
        for i,event in enumerate(events):
            requested=event['update']/50
            serviced=service_frames[event['update']]/rate
            # Independent rational ceiling oracle avoids float rounding at integers.
            assert service_frames[event['update']] == (event['update']*rate+49)//50
            assert 0<=serviced-requested<1/rate+1e-12
            duration=service_frames[deadlines[i+1]]-service_frames[event['update']]
            mapped.append({**event,'update':service_frames[event['update']], 'duration_updates':duration})
            trace.append({'row':i,'requested_seconds':requested,'serviced_seconds':serviced,
                          'lateness_seconds':serviced-requested,'period':event['period'],
                          'duration_seconds':duration/rate})
        end=service_frames[total]
        audio=base.render(mapped,rate,end,args.output/f'scheduled-{rate}.wav')
        with (args.output/f'events-{rate}.csv').open('w',newline='') as f:
            writer=csv.DictWriter(f,fieldnames=list(trace[0]));writer.writeheader();writer.writerows(trace)
        result['rates'][rate]={'requested_phrase_seconds':total/50,'serviced_phrase_seconds':end/rate,
                              'max_event_lateness_seconds':max(t['lateness_seconds'] for t in trace),'audio':audio}
    (args.output/'model-results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))

if __name__=='__main__':main()
