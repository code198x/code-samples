10 rem smooth 8-way movement
20 rem load sprite data
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem setup sprite 0
70 poke 2040,13:poke 53269,1:poke 53287,14
80 x=160:y=120
90 rem main loop
100 j=peek(56320) and 31:dx=0:dy=0
110 if (j and 1)=0 then dy=-2
120 if (j and 2)=0 then dy=2
130 if (j and 4)=0 then dx=-2
140 if (j and 8)=0 then dx=2
150 rem update position
160 x=x+dx:y=y+dy
170 rem boundary checks
180 if x<24 then x=24
190 if x>320 then x=320
200 if y<50 then y=50
210 if y>229 then y=229
220 rem update sprite
230 poke 53248,x:poke 53249,y
240 if x>255 then poke 53264,1 else poke 53264,0
250 for d=1 to 2:next d
260 goto 100
270 data 0,24,0,0,60,0,0,126,0
280 data 0,255,0,1,255,128,3,255,192
290 data 7,255,224,15,255,240,31,255,248
300 data 3,255,192,3,255,192,3,255,192
310 data 3,255,192,3,255,192,3,255,192
320 data 1,255,128,0,255,0,0,126,0
330 data 0,60,0,0,24,0,0,0,0
