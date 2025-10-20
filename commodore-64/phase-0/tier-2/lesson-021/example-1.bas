10 rem sprite collision detection
20 rem load sprite data
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem setup two sprites
70 poke 2040,13:poke 2041,13
80 poke 53287,7:poke 53288,2
90 poke 53269,3
100 x0=50:y0=120:x1=250:y1=120
110 vx0=2:vx1=-2
120 rem main loop
130 x0=x0+vx0:x1=x1+vx1
140 if x0<24 or x0>255 then vx0=-vx0:x0=x0+vx0
150 if x1<24 or x1>255 then vx1=-vx1:x1=x1+vx1
160 poke 53248,x0:poke 53249,y0
170 poke 53250,x1:poke 53251,y1
180 c=peek(53278)
190 if c>0 then poke 53280,c:goto 210
200 poke 53280,6
210 for d=1 to 30:next d
220 goto 130
230 data 0,24,0,0,60,0,0,126,0
240 data 0,255,0,1,255,128,3,255,192
250 data 7,255,224,15,255,240,31,255,248
260 data 3,255,192,3,255,192,3,255,192
270 data 3,255,192,3,255,192,3,255,192
280 data 1,255,128,0,255,0,0,126,0
290 data 0,60,0,0,24,0,0,0,0
