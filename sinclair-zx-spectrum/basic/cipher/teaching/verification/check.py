"""Verify intermediate Cipher tapes; final tape uses the prototype suite."""
import argparse,concurrent.futures,hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line

def check(name,exe,output):
 out=output/name;m=Spectrum(exe,out);checks=[];fixtures=[]
 def record(label):checks.append(label);print('PASS',name,label,flush=True)
 def snapshot():
  for _ in range(9):
   try:return state(m)
   except (AssertionError,IndexError):m.frames(1)
  raise AssertionError('incomplete variable table')
 def wait(text,stopped=False):
  for _ in range(3000):
   if (stopped or line(m) in (8010,8020)) and any(text in row for row in m.screen()):return snapshot()
   m.frames(5)
  raise AssertionError((name,text,line(m),m.screen()))
 def key(k):m.key('space' if k==' ' else k)
 def ready():return wait('ENTER quits.' if name=='guess' else 'ENTER pauses.')
 def capture(label):m.call('save_screenshot',path=str(out/(label+'.png')))
 def stop():return wait('9 STOP statement',True)
 def guess(k):key(k);return ready()
 try:
  m.call('load_media',slot='tape-1',kind='tape',path=str(out/'cipher.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start')
  s=stop() if name=='reveal' else ready()
  assert m.program_lines()=={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};capture('initial');record('fresh-tape-autostart-stored-identity')
  if name=='reveal':
   assert s['w$']=='BOTTLE' and s['d$']=='__TT__' and s['found']==2;record('both-matching-positions')
   for g,mask,count in [('L','____L_',1),('Z','______',0)]:
    m.statement('200 LET w$="BOTTLE": LET g$="'+g+'"');m.statement('RUN');s=stop();assert s['d$']==mask and s['found']==count
    fixtures.append({'edit':g,'mask':mask,'matches':count})
   m.statement('200 LET w$="BOTTLE": LET g$="T"');m.statement('RUN');stop();record('single-and-missing-letter-source-experiments')
  else:
   assert s['d$']=='______'
   for k in ('1',' ','0'):key(k);assert ready()['d$']=='______'
   m.key('caps','0');assert ready()['d$']=='______';record('nonletters-ignored')
   m.key('caps','t');s=ready();assert s['d$']=='__TT__' and s['found']==2;capture('two-matches');record('uppercase-and-repeated-positions')
   s=guess('t');assert s['d$']=='__TT__';record('repeat-preserves-reveal')
   if name=='guess':
    s=guess('z');assert s['d$']=='__TT__' and 'not in the word' in s['a$'];record('miss-without-mistake-limit')
    m.call('input',events=[{'Key':{'name':'b','pressed':True}}]);m.frames(200);assert snapshot()['d$']=='B_TT__';m.call('input',events=[{'Key':{'name':'b','pressed':False}}]);m.frames(10);ready();record('held-key-gate')
    for k in ('o','l','e'):s=guess(k)
    assert s['d$']=='BOTTLE';record('revealed-word-does-not-end-this-stage')
    key('enter');stop();record('enter-quits')
   else:
    assert s['left']==7 and s['t$']=='T'
    s=guess('z');s=guess('z');assert s['left']==6 and s['m$']=='Z' and s['t$']=='TZ';capture('miss');record('duplicate-hit-and-miss-cost-nothing')
    if name=='board':assert s['u$']==''.join('.' if c in 'TZ' else c for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');record('alphabet-mask-matches-history')
    before=s;key('enter');wait('PAUSED');key('a');wait('PAUSED');m.key('caps','c');s=ready();assert all(s[k]==before[k] for k in ('w$','d$','t$','m$','left','round'));record('pause-invalid-key-and-continue-preserve-state')
    for k in ('b','o','l'):guess(k)
    key('e');s=wait('SPACE next.');assert s['wins']==1 and s['losses']==0 and s['left']==6;capture('won');record('win-and-score')
    key('a');assert wait('SPACE next.')['round']==1
    m.call('input',events=[{'Key':{'name':'space','pressed':True}}]);m.frames(250);s=snapshot();assert s['round']==2 and s['wins']==1 and s['t$']=='';m.call('input',events=[{'Key':{'name':'space','pressed':False}}]);m.frames(10);ready();record('held-next-advances-once-with-score-retained')
    for k in 'acdfgh':guess(k)
    key('i');s=wait('SPACE next.');assert s['left']==0 and s['losses']==1 and s['wins']==1;assert 'BOTTLE' in ''.join(m.screen()).replace(' ','');capture('lost');record('seven-misses-reveal-answer')
    m.key('caps','r');s=ready();assert s['round']==1 and s['wins']==s['losses']==0;record('result-reset')
    s=guess('q');s=guess('r');assert s['m$']=='QR' and s['left']==5;record('q-and-r-remain-guesses')
    key('enter');wait('PAUSED');key('r');s=ready();assert s['t$']=='' and s['left']==7;record('pause-reset')
    m.call('input',events=[{'Key':{'name':'t','pressed':True}}]);m.frames(250);assert snapshot()['t$']=='T';m.call('input',events=[{'Key':{'name':'t','pressed':False}}]);m.frames(10);ready();record('held-letter-counts-once')
    key('enter');wait('PAUSED');key('q');stop();record('pause-quit')
  (out/'results.json').write_text(json.dumps({'source_sha256':hashlib.sha256((ROOT/name/'cipher.bas').read_bytes()).hexdigest(),'binary_sha256':hashlib.sha256(Path(exe).read_bytes()).hexdigest(),'server':m.server,'configuration':'Fresh ROM tape on stock 48K PAL','checks':checks,'fixtures':fixtures,'direct_memory_writes':False},indent=2)+'\n')
 except Exception:
  (out/'failure.json').write_text(json.dumps({'line':line(m),'screen':m.screen(),'checks':checks},indent=2)+'\n');raise
 finally:m.close()
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--jobs',type=int,default=1);p.add_argument('--only');a=p.parse_args()
 names=[n for n in ('reveal','guess','rules','board') if not a.only or n==a.only]
 with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:list(pool.map(lambda n:check(n,a.emulator,a.output.resolve()),names))
