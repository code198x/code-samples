10 rem sprite vs background collision
20 rem load sprite data
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem draw background wall
70 print chr$(147)
80 for i=0 to 21
90 poke 1024+40+i,160
100 poke 55296+40+i,1
110 next
120 rem setup sprite
130 poke 2040,13:poke 53287,7:poke 53269,1
140 x=50:y=50:vx=2:vy=1
150 rem main loop
160 x=x+vx:y=y+vy
170 if x<24 or x>255 then vx=-vx:x=x+vx
180 if y<50 or y>230 then vy=-vy:y=y+vy
190 poke 53248,x:poke 53249,y
200 c=peek(53279)
210 if c>0 then vx=-vx:vy=-vy:x=x+vx*2:y=y+vy*2
220 for d=1 to 30:next d
230 goto 160
240 data 0,24,0,0,60,0,0,126,0
250 data 0,255,0,1,255,128,3,255,192
260 data 7,255,224,15,255,240,31,255,248
270 data 3,255,192,3,255,192,3,255,192
280 data 3,255,192,3,255,192,3,255,192
290 data 1,255,128,0,255,0,0,126,0
300 data 0,60,0,0,24,0,0,0,0
