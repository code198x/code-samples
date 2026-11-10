"""Compare native assemblers; execute freshly loaded tapes on a stock 48K."""
import argparse,hashlib,importlib.util,json,re,shutil,subprocess
from pathlib import Path
from types import ModuleType
ROOT=Path(__file__).resolve().parents[1]
DONOR=ROOT.parents[2]/'basic/meet-basic/opening/verification/verify.py'
spec=importlib.util.spec_from_file_location('transport',DONOR);transport=importlib.util.module_from_spec(spec);spec.loader.exec_module(transport)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def build_programs(assembler:str,output:str|Path,*sources:str)->None:
 """Assemble each source (all opening samples when none is named) to asm198x/<name>.{bin,tap} under output, without the emulator. Names are relative, so a tape's CODE block is the same in any checkout."""
 native=Path(output).resolve()/'asm198x';native.mkdir(parents=True,exist_ok=True)
 for source in [ROOT/s for s in sources] or sorted(ROOT.glob('*.asm')):
  for flag,ext in [('--bin','bin'),('--tapbas','tap')]:subprocess.run([assembler,'--dialect','pasmo','--cpu','z80',*([flag] if ext=='tap' else []),str(source),'-o',f'{source.stem}.{ext}'],check=True,cwd=native,capture_output=True)

def evidence_bytes()->ModuleType:
 spec=importlib.util.spec_from_file_location('evidence_bytes',ROOT.parents[3]/'scripts/evidence_bytes.py');e=importlib.util.module_from_spec(spec);spec.loader.exec_module(e);return e
def main():
 p=argparse.ArgumentParser();p.add_argument('--source',nargs='+',default=[],help='Source filenames instead of all opening samples');p.add_argument('--pasmo',required=True);p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--assembler',default='asm198x');a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True);report=[]
 build_programs(a.assembler,out,*a.source);programs={}
 for source in [ROOT/s for s in a.source] or sorted(ROOT.glob('*.asm')):
  name=source.stem;native=out/'asm198x'/name;reference=out/'pasmo'/name
  reference.parent.mkdir(exist_ok=True)
  for flag,ext in [('--bin','bin'),('--tapbas','tap')]:
   subprocess.run([a.pasmo,flag,str(source),f'{name}.{ext}',*([f'{name}.sym'] if ext=='bin' else [])],check=True,cwd=reference.parent)
  programs.update({f'asm198x/{name}.{ext}':sha(native.with_suffix('.'+ext)) for ext in ('bin','tap')})
  data=native.with_suffix('.bin').read_bytes();assert data==reference.with_suffix('.bin').read_bytes()
  for tool,path in [('asm198x',native),('pasmo',reference)]:
   m=transport.Spectrum(a.emulator,out)
   try:
    m.call('load_media',slot='tape-1',kind='tape',path=str(path.with_suffix('.tap')));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');m.frames(7000)
    actual=m.call('memory_read',addr=32768,len=len(data))['bytes']
    if name in ('move-character','clocked-character','debug-branch','debug-trail'):
     symbols={k:int(v,16) for k,v in re.findall(r'(\w+)\s+EQU\s+([0-9A-F]+)H',reference.with_suffix('.sym').read_text())}
     assert actual[:symbols['position']-32768]==list(data[:symbols['position']-32768])
     assert actual[symbols['blank']-32768:]==list(data[symbols['blank']-32768:])
    else:assert actual==list(data),(name,tool,'loaded bytes')
    if name!='first-program':
     assert m.call('memory_read',addr=0x5800,len=1)['bytes']==[71]
     expected=[170] if name=='one-byte' else [24,60,126,219,255,60,102,66]
     for i,b in enumerate(expected):assert m.call('memory_read',addr=0x4000+i*256+(15 if name in ('move-character','clocked-character','debug-branch','debug-trail') else 0),len=1)['bytes']==[b],(name,i)
    if name=='draw-routine':
     for i,b in enumerate([24,60,126,219,255,60,102,66]):assert m.call('memory_read',addr=0x4001+i*256,len=1)['bytes']==[b],(name,'second cell',i)
     assert m.call('memory_read',addr=0x5800,len=3)['bytes']==[71,71,71]
    if name=='move-character':
     def value(label):return m.call('memory_read',addr=symbols[label],len=1)['bytes'][0]
     def picture(column):return [m.call('memory_read',addr=0x4000+i*256+column,len=1)['bytes'][0] for i in range(8)]
     assert value('position')==15 and value('armed')==1
     m.call('press_key',key='o',hold_frames=100);m.frames(3)
     assert value('position')==14 and value('moves')==1
     assert picture(15)==[0]*8 and picture(14)==[24,60,126,219,255,60,102,66]
     m.key('o','p');assert value('position')==14
     for _ in range(16):m.key('o')
     assert value('position')==0 and value('moves')==15
     for _ in range(33):m.key('p')
     assert value('position')==31 and value('moves')==46
     for col in range(31):assert picture(col)==[0]*8
    if name=='clocked-character':
     def value(label):return m.call('memory_read',addr=symbols[label],len=1)['bytes'][0]
     def rom_frames():return int.from_bytes(bytes(m.call('memory_read',addr=23672,len=3)['bytes']),'little')
     f,u,r=value('frames'),value('updates'),rom_frames()
     m.frames(120)
     assert (value('frames')-f)%256==120 and (value('updates')-u)%256==20
     assert (rom_frames()-r)%16777216==120 and value('position')==15
     m.call('press_key',key='o',hold_frames=60);m.frames(2)
     assert value('position')==5,(name,'held left',value('position'))
     pos=value('position');m.call('press_keys',keys=['o','p'],hold_frames=60);m.frames(2)
     assert value('position')==pos
     m.call('press_key',key='o',hold_frames=120);m.frames(2);assert value('position')==0
     m.call('press_key',key='p',hold_frames=240);m.frames(2);assert value('position')==31
     for row,b in enumerate([24,60,126,219,255,60,102,66]):
      bitmap=m.call('memory_read',addr=0x4000+row*256,len=32)['bytes'];assert bitmap==[0]*31+[b]
    if name in ('debug-branch','debug-trail'):
     def pos():return m.call('memory_read',addr=symbols['position'],len=1)['bytes'][0]
     if name=='debug-branch':
      m.call('press_key',key='o',hold_frames=60);m.frames(2);assert pos()==15
     m.call('press_key',key='p',hold_frames=6);m.frames(2);assert pos()==16
     for row,b in enumerate([24,60,126,219,255,60,102,66]):
      assert m.call('memory_read',addr=0x4000+row*256+15,len=2)['bytes']==([b,b] if name=='debug-trail' else [0,b])
    m.call('save_screenshot'   ,path=str(out/f'{name}-{tool}.png'))
    from PIL import Image
    border=Image.open(out/f'{name}-{tool}.png').convert('RGB').getpixel((0,0));assert border[0]>100 and border[1]==border[2]==0 if name=='first-program' else border==(0,0,0),(name,border)
    print('PASS',name,tool,'fresh tape, code, display',flush=True)
   finally:m.close()
  report.append({'source':source.name,'source_sha256':sha(source),'code_sha256':sha(native.with_suffix('.bin')),'code_bytes':len(data),'native_and_pasmo_equal':True,'both_fresh_tapes_executed':True})
 e=evidence_bytes()
 result={'target':'stock 48K PAL','asm198x_version':subprocess.run([a.assembler,'--version'],capture_output=True,text=True).stderr.strip(),'pasmo_banner':subprocess.run([a.pasmo],capture_output=True,text=True).stderr.splitlines()[0],'pasmo_sha256':sha(Path(a.pasmo)),'emulator_sha256':sha(Path(a.emulator)),'checks':report,
  'assembler_sha256':sha(Path(shutil.which(a.assembler) or a.assembler)),'programs':programs,
  'tools':{'assembler':e.tool_identity(a.assembler),'emulator':e.tool_identity(a.emulator),'pasmo':e.tool_identity(a.pasmo)},'status':'passed'}
 (out/'native-results.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
