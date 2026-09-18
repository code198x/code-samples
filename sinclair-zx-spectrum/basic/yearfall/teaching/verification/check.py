"""Execute intermediate teaching tapes through ROM keys; observations are read-only."""
import argparse,concurrent.futures,hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
from model import plan,resolve,choose,travellers
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line
NAMES=['ledger','food','seed','harvest','editor','planner','years','trade','visitors','continued']
def check(item,exe,output):
 name=item['name'];level=NAMES.index(name);out=output/name;m=Spectrum(exe,out);checks=[];trials=[];fixtures=[];events=[]
 def record(label):checks.append(label);print('PASS',name,label,flush=True)
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
  raise AssertionError((name,text,line(m),m.screen()))
 def stopped():
  for _ in range(1500):
   if any('9 STOP statement' in r for r in m.screen()):return snapshot()
   m.frames(5)
  raise AssertionError((name,line(m),m.screen()))
 def key(k):m.key('space' if k==' ' else k);m.frames(8)
 def ready():return wait('SPACE harvest.')
 def capture(label):m.call('save_screenshot',path=str(out/(label+'.png')))
 def edit(k,value):
  key(k);wait('DELETE erases.')
  for ch in str(value):key(ch);wait('DELETE erases.')
  key('enter');return ready()
 def reset():key('r');s=ready();assert (s['pop'],s['grain'],s['land'],s['yr'],s['lost'])==(60,360,100,1,0);return s
 def commit():
  b=ready();trade=int(b.get('trade',0));price=int(b.get('price',0))
  params=[int(b[k]) for k in ['pop','grain','land']]+[price,trade,int(b['feed']),int(b['plant'])]
  assert plan(*params)['ok'];key(' ');a=wait('GRAIN ACCOUNT');expect=resolve(*params,int(a['crop']))
  if level<6:expect=(expect[0]-expect[4],expect[1],expect[2],expect[3],0)
  assert tuple(a[k] for k in ['pop','grain','land','deaths','newcomers'])==expect,(name,params,a,expect)
  assert a['lost']==b['lost']+a['deaths']
  assert a['oldgrain']-a.get('welcome',0)-trade*price-b['feed']-b['plant']+a['harvest']==a['grain']
  trials.append({'year':b['yr'],'start':params[:3],'plan':params[3:],'yield':a['crop'],'result':expect});return a
 def arrive():
  b=wait('YEARFALL')
  if not any('TRAVELLERS AT THE GATE' in r for r in m.screen()):return ready()
  accept=bool(events) and b['can']==1
  expected=travellers(*(int(b[k]) for k in ['pop','grain','land','guests']),accept)
  key('y' if accept else 'n');a=ready()
  assert tuple(a[k] for k in ['pop','grain','land','admitted','welcome'])==expected
  assert 3<=a['visit']-a['yr']<=5
  events.append({'year':b['yr'],'accepted':accept,'guests':b['guests'],'after':expected});return a
 try:
  m.call('load_media',slot='tape-1',kind='tape',path=str(out/'yearfall.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start')
  s=stopped() if level<4 else ready()
  assert m.program_lines()=={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};capture('initial');record('fresh-tape-autostart-stored-identity')
  if level==0:
   assert (s['pop'],s['grain'],s['land'])==(60,360,100);record('initial-settlement-ledger')
  if level in [1,2]:
   assert s['fed']==60 and s['left']==(180 if level==1 else 80) and s['ok']==1;record('food-and-seed-budget')
   variants=[(220,'LET feed=179',{'fed':59,'left':181 if level==1 else 81}),(220,'LET feed=361',{'ok':0})]
   if level==2:variants += [(220,'LET feed=120',{'fed':40,'ok':0}),(240,'LET plant=101',{'ok':0})]
   original={int(l.split()[0]):l for l in (ROOT/item['source']).read_text().splitlines()}
   for n,text,expected in variants:
    m.statement(f'{n} {text}');m.statement('RUN');a=stopped();assert all(a[k]==v for k,v in expected.items()),(name,text,a)
    fixtures.append({'ordinary_ROM_line_edit':f'{n} {text}','expected':expected});m.statement(original[n])
   assert m.program_lines()=={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};record('documented-line-edit-experiments-and-restoration')
  if level==3:
   assert 2<=s['crop']<=5 and s['grain']==80+100*s['crop'] and s['pop']==60 and s['newcomers']==0;record('single-harvest-ledger-without-growth')
   m.statement('240 LET plant=101');m.statement('RUN');a=stopped();assert a['ok']==0 and a['grain']==360 and a['pop']==60;fixtures.append({'ordinary_ROM_line_edit':'240 LET plant=101','expected':'rejected before resources change'});m.statement('240 LET plant=100');record('invalid-plan-stops-before-harvest')
  if level>=4:
   assert s['feed']==180 and s['plant']==100 and s['left']==80;record('initial-draft-budget')
   key('a');assert ready()['grain']==360;record('ignored-key-does-not-commit')
   key('f');wait('DELETE erases.');key('9');wait('DELETE erases.');key('x');assert ready()['feed']==180;record('cancel-preserves-plan')
   key('f');wait('DELETE erases.');key('1');wait('DELETE erases.');m.key('caps','0');assert wait('DELETE erases.')['d$']=='';key('enter');assert ready()['feed']==180;record('delete-and-empty-entry')
   key('f');wait('DELETE erases.');m.call('input',events=[{'Key':{'name':'2','pressed':True}}]);m.frames(150);assert snapshot()['d$']=='2';m.call('input',events=[{'Key':{'name':'2','pressed':False}}]);m.frames(10);key('x');ready();record('held-digit-counts-once')
   edit('f',99999);s=ready();assert s['feed']==9999 and s['ok']==0;key(' ');assert ready()['grain']==360;record('bounded-input-and-invalid-budget')
   reset();s=edit('f',179);assert s['fed']==59 and s['ok']==1;s=commit();assert s['deaths']==1 and s['newcomers']==0;capture('short-rations');record('partial-food-and-year-ledger')
   if level<6:
    before=s;key(' ');a=wait('GRAIN ACCOUNT');assert a['yr']==1 and a['grain']==before['grain'];record('single-year-report-retained')
   if level>=5:
    reset();edit('p',101);assert ready()['ok']==0;record('land-limits-planting')
    reset();edit('f',0);assert ready()['ok']==0;edit('p',0);a=commit();assert a['pop']==0;record('fed-workforce-and-empty-harvest')
    if level>=6:
     key(' ');a=wait('settlement is empty.');key('c');assert wait('settlement is empty.')['pop']==0;record('empty-ending-cannot-continue')
   reset()
   if level>=7:
    s=edit('b',5);assert s['trade']==5 and 'Spend ' in m.screen()[10]
    s=edit('s',10);assert s['trade']==-10 and 'Receive ' in m.screen()[10]
    edit('p',90);commit();record('separate-buy-sell-and-sale-ledger')
    reset();edit('s',101);assert ready()['ok']==0;key(' ');assert ready()['land']==100;record('ownership-limit')
    reset()
    key('q');stopped();m.statement('LET grain=220');m.statement('LET price=8');m.statement('GO TO 220');ready();s=edit('p',100);assert s['left']==-60
    edit('s',7);s=edit('p',93);assert s['left']==3 and s['ok']==1 and '189 to 468' in m.screen()[17];fixtures.append({'ordinary_ROM_commands':['LET grain=220','LET price=8','GO TO 220'],'keys':['p','1','0','0','enter','s','7','enter','p','9','3','enter'],'expected':'3 retained; harvest balance 189 to 468'});record('worked-recovery-budget-fixture')
    reset()
   if level>=6:
    key('q');stopped();m.statement('RANDOMIZE 17');m.statement('RUN 200');ready();last=30 if level==9 else 10
    for year in range(1,last+1):
     s=ready();assert s['yr']==year
     if level>=7:
      t,f,a=choose(*(int(s[k]) for k in ['pop','grain','land','price']))
      for field,k,v in [('trade','s' if t<0 else 'b',abs(t)),('feed','f',f),('plant','p',a)]:
       target=t if field=='trade' else v
       if s[field]!=target:s=edit(k,v)
     a=commit()
     key(' ')
     if a['pop']==0:
      wait('settlement is empty.');break
     if year%10==0:
      summary=wait('Years completed:');assert summary['yr']==year;capture('summary')
      if year==last:
       if level<9:key('c');assert wait('Years completed:')['yr']==year
       break
      key('c');arrive()
     else:arrive()
    if level>=7:assert year==last and a['pop']>0
    record('year-progression-and-ending')
    if level>=8:assert any(e['accepted'] for e in events) and not events[0]['accepted'];record('welcome-and-decline-resource-deltas')
    if level==9:record('thirty-years-with-preserved-decade-continuation')
   reset();key('q');stopped();record('reset-and-quit')
  (out/'results.json').write_text(json.dumps({'source_sha256':hashlib.sha256((ROOT/item['source']).read_bytes()).hexdigest(),'checks':checks,'trials':trials,'events':events,'fixtures':fixtures,'direct_memory_writes':False,'configuration':'Fresh stock 48K PAL tape load; ordinary key play. Listed early experiments edit source through ROM keys; yearly fixtures use RANDOMIZE 17 and RUN 200.','binary_sha256':hashlib.sha256(Path(exe).read_bytes()).hexdigest()},indent=2)+'\n')
 except Exception:
  (out/'failure.json').write_text(json.dumps({'line':line(m),'screen':m.screen(),'checks':checks,'trials':trials},indent=2)+'\n');raise
 finally:m.close()
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only');p.add_argument('--jobs',type=int,default=1);a=p.parse_args()
 items=[i for i in json.loads((ROOT/'checkpoints.json').read_text()) if i['name'] in NAMES and (not a.only or i['name']==a.only)]
 with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:list(pool.map(lambda i:check(i,a.emulator,a.output.resolve()),items))
