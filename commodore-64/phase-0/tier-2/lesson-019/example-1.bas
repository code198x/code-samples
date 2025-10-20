10 rem move sprite horizontally
20 rem load sprite data
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem enable sprite
70 poke 2040,13:poke 53287,7:poke 53269,1
80 x=50:y=120
90 rem main loop
100 poke 53248,x:poke 53249,y
110 x=x+2
120 if x>255 then x=50
130 for d=1 to 50:next d
140 goto 100
150 data 0,24,0,0,60,0,0,126,0
160 data 0,255,0,1,255,128,3,255,192
170 data 7,255,224,15,255,240,31,255,248
180 data 3,255,192,3,255,192,3,255,192
190 data 3,255,192,3,255,192,3,255,192
200 data 1,255,128,0,255,0,0,126,0
210 data 0,60,0,0,24,0,0,0,0
