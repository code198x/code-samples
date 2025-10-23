10 rem falling stars
20 print chr$(147)
30 print "falling stars demo"
40 print
50 dim fx(5),fy(5)
60 for i=1 to 5
70 fx(i)=int(rnd(1)*40):fy(i)=int(rnd(1)*10)
80 next i
90 rem main loop
100 for i=1 to 5
110 poke 1024+(fy(i)*40)+fx(i),32
120 fy(i)=fy(i)+1
130 if fy(i)>24 then fy(i)=0:fx(i)=int(rnd(1)*40)
140 poke 1024+(fy(i)*40)+fx(i),42
150 next i
160 for d=1 to 20:next d
170 goto 100
