10 rem music with duration and rests
20 rem setup adsr
30 poke 54277,9:poke 54278,0
40 rem set volume
50 poke 54296,15
60 rem note data: twinkle twinkle (c c g g a a g - f f e e d d c)
70 dim f(14),d(14)
80 f(0)=4291:f(1)=4291:f(2)=6430:f(3)=6430
90 f(4)=7217:f(5)=7217:f(6)=6430:f(7)=0
100 f(8)=5729:f(9)=5729:f(10)=5406:f(11)=5406
110 f(12)=4817:f(13)=4817:f(14)=4291
120 d(0)=250:d(1)=250:d(2)=250:d(3)=250
130 d(4)=250:d(5)=250:d(6)=500:d(7)=125
140 d(8)=250:d(9)=250:d(10)=250:d(11)=250
150 d(12)=250:d(13)=250:d(14)=500
160 rem play melody
170 for n=0 to 14
180 if f(n)=0 then 230
190 l=f(n) and 255:h=int(f(n)/256)
200 poke 54272,l:poke 54273,h
210 poke 54276,17
220 for t=1 to d(n):next
230 poke 54276,16
240 for t=1 to 50:next
250 next
