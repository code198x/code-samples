10 rem star catcher complete
20 print chr$(147)
30 print "   star catcher"
40 print
50 print "catch 20 cyan stars"
60 print "avoid red asteroids"
70 print
80 print "a/d to move"
90 print
100 print "press any key"
110 get k$:if k$="" then 110
120 print chr$(147)
130 dim fx(8),fy(8),ft(8)
140 for i=1 to 8
150 fx(i)=int(rnd(1)*40):fy(i)=int(rnd(1)*12)
160 ft(i)=int(rnd(1)*3)
170 next i
180 px=20:py=23:sc=0:lv=3
190 rem main loop
200 poke 1024,sc+48
210 poke 1030,lv+48
220 poke 1024+(py*40)+px,32
230 get k$
240 if k$="a" and px>0 then px=px-1
250 if k$="d" and px<39 then px=px+1
260 for i=1 to 8
270 poke 1024+(fy(i)*40)+fx(i),32
280 fy(i)=fy(i)+1
290 if fy(i)>24 then fy(i)=0:fx(i)=int(rnd(1)*40):ft(i)=int(rnd(1)*3)
300 if fx(i)=px and fy(i)=py then gosub 1000
310 if ft(i)=0 then c=42:cl=3
320 if ft(i)=1 or ft(i)=2 then c=90:cl=2
330 poke 1024+(fy(i)*40)+fx(i),c
340 poke 55296+(fy(i)*40)+fx(i),cl
350 next i
360 poke 1024+(py*40)+px,81
370 poke 55296+(py*40)+px,7
380 if lv=0 then 500
390 if sc>=20 then 600
400 for d=1 to 12:next d
410 goto 200
500 rem game over
510 poke 1024+240,71:poke 1024+241,65
520 poke 1024+242,77:poke 1024+243,69
530 poke 1024+245,79:poke 1024+246,86
540 poke 1024+247,69:poke 1024+248,82
550 for d=1 to 500:next d
560 end
600 rem you win
610 poke 1024+240,89:poke 1024+241,79
620 poke 1024+242,85:poke 1024+244,87
630 poke 1024+245,73:poke 1024+246,78
640 for d=1 to 500:next d
650 end
1000 rem collision
1010 if ft(i)=0 then sc=sc+1:gosub 2000
1020 if ft(i)>0 then lv=lv-1:gosub 3000
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
3000 rem explosion sound
3010 poke 54296,15
3020 poke 54277,0:poke 54278,240
3030 poke 54272,255:poke 54273,255
3040 poke 54276,129
3050 for t=1 to 50:next t
3060 poke 54276,128
3070 return
