"""Read-only decoding of Sinclair BASIC numeric variables for verification."""
def number(b):
 if b[0]==0:return b[2]+256*b[3]-(65536 if b[1] else 0)
 return (-1 if b[1]&128 else 1)*(1+(((b[1]&127)<<24)+(b[2]<<16)+(b[3]<<8)+b[4])/2**31)*2**(b[0]-129)
def variables(m):
 ptr=m.call('memory_read',addr=23627,len=2)['bytes'];addr=ptr[0]+256*ptr[1];b=[]
 for offset in range(0,1024,128):b+=m.call('memory_read',addr=addr+offset,len=128)['bytes']
 i=0;out={}
 while b[i]!=128:
  tag=b[i]>>5;name=chr((b[i]&31)+96);i+=1
  if tag in [2,4,6]:size=b[i]+256*b[i+1];i+=2+size
  elif tag in [3,5,7]:
   if tag==5:
    while True:
     ch=b[i];i+=1;name+=chr(ch&127)
     if ch&128:break
   out[name]=number(b[i:i+5]);i+=5
   if tag==7:i+=13
  else:raise AssertionError(('unknown variable',tag,i,b[i:i+12]))
 return out
