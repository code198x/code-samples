"""Compare a raw emitted PNG with the stable Spectrum screen bitmap.

Requires Pillow on the host. Reads original pixels; does not edit an image.
"""
import argparse,json,hashlib
from pathlib import Path
from PIL import Image
from entry import Spectrum,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--name',required=True);a=p.parse_args();out=ROOT/'verification/evidence';m=Spectrum(a.emulator,out)
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(out/'three.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');m.frames(5000)
 m.key('s');m.frames(300)
 for key in ('1','8','7','4'):m.key(key);m.frames(300)
 png=out/(a.name+'.png');m.call('save_screenshot',path=str(png))
 data=[]
 for addr in range(16384,22528,128):data+=m.call('memory_read',addr=addr,len=128)['bytes']
 # All game paper is black, all ink is non-black, and FLASH is disabled.
 attrs=[]
 for addr in range(22528,23296,128):attrs+=m.call('memory_read',addr=addr,len=128)['bytes']
 assert all((v&56)==0 and not(v&128) and (v&7)>0 for v in attrs)
 im=Image.open(png).convert('RGB');assert im.size==(352,296)
 mismatch=[]
 for y in range(192):
  for x in range(256):
   offset=((y&192)<<5)|((y&7)<<8)|((y&56)<<2)|(x//8)
   expected=bool(data[offset]&(128>>(x%8)))
   actual=any(im.getpixel((x+48,y+48)))
   if actual!=expected:mismatch.append([x,y])
 assert not mismatch,(len(mismatch),mismatch[:20])
 record={'status':'passed','configuration':'Stock 48K PAL','server':m.server,'source_sha256':hashlib.sha256((ROOT/'three.bas').read_bytes()).hexdigest(),'binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),'capture':png.name,'capture_sha256':hashlib.sha256(png.read_bytes()).hexdigest(),'screen_pixels_compared':49152,'mismatches':0,'method':'Fresh tape, S, legal moves 1/8/7/4. Original PNG foreground compared pixel-for-pixel with the stable screen bitmap; black paper, non-black ink, FLASH off. No image edits or state writes.'}
 (out/(a.name+'.json')).write_text(json.dumps(record,indent=2)+'\n');print('PASS',a.name,'49152 screen pixels')
finally:m.close()
