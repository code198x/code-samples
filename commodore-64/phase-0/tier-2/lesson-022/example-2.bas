10 rem animated walking character
20 rem load 2 animation frames
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 for i=0 to 62
70 read b:poke 896+i,b
80 next
90 rem setup sprite
100 poke 53287,7:poke 53269,1
110 x=50:y=120:vx=1:f=0
120 poke 53248,x:poke 53249,y
130 t=ti
140 rem main loop
150 x=x+vx
160 if x>255 then x=50
170 poke 53248,x
180 if ti-t<5 then goto 180
190 t=ti
200 f=1-f
210 poke 2040,13+f
220 goto 150
230 rem frame 0 - left leg forward
240 data 0,24,0,0,60,0,0,126,0
250 data 0,255,0,1,255,128,3,255,192
260 data 7,255,224,15,255,240,31,255,248
270 data 3,255,192,3,255,192,3,255,192
280 data 1,255,192,0,255,192,0,126,192
290 data 0,60,128,0,24,0,0,0,0
300 data 0,0,0,0,0,0,0,0,0
310 rem frame 1 - right leg forward
320 data 0,24,0,0,60,0,0,126,0
330 data 0,255,0,1,255,128,3,255,192
340 data 7,255,224,15,255,240,31,255,248
350 data 3,255,192,3,255,192,3,255,192
360 data 3,255,128,3,255,0,3,126,0
370 data 1,60,0,0,24,0,0,0,0
380 data 0,0,0,0,0,0,0,0,0
