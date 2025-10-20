10 rem four sprites with msb
20 rem load sprite data
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem setup 4 sprites
70 for s=0 to 3
80 poke 2040+s,13
90 poke 53287+s,s+2
100 next
110 poke 53269,15
120 x0=50:y0=100:vx0=2:vy0=1
125 x1=100:y1=120:vx1=2:vy1=1
127 x2=150:y2=140:vx2=2:vy2=-1
129 x3=200:y3=160:vx3=2:vy3=-1
170 rem main loop
180 x0=x0+vx0:y0=y0+vy0
190 if x0<24 or x0>320 then vx0=-vx0:x0=x0+vx0
200 if y0<50 or y0>230 then vy0=-vy0:y0=y0+vy0
210 x1=x1+vx1:y1=y1+vy1
220 if x1<24 or x1>320 then vx1=-vx1:x1=x1+vx1
230 if y1<50 or y1>230 then vy1=-vy1:y1=y1+vy1
240 x2=x2+vx2:y2=y2+vy2
250 if x2<24 or x2>320 then vx2=-vx2:x2=x2+vx2
260 if y2<50 or y2>230 then vy2=-vy2:y2=y2+vy2
270 x3=x3+vx3:y3=y3+vy3
280 if x3<24 or x3>320 then vx3=-vx3:x3=x3+vx3
290 if y3<50 or y3>230 then vy3=-vy3:y3=y3+vy3
300 rem update positions with msb
310 m=0
320 if x0>255 then m=m+1:poke 53248,x0-256:goto 325
322 poke 53248,x0
325 if x1>255 then m=m+2:poke 53250,x1-256:goto 330
327 poke 53250,x1
330 if x2>255 then m=m+4:poke 53252,x2-256:goto 335
332 poke 53252,x2
335 if x3>255 then m=m+8:poke 53254,x3-256:goto 340
337 poke 53254,x3
340 poke 53264,m
350 poke 53249,y0:poke 53251,y1
360 poke 53253,y2:poke 53255,y3
390 for d=1 to 20:next d
400 goto 180
410 data 0,24,0,0,60,0,0,126,0
420 data 0,255,0,1,255,128,3,255,192
430 data 7,255,224,15,255,240,31,255,248
440 data 3,255,192,3,255,192,3,255,192
450 data 3,255,192,3,255,192,3,255,192
460 data 1,255,128,0,255,0,0,126,0
470 data 0,60,0,0,24,0,0,0,0
