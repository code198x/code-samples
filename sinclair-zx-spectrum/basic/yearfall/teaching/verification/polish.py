"""Check the polished plan screen and quit path on a ROM-saved tape.

The plan must stay correct while only its changing figures are reprinted, and
every Q must leave through the one closing routine. Run it against the
`finished` tape as well: that program redraws the whole screen per edit and
stops on each Q line, so the update and exit checks fail there.
"""
import argparse,hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line
TITLE_ROW=0x4000  # top pixel line of character row 0; CLS clears it
QUIT_LINE=9020

def row(*parts):
 cells=[' ']*32
 for col,text in parts:
  for i,ch in enumerate(text):cells[col+i]=ch
 return ''.join(cells).rstrip()

def plan_rows(s):
 """The plan screen as the accepted game draws it from a cleared screen."""
 n=lambda v:str(int(v))
 trade=int(s['trade']);cost=int(s['cost']);ok=int(s['ok'])
 money='No land bought or sold.'
 if trade>0:money='Spend '+n(cost)+' grain on land.'
 if trade<0:money='Receive '+n(-cost)+' grain for land.'
 rows=['']*22
 rows[0]=row((1,'YEARFALL'),(20,'YEAR '+n(s['yr'])))
 rows[2]=row((1,'PEOPLE '+n(s['pop'])),(17,'LAND '+n(s['land'])))
 rows[3]=row((1,'GRAIN  '+n(s['grain'])),(17,'PRICE '+n(s['price'])))
 rows[5]=row((1,'PLAN'),(17,'AMOUNT'),(25,'COST'))
 rows[6]=row((1,'B  Buy land'),(17,n(s['buy'])))
 rows[7]=row((1,'S  Sell land'),(17,n(s['sell'])))
 rows[8]=row((1,'F  Feed grain'),(17,n(s['feed'])),(25,n(s['feed'])))
 rows[9]=row((1,'P  Plant acres'),(17,n(s['plant'])),(25,n(s['plant'])))
 rows[10]=row((1,money))
 rows[11]=row((1,'Grain left: '+n(s['left'])))
 rows[12]=row((1,'Food needed: '+n(3*s['pop'])))
 rows[13]=row((1,'Land after trade: '+n(s['acres'])))
 rows[14]=row((1,'Fed workers can plant: '+n(2*s['fed'])))
 rows[16]=row((1,s['m$']))
 if ok==1:rows[17]=row((1,'After harvest: '+n(s['left']+2*s['plant'])+' to '+n(s['left']+5*s['plant'])))
 rows[19]=row((1,'B/S land. F/P food/plant.'))
 rows[20]=row((1,'SPACE harvest. R reset. Q quit.'))
 return rows

p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--source',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();m=Spectrum(a.emulator,out);checks=[];failures=[];redraws=[];quits=[]
def record(name):checks.append(name);print('PASS',name,flush=True)
def expect(name,condition,detail):
 if condition:record(name)
 else:failures.append({'check':name,'detail':detail});print('FAIL',name,detail,flush=True)
def snapshot():
 for retry in range(9):
  try:return state(m)
  except (AssertionError,IndexError):
   if retry==8:raise
   m.frames(1)
def wait(text):
 for _ in range(3000):
  if line(m) in (8010,8020) and any(text in r for r in m.screen()):return snapshot()
  m.frames(5)
 raise AssertionError((text,line(m),m.screen()))
def stopped():
 for _ in range(1500):
  rows=m.screen()
  if any('STOP statement' in r for r in rows):return [r.rstrip() for r in rows]
  m.frames(5)
 raise AssertionError((line(m),m.screen()))
def key(k):m.key('space' if k==' ' else k);m.frames(8)
def ready():return wait('SPACE harvest.')
def screen_matches(label):
 s=ready();shown=[r.rstrip() for r in m.screen()[:22]];want=plan_rows(s)
 bad=[(i,shown[i],want[i]) for i in range(22) if shown[i]!=want[i]]
 if bad:failures.append({'check':'plan-screen-'+label,'rows':bad});print('FAIL plan-screen',label,bad,flush=True)
 return s,not bad
def edit(k,value,label):
 key(k);wait('DELETE erases.')
 for ch in str(value):key(ch);wait('DELETE erases.')
 key('enter');return screen_matches(label)
def quit(where):
 key('q');rows=stopped();report=next(r for r in rows if 'STOP statement' in r)
 farewell=any('Thanks for playing.' in r for r in rows) and any('RUN plays again.' in r for r in rows)
 quits.append({'from':where,'report':report,'farewell':farewell})
 return report.endswith(f'{QUIT_LINE}:1') and farewell
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(out/'yearfall.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');wait('S starts.')
 key('s');s,good=screen_matches('first-year');assert good,'the first plan screen must match before edits are compared'
 # Every edit below changes the plan; together they shrink and grow each figure
 # and each message so stale characters would show.
 steps=[('f',5,'feed-shrinks'),('f',180,'feed-grows'),('b',1234,'large-purchase'),('s',5,'sale-replaces-purchase'),
        ('s',0,'land-plan-cleared'),('p',7,'planting-shrinks'),('f',9999,'feed-at-editor-limit'),('p',100,'planting-restored'),('f',180,'plan-valid-again')]
 matched=[]
 for k,v,label in steps:
  m.call('watch_memory_clear');m.call('watch_memory_start',addr=TITLE_ROW,len=32)
  _,good=edit(k,v,label);matched.append(good)
  redraws.append({'edit':label,'title_row_writes':m.call('watch_memory_log',limit=1)['total_writes']})
 m.call('watch_memory_clear')
 # Cancelling and blank entry change nothing, but the editor borrowed rows 19-21.
 key('f');wait('DELETE erases.');key('9');wait('DELETE erases.');key('x');_,good=screen_matches('cancelled-edit');matched.append(good)
 key('p');wait('DELETE erases.');key('enter');_,good=screen_matches('blank-entry');matched.append(good)
 expect('every-edit-leaves-the-full-plan-screen',all(matched),[f for f in failures if f['check'].startswith('plan-screen')])
 expect('edits-leave-the-title-row-untouched',all(r['title_row_writes']==0 for r in redraws),redraws)
 key(' ');wait('GRAIN ACCOUNT');key(' ');s,good=screen_matches('next-year');expect('new-year-draws-a-fresh-frame',good and s['yr']==2,s['yr'])
 expect('quit-from-plan-says-goodbye',quit('plan'),quits[-1])
 m.statement('RUN');wait('S starts.')
 expect('quit-from-title-says-goodbye',quit('title'),quits[-1])
 m.statement('RUN');wait('S starts.');key('s');ready();key(' ');wait('GRAIN ACCOUNT')
 expect('quit-from-report-says-goodbye',quit('report'),quits[-1])
 m.statement('RUN');wait('S starts.');key('s');ready()
 edit('f',0,'nobody-fed');edit('p',0,'nothing-planted');key(' ');wait('GRAIN ACCOUNT');key(' ');wait('settlement is empty.')
 expect('quit-from-review-says-goodbye',quit('review'),quits[-1])
 # The prototype's unaffordable-offer route: seeded through ordinary ROM commands.
 m.statement('RANDOMIZE 17');m.statement('RUN 200');ready()
 edit('s',100,'sell-everything');edit('p',0,'plant-nothing');key(' ');wait('GRAIN ACCOUNT');key(' ');s=ready()
 edit('f',int(s['grain']),'feed-all-grain');key(' ');wait('GRAIN ACCOUNT');key(' ');wait('TRAVELLERS AT THE GATE')
 expect('quit-from-offer-says-goodbye',quit('offer'),quits[-1])
 m.call('save_screenshot',path=str(out/'farewell.png'))
 result={'source':str(a.source),'source_sha256':hashlib.sha256(a.source.read_bytes()).hexdigest(),'binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),
         'configuration':'Stock 48K PAL; fresh ROM tape load; ordinary key play; offer route uses ROM RANDOMIZE 17 and RUN 200',
         'checks':checks,'failures':failures,'redraws':redraws,'quits':quits,'direct_memory_writes':False,'server':m.server}
 (out/'polish.json').write_text(json.dumps(result,indent=2)+'\n')
 if failures:sys.exit(f'FAIL {len(failures)} polish checks; see {out/"polish.json"}')
 print('PASS',len(checks),'polish checks')
finally:m.close()
