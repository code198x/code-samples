10 rem simple melody player
20 rem setup adsr
30 poke 54277,9:poke 54278,0
40 rem set volume
50 poke 54296,15
60 rem note data: e d c d e e e (mary had a little lamb)
70 dim f(6)
80 f(0)=5406:f(1)=4817:f(2)=4291:f(3)=4817
90 f(4)=5406:f(5)=5406:f(6)=5406
100 rem play melody
110 for n=0 to 6
120 l=f(n) and 255:h=int(f(n)/256)
130 poke 54272,l:poke 54273,h
140 poke 54276,17
150 for t=1 to 250:next
160 poke 54276,16
170 for t=1 to 50:next
180 next
