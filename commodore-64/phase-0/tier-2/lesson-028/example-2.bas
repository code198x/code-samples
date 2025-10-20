10 rem diagonal speed normalization
20 rem load sprite data
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem setup sprite 0
70 poke 2040,13:poke 53269,1:poke 53287,7
80 x=160:y=120:sp=2
90 rem main loop
100 j=peek(56320) and 31:dx=0:dy=0
110 if (j and 1)=0 then dy=-1
120 if (j and 2)=0 then dy=1
130 if (j and 4)=0 then dx=-1
140 if (j and 8)=0 then dx=1
150 rem check if moving diagonally
160 if dx<>0 and dy<>0 then s=1 else s=sp
170 rem update position
180 x=x+dx*s:y=y+dy*s
190 rem boundary checks
200 if x<24 then x=24
210 if x>320 then x=320
220 if y<50 then y=50
230 if y>229 then y=229
240 rem update sprite
250 poke 53248,x:poke 53249,y
260 if x>255 then poke 53264,1 else poke 53264,0
270 for d=1 to 2:next d
280 goto 100
290 data 0,24,0,0,60,0,0,126,0
300 data 0,255,0,1,255,128,3,255,192
310 data 7,255,224,15,255,240,31,255,248
320 data 3,255,192,3,255,192,3,255,192
330 data 3,255,192,3,255,192,3,255,192
340 data 1,255,128,0,255,0,0,126,0
350 data 0,60,0,0,24,0,0,0,0
