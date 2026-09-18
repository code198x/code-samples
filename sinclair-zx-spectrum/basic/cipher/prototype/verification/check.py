"""Fresh-tape Cipher checks with read-only observation and ordinary ROM/key input."""
import argparse,hashlib,json,sys
from pathlib import Path
from entry import Spectrum,ROOT
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();m=Spectrum(a.emulator,out);checks=[];fixtures=[];delays=[];ordinary_delays=[]
def record(name):checks.append(name);print('PASS',name,flush=True)
def wait(text):
 for frames in range(0,15000,5):
  if line(m) in (8010,8020) and any(text in row for row in m.screen()):
   for attempt in range(9):
    try:return state(m),frames
    except (AssertionError,IndexError):
     if attempt==8:raise
     m.frames(1)
  m.frames(5)
 raise AssertionError((text,line(m),m.screen()))
def ready():return wait('ENTER pauses.')[0]
def key(k):m.key('space' if k==' ' else k)
def capture(name):m.call('save_screenshot',path=str(out/(name+'.png')))
def stop():
 for _ in range(400):
  if any('9 STOP statement' in row for row in m.screen()):return
  m.frames(5)
 raise AssertionError(m.screen())
def guess(k,upper=False):
 before=ready();letter=k.upper();seen=letter in before['t$'];found=letter in before['w$'];expected=''.join(c if c==letter else before['d$'][i] for i,c in enumerate(before['w$']))
 if upper:m.key('caps',k)
 else:key(k)
 end=(expected==before['w$'] or (before['left']==1 and not seen and not found))
 after,frames=wait('SPACE next.' if end else 'ENTER pauses.');delays.append(frames)
 if not end:ordinary_delays.append(frames)
 assert after['d$']==expected
 assert after['left']==before['left']-int(not seen and not found)
 assert after['t$']==before['t$']+('' if seen else letter)
 assert after['u$']==''.join('.' if c in after['t$'] else c for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
 assert after['m$']==before['m$']+('' if seen or found else letter)
 assert after['wins']==before['wins']+int(expected==before['w$'])
 assert after['losses']==before['losses']+int(after['left']==0)
 return after,end
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(out/'cipher.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');wait('S starts.');capture('title')
 assert m.program_lines()=={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};record('fresh-ROM-tape-autostart-and-token-identity')
 key('a');wait('S starts.');key('q');stop();record('title-invalid-key-and-quit')
 m.statement('RUN');wait('S starts.');m.key('caps','s');s=ready();assert (s['round'],s['wins'],s['losses'],s['left'],s['t$'],s['m$'])==(1,0,0,7,'','');capture('opening');record('uppercase-start-and-empty-history')
 for k in ('1','0',' ','symbol'):
  key(k);after=ready();assert after['d$']==s['d$'] and after['t$']=='' and after['left']==7
 m.key('caps','0');after=ready();assert after['t$']=='';record('digits-space-delete-and-modifier-ignored')
 letter=s['w$'][0].lower();s,_=guess(letter,upper=True);assert s['found']==s['w$'].count(letter.upper());capture('revealed');record('uppercase-guess-reveals-all-matches')
 before=s;s,_=guess(letter);assert s['t$']==before['t$'] and s['left']==7;capture('repeat');record('repeated-hit-is-free')
 miss=next(c for c in 'ZXQJV' if c not in s['w$']);s,_=guess(miss.lower());before=s;s,_=guess(miss.lower());assert s['left']==6 and s['m$']==miss;capture('miss');record('miss-costs-once-and-is-listed')
 key('enter');paused=wait('PAUSED')[0];capture('paused');key('a');again=wait('PAUSED')[0];assert again['t$']==paused['t$'];m.key('caps','c');after=ready();assert all(after[k]==paused[k] for k in ('w$','d$','left','t$','m$','wins','losses','round'));record('pause-invalid-key-and-continue-preserve-round')
 for c in sorted(set(after['w$'])-set(after['t$'])):s,end=guess(c.lower())
 assert end and s['wins']==1 and s['losses']==0;capture('won');record('legal-word-completion-and-retained-result')
 key('a');after=wait('SPACE next.')[0];assert after['wins']==1 and after['round']==1
 key(' ');s=ready();assert s['round']==2 and s['wins']==1 and s['w$']!=after['w$'];record('next-round-preserves-score-and-prevents-immediate-repeat')
 misses=[c for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' if c not in s['w$']][:7]
 for c in misses:s,end=guess(c.lower())
 assert end and s['losses']==1 and s['wins']==1 and s['left']==0;capture('lost');record('seven-distinct-misses-lose-and-reveal-answer')
 m.key('caps','r');s=ready();assert s['round']==1 and s['wins']==s['losses']==0;record('result-reset-clears-session')
 letter=s['w$'][0].lower();m.call('input',events=[{'Key':{'name':letter,'pressed':True}}]);m.frames(1000)
 held=state(m);assert held['t$']==letter.upper() and held['left']==7
 m.call('input',events=[{'Key':{'name':letter,'pressed':False}}]);m.frames(10);ready();record('held-letter-is-one-guess')
 key('enter');wait('PAUSED');m.key('caps','r');s=ready();assert s['t$']=='' and s['round']==1;record('pause-reset-clears-session')
 key('enter');wait('PAUSED');m.key('caps','q');stop();record('pause-quit')
 # Explicit ROM diagnostics select each authored word; no direct memory writes.
 words=[]
 for pick in range(1,25):
  m.statement('LET pick='+str(pick));m.statement('GO TO 230');s=ready();words.append(s['w$'])
  assert s['w$'].isalpha() and s['w$'].isupper() and 4<=len(s['w$'])<=8
  for c in sorted(set(s['w$'])):s,end=guess(c.lower())
  assert end and s['left']==7
  fixtures.append({'ROM_setup':['LET pick='+str(pick),'GO TO 230'],'word':s['w$'],'guesses':s['t$'],'remaining':s['left']})
  key('q');stop()
 assert len(set(words))==24;record('all-24-authored-words-load-reveal-and-complete')
 # Q and R must be usable guesses, never accidental menu actions.
 m.statement('LET pick=16');m.statement('GO TO 230');s=ready()
 for c in ('q','r'):s,end=guess(c)
 assert s['t$']=='QR' and s['left']==6;record('q-and-r-are-letters-during-play')
 key('enter');wait('PAUSED');key('q');stop()
 (out/'results.json').write_text(json.dumps({'source_sha256':hashlib.sha256((ROOT/'cipher.bas').read_bytes()).hexdigest(),'binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),'server':m.server,'configuration':'Stock 48K PAL; fresh ROM tape; ordinary key play; content coverage uses explicit ROM commands','checks':checks,'fixtures':fixtures,'max_poll_frames_after_key':max(delays),'max_ordinary_guess_poll_frames':max(ordinary_delays),'direct_memory_writes':False},indent=2)+'\n')
except Exception:
 (out/'failure.json').write_text(json.dumps({'line':line(m),'screen':m.screen(),'checks':checks},indent=2)+'\n');raise
finally:m.close()
