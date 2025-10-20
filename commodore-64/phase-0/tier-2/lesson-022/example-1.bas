10 rem sprite frame cycling
20 rem load 2 animation frames
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 for i=0 to 62
70 read b:poke 896+i,b
80 next
90 rem setup sprite
100 poke 53287,7:poke 53269,1
110 x=150:y=120:f=0
120 poke 53248,x:poke 53249,y
130 rem main loop
140 f=1-f
150 poke 2040,13+f
160 for d=1 to 30:next d
170 goto 140
180 rem frame 0 - circle
190 data 0,0,0,0,126,0,1,255,128
200 data 3,255,192,7,255,224,7,255,224
210 data 15,255,240,15,255,240,15,255,240
220 data 7,255,224,7,255,224,3,255,192
230 data 1,255,128,0,126,0,0,0,0
240 data 0,0,0,0,0,0,0,0,0
250 data 0,0,0,0,0,0,0,0,0
260 rem frame 1 - diamond
270 data 0,0,0,0,24,0,0,60,0
280 data 0,126,0,1,255,128,3,255,192
290 data 7,255,224,15,255,240,15,255,240
300 data 7,255,224,3,255,192,1,255,128
310 data 0,126,0,0,60,0,0,24,0
320 data 0,0,0,0,0,0,0,0,0
330 data 0,0,0,0,0,0,0,0,0
