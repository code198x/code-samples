10 rem lives with hearts and sprite
15 rem sprite data
16 data 0,24,0,0,60,0,0,126,0
17 data 0,255,0,1,255,128,3,255,192
18 data 7,255,224,15,255,240,31,255,248
19 data 3,255,192,3,255,192,3,255,192
20 data 3,255,192,3,255,192,3,255,192
21 data 1,255,128,0,255,0,0,126,0
22 data 0,60,0,0,24,0,0,0,0
25 rem lives label data
26 data 12,9,22,5,19
30 rem load sprite data
31 for i=0 to 62
32 read b:poke 832+i,b
33 next
60 rem setup sprite 0
70 poke 2040,13:poke 53269,1:poke 53287,14
80 x=160:y=120:li=3:sc=0
90 rem setup screen
100 print chr$(147):poke 53280,0:poke 53281,0
110 rem draw lives label
120 for i=0 to 4:read d:poke 1024+i,d:poke 55296+i,7:next
130 gosub 500
140 rem main loop
150 get k$
160 j=peek(56320) and 31:dx=0:dy=0
170 if (j and 1)=0 then dy=-2
180 if (j and 2)=0 then dy=2
190 if (j and 4)=0 then dx=-2
200 if (j and 8)=0 then dx=2
210 if k$=" " and li>0 then gosub 600
220 rem update position
230 x=x+dx:y=y+dy
240 if x<24 then x=24
250 if x>320 then x=320
260 if y<50 then y=50
270 if y>229 then y=229
280 rem update sprite
290 poke 53248,x:poke 53249,y
300 if x>255 then poke 53264,1 else poke 53264,0
310 rem update score
320 sc=sc+1:if sc>9999 then sc=0
330 gosub 700
340 for d=1 to 2:next d
350 if li>0 then 150
360 gosub 800
370 get k$:if k$="" then 370
380 end
500 rem draw hearts
510 for h=0 to 2
520 if h<li then poke 1024+6+h,83:poke 55296+6+h,2
530 if h>=li then poke 1024+6+h,32:poke 55296+6+h,0
540 next
550 return
600 rem take damage
610 if li=0 then return
620 li=li-1
630 gosub 500
640 return
700 rem display score
710 s=sc
720 for i=3 to 0 step -1
730 poke 1024+40+i,48+(s-int(s/10)*10)
740 s=int(s/10)
750 next
760 return
800 rem game over
810 for i=0 to 8:read d:poke 1104+i,d:poke 55376+i,2:next
820 data 7,1,13,5,32,15,22,5,18
830 return
