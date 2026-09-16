"""Keep one named program from a ROM recording, without changing its bytes."""
from pathlib import Path

def keep_program(path,name):
    path=Path(path);data=path.read_bytes();blocks=[];i=0
    while i<len(data):
        n=int.from_bytes(data[i:i+2],'little');block=data[i+2:i+2+n]
        assert len(block)==n and n>=2
        checksum=0
        for b in block:checksum^=b
        assert checksum==0
        blocks.append((data[i:i+2+n],block));i+=n+2
    assert i==len(data)
    found=[]
    for j,(_,header) in enumerate(blocks[:-1]):
        if len(header)==19 and header[0:2]==bytes([0,0]) and header[2:12].decode('ascii').rstrip()==name:
            assert blocks[j+1][1][0]==255
            assert len(blocks[j+1][1])-2==int.from_bytes(header[12:14],'little')
            found.append(blocks[j][0]+blocks[j+1][0])
    assert found,('program not found',name)
    path.write_bytes(found[-1])
