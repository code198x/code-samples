"""Load independently ROM-entered teaching tapes and observe their behaviour."""
import argparse,hashlib,json,re,sys,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve()
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
for name in ['roll','tally','shares','live']:
 folder=out/name;m=Spectrum(a.emulator,folder);checks=[]
 def record(label):checks.append(label);print('PASS',name,label,flush=True)
 def stopped():
  for _ in range(3000):
   if any('9 STOP statement' in r for r in m.screen()):return state(m)
   m.frames(10)
  raise AssertionError(m.screen())
 def chart(s,bars=False):
  rows=m.screen();assert sum(s['t'])==s['n'];assert all(v>=0 and int(v)==v for v in s['t'])
  for i,count in enumerate(s['t']):
   row=5+2*i;assert float(rows[row][7:14].strip())==count
   if name in ('shares','live'):assert float(rows[row][15:23].strip())==int(1000*count/s['n']+.5)/10
   if bars:
    width=int(20*count/s['n']+.5);assert rows[row+1][5]=='[' and rows[row+1][26]==']'
    assert rows[row+1][6:26]=='#'*width+' '*(20-width)
 try:
  m.call('load_media',slot='tape-1',kind='tape',path=str(folder/'dice-roller.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start')
  if name=='live':
   seen=[]
   for _ in range(6000):
    if line(m)==1170:
     s=state(m)
     if s['n']>=2 and (not seen or s['n']>seen[-1]):
      chart(s,True);seen.append(s['n'])
      if len(seen)==2:break
    m.frames(1)
   assert len(seen)==2,seen;record('live-counts-shares-and-bars-before-completion')
   m.call('input',events=[{'Key':{'name':'q','pressed':True}}]);s=stopped();assert 0<s['done']<12 and s['n']==s['done'];chart(s,True);record('early-stop-keeps-exact-partial-sample')
   m.call('input',events=[{'Key':{'name':'q','pressed':False}}]);m.frames(10);m.statement('RUN')
  s=stopped();assert m.program_lines()=={int(k):v for k,v in json.loads((folder/'stored.json').read_text()).items()};record('fresh-tape-autostart-and-token-identity')
  if name=='roll':
   rolls=[]
   for row in m.screen():
    match=re.fullmatch(r'\s*(\d+):\s*(\d+)\s*',row)
    if match:rolls.append(tuple(map(int,match.groups())))
   assert [i for i,d in rolls]==list(range(1,13)),rolls
   assert all(1<=d<=6 for i,d in rolls);record('twelve-numbered-rolls-in-range')
  else:
   assert s['n']==12;chart(s,name=='live');record('twelve-rolls-and-exact-accounting')
   if name=='shares':record('all-six-rounded-percentages')
   if name=='live':assert s['done']==12;record('complete-live-batch-and-bounded-bars')
  m.statement('RUN');s=stopped()
  if name!='roll':assert s['n']==12 and sum(s['t'])==12
  record('run-starts-a-fresh-sample')
  (folder/'results.json').write_text(json.dumps(dict(source_sha256=sha(ROOT/name/'dice-roller.bas'),binary_sha256=sha(Path(a.emulator)),checks=checks,server=m.server,direct_memory_writes=False,configuration='Stock 48K PAL; fresh tape; ordinary keys and RUN; no state injection'),indent=2)+'\n')
 finally:m.close()
# The complete endpoint receives the original accepted prototype suite, using
# this independently entered tape. Its source identity is audited separately.
subprocess.run([sys.executable,str(ROOT.parent/'prototype/verification/check.py'),'--emulator',a.emulator,'--output',str(out/'finished')],check=True)
