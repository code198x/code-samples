"""Read-only BASIC variables and current line; extended for the larger map."""
def number(b):
 if b[0]==0:return b[2]+256*b[3]-(65536 if b[1] else 0)
 return (-1 if b[1]&128 else 1)*(1+(((b[1]&127)<<24)+(b[2]<<16)+(b[3]<<8)+b[4])/2**31)*2**(b[0]-129)
def state(m):
 ptr=m.call('memory_read',addr=23627,len=2)['bytes'];addr=ptr[0]+256*ptr[1];data=[]
 for offset in range(0,8192,128):data+=m.call('memory_read',addr=addr+offset,len=128)['bytes']
 i=0;out={}
 while data[i]!=128:
  tag=data[i]>>5;name=chr((data[i]&31)+96);i+=1
  if tag in [2,4,6]:
   size=data[i]+256*data[i+1];i+=2
   if tag==4:
    dims=data[i];j=i+1+2*dims
    out[name]=[int(number(data[k:k+5])) for k in range(j,i+size,5)]
   elif tag==2:out[name+'$']=''.join(map(chr,data[i:i+size]))
   elif tag==6 and data[i]==1:out[name+'$']=''.join(map(chr,data[i+3:i+size]))
   i+=size
  elif tag in [3,5,7]:
   if tag==5:
    while True:
     ch=data[i];i+=1;name+=chr(ch&127)
     if ch&128:break
   out[name]=number(data[i:i+5]);i+=5
   if tag==7:i+=13
  else:
   raise AssertionError((tag,i,{k:len(v) if isinstance(v,list) else v for k,v in out.items()}))
 return out

def line(m):
 b=m.call('memory_read',addr=23621,len=2)['bytes'];return b[0]+256*b[1]
