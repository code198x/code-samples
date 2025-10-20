10 rem sprite across full screen width
20 rem load sprite data
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem enable sprite
70 poke 2040,13:poke 53287,14:poke 53269,1
80 x=0:y=120
90 rem main loop
100 if x<256 then poke 53264,0:poke 53248,x
110 if x>=256 then poke 53264,1:poke 53248,x-256
120 poke 53249,y
130 x=x+2
140 if x>340 then x=0
150 for d=1 to 50:next d
160 goto 100
170 data 0,0,0,0,56,0,0,124,0
180 data 0,214,0,1,255,128,1,255,128
190 data 3,255,192,3,255,192,7,255,224
200 data 7,255,224,15,255,240,31,255,248
210 data 63,255,252,127,255,254,127,255,254
220 data 63,231,252,31,195,248,7,0,224
230 data 3,0,192,1,129,128,0,195,0
240 data 0,126,0,0,60,0,0,0,0
