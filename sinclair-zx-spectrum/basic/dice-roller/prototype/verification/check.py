"""Tape-driven Dice Roller checks; read-only observation, labelled ROM fixtures."""
import argparse,hashlib,json,sys
from pathlib import Path
from entry import Spectrum,ROOT
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();m=Spectrum(a.emulator,out);checks=[];samples=[];fixtures=[]
def record(name):checks.append(name);print('PASS',name,flush=True)
def read():
 for _ in range(9):
  try:return state(m)
  except (AssertionError,IndexError):m.frames(1)
 raise AssertionError('incomplete variable table')
def wait(text):
 for _ in range(9000):
  if line(m) in (8010,8020) and any(text in s for s in m.screen()):return read()
  m.frames(10)
 raise AssertionError((text,line(m),m.screen()))
def key(k):m.key('space' if k==' ' else k)
def capture(name):
 m.frames(50)  # Let the completed display settle before capture.
 m.call('save_screenshot',path=str(out/(name+'.png')))
def stop():
 for _ in range(500):
  if any('9 STOP statement' in s for s in m.screen()):return
  m.frames(5)
 raise AssertionError(m.screen())
def chart(s):
 rows=m.screen();assert 1<=s['n']<=9600 and sum(s['t'])==s['n'] and all(x>=0 and x==int(x) for x in s['t'])
 assert sum(s['p'])==s['pn']
 for i,count in enumerate(s['t']):
  row=5+2*i;pc=int(1000*count/s['n']+.5)/10;width=int(20*count/s['n']+.5)
  assert 0<=width<=20
  assert float(rows[row][7:14].strip())==count,(row,rows[row],count)
  assert float(rows[row][15:23].strip())==pc,(row,rows[row],pc)
  if s['pn']>0:assert float(rows[row][24:30].strip())==int(1000*s['p'][i]/s['pn']+.5)/10
  else:assert rows[row][24:26]=='--'
  assert rows[row+1][5]=='[' and rows[row+1][26]==']',(row,rows[row+1])
  assert rows[row+1][6:26]=='#'*width+' '*(20-width),(row,rows[row+1],width)
 assert 'Prev '+str(int(s['pn'])) in rows[1],rows[1]
 assert 'scroll?' not in ''.join(rows).lower()
def result():
 s=wait('Q quits.');chart(s)
 samples.append({k:s[k] for k in ('n','pn','b','done','t','p')});return s
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(out/'dice-roller.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');wait('1-4 chooses.')
 assert m.program_lines()=={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};capture('sizes');record('fresh-tape-autostart-stored-identity')
 for k in ('0','5','a',' ','enter'):key(k);assert wait('1-4 chooses.')['n']==0
 record('invalid-size-keys-preserve-state')
 key('q');stop();m.statement('RUN');wait('1-4 chooses.');record('size-menu-quit-and-run')
 key('1');s=result();assert s['n']==12 and s['pn']==0 and s['b']==12 and s['done']==12;capture('twelve');record('twelve-rolls-and-first-result-without-previous')
 old=s
 for k in ('1','x',' ','enter'):key(k);s=result();assert s['t']==old['t'] and s['n']==12
 record('invalid-result-keys-preserve-counts')
 m.key('caps','r');s=result();assert s['n']==12 and s['pn']==12 and s['p']==old['t'];capture('repeat');record('fresh-repeat-keeps-previous-sample')
 old=s;m.key('caps','a');s=result();assert s['n']==24 and s['pn']==12 and s['p']==old['t'] and all(x>=y for x,y in zip(s['t'],old['t']));capture('added');record('adding-preserves-counts-and-compares-prior-total')
 old=s;key('r');s=result();assert s['n']==12 and s['pn']==24 and s['p']==old['t'];record('fresh-repeat-clears-accumulation')
 for choice,size in [('2',60),('3',300),('4',1200)]:
  old=s;m.key('caps','n');menu=wait('1-4 chooses.');assert menu['t']==old['t'] and menu['n']==old['n'];key(choice)
  if size==300:
   live=[]
   for _ in range(9000):
    if line(m)==1170:
     observed=read()
     if 1<observed['n']<size and (not live or observed['n']>live[-1]):
      chart(observed);live.append(observed['n'])
      if len(live)==2:break
    m.frames(1)
   assert len(live)==2,live
   capture('rolling');record('live-chart-updates-during-batch')
  s=result();assert s['n']==size and s['b']==size and s['pn']==old['n'] and s['p']==old['t'];capture('sample-'+str(size));record('batch-'+str(size)+'-and-fixed-chart-scale')
 # ROM-command boundary fixture avoids thousands of redundant intermediate rolls.
 key('q');stop()
 cmds=['LET n=8400: LET b=1200: LET done=1200','FOR j=1 TO 6: LET t(j)=1400: NEXT j','GO TO 600']
 for cmd in cmds:m.statement(cmd)
 s=result();fixtures.append({'commands':cmds,'counts':s['t']})
 old=s;key('a');s=result();assert s['n']==9600 and s['p']==old['t'] and s['pn']==8400;assert all(x>=y for x,y in zip(s['t'],old['t']))
 capture('maximum');record('add-to-9600-from-labelled-boundary-fixture')
 old=s;key('a');s=result();assert s['t']==old['t'] and s['p']==old['p'] and s['n']==9600;assert any('9600 limit' in r for r in m.screen());record('limit-rejects-add-without-changing-comparison')
 # Holding Q during a running batch stops, but the release gate must keep its result visible.
 key('r');m.call('input',events=[{'Key':{'name':'q','pressed':True}}]);s=wait('Q quits.');assert 0<s['done']<s['b'];m.frames(200);assert line(m)==8010
 m.call('input',events=[{'Key':{'name':'q','pressed':False}}]);m.frames(10);s=result();capture('stopped');record('stop-retains-partial-counts-and-held-q-does-not-quit')
 key('q');stop();record('result-quit')
 # Labelled boundary fixture: exact zero and 100% bars, using ordinary ROM commands.
 cmds=['LET n=1: LET pn=0: LET b=12: LET done=12','DIM t(6): DIM p(6): LET t(1)=1','GO TO 600']
 for cmd in cmds:m.statement(cmd)
 s=result();assert s['t']==[1,0,0,0,0,0];fixtures.append({'commands':cmds,'counts':s['t']});record('zero-and-hundred-percent-chart-boundary-fixture')
 key('q');stop();m.statement('RUN');wait('1-4 chooses.');key('1');s=result()
 m.call('input',events=[{'Key':{'name':'r','pressed':True}}]);m.frames(20);s=wait('Q quits.');m.frames(500);held=read();assert held['n']==12 and held['pn']==12 and line(m)==8010
 m.call('input',events=[{'Key':{'name':'r','pressed':False}}]);m.frames(10);result();record('held-repeat-starts-one-batch')
 key('n');wait('1-4 chooses.');m.key('caps','q');stop();record('uppercase-menu-quit')
 (out/'results.json').write_text(json.dumps({'source_sha256':hashlib.sha256((ROOT/'dice-roller.bas').read_bytes()).hexdigest(),'binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),'server':m.server,'configuration':'Stock 48K PAL; fresh ROM tape and ordinary keys; boundary fixture uses explicit ROM commands','checks':checks,'samples':samples,'fixtures':fixtures,'direct_memory_writes':False},indent=2)+'\n')
except Exception:
 (out/'failure.json').write_text(json.dumps({'line':line(m),'screen':m.screen(),'checks':checks},indent=2)+'\n');raise
finally:m.close()
