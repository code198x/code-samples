"""Expose the original tile sketches and their four UDG byte rows for teaching."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=ROOT.parent/'prototype/crates.bas'
rows=[list(map(int,l.split(' DATA ')[1].split(','))) for l in p.read_text().splitlines() if ' DATA ' in l]
out=['# Crates tile source','', 'Original 16×16 artwork, reconstructed losslessly from the accepted prototype. Each tile uses four 8×8 characters in top-left, top-right, bottom-left, bottom-right order. `#` sets an INK pixel; `.` leaves PAPER. The row bytes are pixel masks, not character codes or colours.','', 'Lesson 1 allocates its crate to characters 144–147. In the complete tile bank the crate occupies 152–155. The pixels are identical; the allocation changes as the bank grows.','']
for i,name in enumerate(['Brickwork','Target','Crate','Player','Player on target']):
 q=rows[4*i:4*i+4]
 bits=lambda x:format(x,'08b').replace('0','.').replace('1','#')
 pixels=[bits(q[0][j])+bits(q[1][j]) for j in range(8)]+[bits(q[2][j])+bits(q[3][j]) for j in range(8)]
 out += ['## '+name,'','```text',*pixels,'```','','| Quadrant | Character code in full bank | Eight row bytes |','|---|---|---|']
 for j,title in enumerate(['Top left','Top right','Bottom left','Bottom right']):out.append(f'| {title} | {144+4*i+j} | '+', '.join(map(str,q[j]))+' |')
 out+=['']
out+=['The delivered crate reuses the crate bitmap with green ink. The teaching HUD also states how many goals are filled, so delivery need not be inferred only from colour. That added HUD cue is part of the approved teaching version.','', 'Original artwork and source are covered by the code-samples MIT licence. Spectrum UDG storage and encoding: Steven Vickers, edited by Robin Bradbeer, *ZX Spectrum BASIC Programming*, second edition (Sinclair Research, 1983), chapter 14.','']
(ROOT/'tiles.md').write_text('\n'.join(out))
