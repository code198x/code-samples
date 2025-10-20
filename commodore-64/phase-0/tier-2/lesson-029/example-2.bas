10 rem zero-padded score with sprite
15 rem sprite data
16 data 0,24,0,0,60,0,0,126,0
17 data 0,255,0,1,255,128,3,255,192
18 data 7,255,224,15,255,240,31,255,248
19 data 3,255,192,3,255,192,3,255,192
20 data 3,255,192,3,255,192,3,255,192
21 data 1,255,128,0,255,0,0,126,0
22 data 0,60,0,0,24,0,0,0,0
25 rem score label data
26 data 19,3,15,18,5
30 rem load sprite data
31 for i=0 to 62
32 read b:poke 832+i,b
33 next
60 rem setup sprite 0
70 poke 2040,13:poke 53269,1:poke 53287,14
80 x=160:y=120:sc=0
90 rem setup screen
100 print chr$(147):poke 53280,0:poke 53281,0
110 rem draw score label
120 for i=0 to 4:read d:poke 1024+i,d:poke 55296+i,7:next
140 rem main loop
150 j=peek(56320) and 31:dx=0:dy=0
160 if (j and 1)=0 then dy=-2
170 if (j and 2)=0 then dy=2
180 if (j and 4)=0 then dx=-2
190 if (j and 8)=0 then dx=2
200 rem update position
210 x=x+dx:y=y+dy
220 if x<24 then x=24
230 if x>320 then x=320
240 if y<50 then y=50
250 if y>229 then y=229
260 rem update sprite
270 poke 53248,x:poke 53249,y
280 if x>255 then poke 53264,1 else poke 53264,0
290 rem increase score
300 sc=sc+1:if sc>99999 then sc=0
310 gosub 420
320 for d=1 to 2:next d
330 goto 150
420 rem display score subroutine
430 s=sc
440 for i=4 to 0 step -1
450 poke 1024+6+i,48+(s-int(s/10)*10)
460 s=int(s/10)
470 next
480 return
