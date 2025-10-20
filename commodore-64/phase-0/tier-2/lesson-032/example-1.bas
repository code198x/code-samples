10 rem tier 2 capstone - sprite game
20 rem state: 0=title, 1=play, 2=gameover
30 gs=0:sc=0:hi=0:li=0
40 px=160:py=200:ex=50:ey=60:ev=1
50 rem load sprite data
60 for i=0 to 125:read b:poke 832+i,b:next
70 rem setup sprite pointers and colors
80 poke 2040,13:poke 2041,14:poke 2042,14
90 poke 53287,14:poke 53288,2:poke 53289,2
100 rem setup sid
110 poke 54277,9:poke 54278,0
120 poke 54296,15
130 rem main game loop
140 on gs+1 gosub 200,400,700
150 goto 140
200 rem title state
210 poke 53269,0
220 print chr$(147)
230 poke 53280,6:poke 53281,6
240 for i=0 to 15:read d:poke 1124+i,d:poke 55396+i,14:next
250 for i=1 to 100:next i
260 get k$:if k$<>"" then gs=1:li=3:sc=0:px=160:py=200:restore
270 return
400 rem play state
410 if sc=0 then print chr$(147):poke 53280,0:poke 53281,0:gosub 900:gosub 800:poke 53269,3
420 rem read joystick
430 j=peek(56320) and 31:dx=0:dy=0
440 if (j and 1)=0 then dy=-2
450 if (j and 2)=0 then dy=2
460 if (j and 4)=0 then dx=-2
470 if (j and 8)=0 then dx=2
480 px=px+dx:py=py+dy
490 if px<24 then px=24
500 if px>300 then px=300
510 if py<50 then py=50
520 if py>229 then py=229
530 poke 53248,px:poke 53249,py
540 rem update enemy
550 ex=ex+ev:if ex<24 or ex>300 then ev=-ev:ex=ex+ev
560 poke 53250,ex:poke 53251,ey
570 rem collision check
580 c=peek(53279):if c>0 then gosub 1000
590 rem update score
600 sc=sc+1:if sc>9999 then sc=0
610 gosub 850
620 if li=0 then gs=2:restore
630 for d=1 to 2:next d
640 return
700 rem game over state
710 poke 53269,0
720 poke 53280,2:poke 53281,2
730 for i=0 to 8:read d:poke 1144+i,d:poke 55416+i,7:next
740 if sc>hi then hi=sc
750 for i=1 to 200:next i
760 gs=0:restore
770 return
800 rem draw lives
810 for h=0 to 2
820 if h<li then poke 1024+6+h,83:poke 55296+6+h,2
830 if h>=li then poke 1024+6+h,32:poke 55296+6+h,0
840 next:return
850 rem display score
860 s=sc
870 for i=3 to 0 step -1
880 poke 1024+40+i,48+(s-int(s/10)*10)
890 s=int(s/10):next:return
900 rem draw labels (skip sprite data)
910 for i=0 to 125:read d:next
920 for i=0 to 4:read d:poke 1024+i,d:poke 55296+i,10:next
930 for i=0 to 4:read d:poke 1024+32+i,d:poke 55328+i,10:next
940 return
1000 rem collision damage
1010 rem play sound effect
1020 poke 54272,200:poke 54273,12
1030 poke 54276,17
1040 for t=1 to 10:next
1050 poke 54276,16
1060 li=li-1:gosub 800
1070 return
1100 rem player sprite data
1110 data 0,24,0,0,60,0,0,126,0
1120 data 0,255,0,1,255,128,3,255,192
1130 data 7,255,224,15,255,240,31,255,248
1140 data 3,255,192,3,255,192,3,255,192
1150 data 3,255,192,3,255,192,3,255,192
1160 data 1,255,128,0,255,0,0,126,0
1170 data 0,60,0,0,24,0,0,0,0
1180 rem enemy sprite data
1190 data 3,192,3,7,224,7,15,240,15
1200 data 31,248,31,63,252,63,127,254,127
1210 data 255,255,255,255,255,255,127,254,127
1220 data 63,252,63,31,248,31,15,240,15
1230 data 7,224,7,3,192,3,1,128,1
1240 data 0,0,0,0,0,0,0,0,0
1250 rem label data
1260 data 12,9,22,5,19
1270 data 19,3,15,18,5
1280 rem title text
1290 data 20,9,5,18,32,2,32,7,1,13,5
1300 data 16,18,5,19,19,32,6,9,18,5
1310 rem gameover text
1320 data 7,1,13,5,32,15,22,5,18
