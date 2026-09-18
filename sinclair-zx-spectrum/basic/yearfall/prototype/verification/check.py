"""Fresh-ROM tape checks: ordinary keys only, read-only memory observations."""
import argparse,hashlib,json,sys
from pathlib import Path
from entry import Spectrum,ROOT
from model import plan,resolve,choose
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();m=Spectrum(a.emulator,out);checks=[];trials=[];retries=0

def record(name):checks.append(name);print('PASS',name,flush=True)
def wait(text):
 global retries
 for _ in range(3000):
  if line(m) in (8010,8020) and any(text in r for r in m.screen()):
   for retry in range(9):
    try:return state(m)
    except (AssertionError,IndexError):
     if retry==8:raise
     retries+=1;m.frames(1)
  m.frames(5)
 raise AssertionError((text,line(m),m.screen()))
def key(k):m.key('space' if k==' ' else k);m.frames(8)
def ready():return wait('SPACE harvest.')
def report():return wait('GRAIN ACCOUNT')
def edit(which,value):
 key(which);wait('DELETE erases.')
 for c in str(value):
  if c=='-':m.key('symbol','j')
  else:key(c)
  wait('DELETE erases.')
 key('enter');return ready()
def reset():
 key('r');s=ready();assert (s['pop'],s['grain'],s['land'],s['yr'],s['lost'])==(60,360,100,1,0);return s

def commit():
 before=ready();params=[int(before[k]) for k in ['pop','grain','land','price','trade','feed','plant']]
 expected=plan(*params);assert expected['ok'];key(' ');after=report()
 result=resolve(*params,int(after['crop']))
 assert tuple(after[k] for k in ['pop','grain','land','deaths','newcomers'])==result,(before,after,result)
 assert after['lost']==before['lost']+result[3]
 assert after['yr']==before['yr']
 assert after['grain']==before['grain']-before['trade']*before['price']-before['feed']-before['plant']+after['harvest']
 trials.append({'year':before['yr'],'start':params[:3],'price':params[3],'plan':params[4:],'yield':after['crop'],'result':result})
 return after

def capture(name):m.call('save_screenshot',path=str(out/(name+'.png')))
def stop():
 for _ in range(500):
  if any('9 STOP statement' in s for s in m.screen()):return
  m.frames(5)
 raise AssertionError(m.screen())
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(out/'yearfall.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');wait('S starts.')
 assert m.program_lines()=={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};capture('title');record('fresh-tape-autostart-token-identity')
 key('a');wait('S starts.');key('q');stop();record('title-ignored-key-and-quit')
 m.statement('RUN');wait('S starts.');key('s');s=ready();assert (s['feed'],s['plant'],s['left'],s['fed'],s['ok'])==(180,100,80,60,1);capture('planning');record('initial-live-budget')
 before=s
 for k in ['a','0','enter']:key(k);s=ready();assert s['yr']==1 and s['grain']==360
 record('ignored-planning-keys-preserve-state')
 # The number editor accepts only digits, an initial trade sign and editing keys.
 key('f');wait('DELETE erases.');key('a');key('enter');assert ready()['feed']==180
 key('f');wait('DELETE erases.');key('1');wait('DELETE erases.');m.key('caps','0');s=wait('DELETE erases.');assert s['d$']==''
 key('enter');assert ready()['feed']==180;record('empty-invalid-and-delete-input')
 key('f');wait('DELETE erases.');key('9');wait('DELETE erases.');key('x');assert ready()['feed']==180;record('cancel-preserves-plan')
 key('f');wait('DELETE erases.');key('1');wait('DELETE erases.');capture('editing');m.call('input',events=[{'Key':{'name':'2','pressed':True}}]);m.frames(180)
 assert state(m)['d$']=='12';m.call('input',events=[{'Key':{'name':'2','pressed':False}}]);m.frames(10);key('x');ready();record('held-digit-is-one-entry')
 s=edit('f','99999');assert s['feed']==9999 and s['ok']==0;key(' ');assert ready()['yr']==1;record('four-digit-limit-and-over-budget-block')
 reset();s=edit('f',183);assert s['fed']==60;commit();assert report()['newcomers']==3;record('excess-food-gives-no-extra-newcomers')
 reset();s=edit('t',-101);assert s['ok']==0;key(' ');assert ready()['land']==100;capture('invalid-plan');record('cannot-sell-unowned-land')
 reset();s=edit('p',101);assert s['ok']==0;record('planting-limited-by-land')
 reset();s=edit('f',0);assert s['fed']==0 and s['ok']==0;key(' ');assert ready()['pop']==60;record('unfed-workers-cannot-plant')
 # Trade itself is not committed until a valid plan is harvested.
 reset();s=edit('t',5);assert s['land']==100 and s['grain']==360 and s['acres']==105
 edit('p',105);s=ready();assert s['ok']==1;commit();capture('harvest');record('purchase-and-ledger-resolution')
 reset();edit('t',-10);edit('p',90);commit();record('sale-and-ledger-resolution')
 reset();s=edit('f',179);assert s['fed']==59 and s['ok']==1;commit();s=report();assert s['deaths']==1 and s['newcomers']==0;capture('short-rations');record('partial-ration-costs-one-person-and-no-newcomers')
 before=s;key('a');s=report();assert s['grain']==before['grain'] and s['yr']==before['yr'];record('report-does-not-advance-with-invalid-key')
 key(' ');s=ready();assert s['yr']==2 and s['pop']==59 and s['lost']==1;record('year-state-persists')
 # Reproducible RNG fixture via ordinary ROM commands, without memory writes.
 key('q');stop();m.statement('RANDOMIZE 17');m.statement('RUN 200');ready()
 for year in range(1,11):
  s=ready();assert s['yr']==year
  t,f,plant=choose(*(int(s[k]) for k in ['pop','grain','land','price']))
  for field,k,v in [('trade','t',t),('feed','f',f),('plant','p',plant)]:
   if s[field]!=v:s=edit(k,v)
  s=commit()
  if s['pop']==0:raise AssertionError('Managed trial collapsed; retain and investigate the trace')
  if year<10:key(' ');ready()
 capture('tenth-harvest');record('ten-year-managed-run-and-every-ledger')
 key(' ');s=wait('Q quits.');assert s['yr']==10 and s['pop']>0;capture('ten-years');record('finite-run-summary')
 before=s;key(' ');s=wait('Q quits.');assert s['grain']==before['grain'] and s['yr']==10;record('summary-is-stable')
 reset();s=ready();m.call('input',events=[{'Key':{'name':'space','pressed':True}}]);m.frames(400);assert state(m)['yr']==1 and any('GRAIN ACCOUNT' in r for r in m.screen());m.call('input',events=[{'Key':{'name':'space','pressed':False}}]);m.frames(10);report();record('held-harvest-does-not-skip-report')
 reset();edit('f',0);edit('p',0);s=commit();assert s['pop']==0 and s['lost']==60
 key(' ');s=wait('settlement is empty.');capture('empty');record('empty-settlement-ending')
 key('q');stop();record('quit-ending')
 m.statement('RUN');wait('S starts.');m.key('caps','s');ready();m.key('caps','t');wait('DELETE erases.');m.key('caps','x');ready();m.key('caps','r');ready();record('uppercase-menu-and-reset')
 key('q');stop();record('quit-planning')
 m.statement('RUN');wait('S starts.');key('s');ready();commit();key('q');stop();record('quit-report')
 (out/'results.json').write_text(json.dumps({'source_sha256':hashlib.sha256((ROOT/'yearfall.bas').read_bytes()).hexdigest(),'binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),'configuration':'Stock 48K PAL; fresh ROM tape load; ordinary key play; full-run fixture uses ROM RANDOMIZE 17 and RUN 200','checks':checks,'trials':trials,'sampling_retries':retries,'direct_memory_writes':False,'server':m.server},indent=2)+'\n')
except Exception:
 (out/'failure.json').write_text(json.dumps({'line':line(m),'screen':m.screen(),'checks':checks,'trials':trials},indent=2)+'\n');raise
finally:m.close()
