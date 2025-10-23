10 rem basic star catcher
20 print chr$(147)
30 print "star catcher"
40 print
50 print "a/d to move, catch stars!"
60 print
70 dim fx(5),fy(5)
80 for i=1 to 5
90 fx(i)=int(rnd(1)*40):fy(i)=int(rnd(1)*10)
100 next i
110 px=20:py=23:sc=0
120 rem main loop
130 poke 1024,sc+48
140 poke 1024+(py*40)+px,32
150 get k$
160 if k$="a" and px>0 then px=px-1
170 if k$="d" and px<39 then px=px+1
180 for i=1 to 5
190 poke 1024+(fy(i)*40)+fx(i),32
200 fy(i)=fy(i)+1
210 if fy(i)>24 then fy(i)=0:fx(i)=int(rnd(1)*40)
220 if fx(i)=px and fy(i)=py then gosub 1000
230 poke 1024+(fy(i)*40)+fx(i),42
240 poke 55296+(fy(i)*40)+fx(i),3
250 next i
260 poke 1024+(py*40)+px,81
270 poke 55296+(py*40)+px,7
280 for d=1 to 15:next d
290 goto 130
1000 rem collision
1010 sc=sc+1
1020 gosub 2000
1030 fy(i)=0:fx(i)=int(rnd(1)*40)
1040 return
2000 rem coin sound
2010 poke 54296,15
2020 poke 54277,0:poke 54278,240
2030 poke 54274,0:poke 54275,8
2040 poke 54272,100:poke 54273,30
2050 poke 54276,65
2060 for t=1 to 50:next t
2070 poke 54276,64
2080 return
