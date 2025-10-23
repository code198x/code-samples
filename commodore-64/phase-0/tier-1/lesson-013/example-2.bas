10 rem stars with player
20 print chr$(147)
30 print "catch the stars!"
40 print
50 print "wasd to move"
60 print
70 dim fx(8),fy(8)
80 for i=1 to 8
90 fx(i)=int(rnd(1)*40):fy(i)=int(rnd(1)*15)
100 next i
110 px=20:py=22:pc=81
120 poke 1024+(py*40)+px,pc
130 poke 55296+(py*40)+px,7
140 rem main loop
150 for i=1 to 8
160 poke 1024+(fy(i)*40)+fx(i),32
170 fy(i)=fy(i)+1
180 if fy(i)>24 then fy(i)=0:fx(i)=int(rnd(1)*40)
190 poke 1024+(fy(i)*40)+fx(i),42
200 poke 55296+(fy(i)*40)+fx(i),3
210 next i
220 poke 1024+(py*40)+px,32
230 get k$
240 if k$="w" and py>6 then py=py-1
250 if k$="s" and py<24 then py=py+1
260 if k$="a" and px>0 then px=px-1
270 if k$="d" and px<39 then px=px+1
280 poke 1024+(py*40)+px,pc
290 poke 55296+(py*40)+px,7
300 for d=1 to 15:next d
310 goto 150
