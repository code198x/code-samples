10 rem spaceship sprite
20 rem read sprite data from data statements
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem position and enable sprite
70 poke 53248,160:poke 53249,120
80 poke 2040,13
90 poke 53287,1:rem white
100 poke 53269,1
110 get a$:if a$="" then 110
120 data 0,0,0,0,56,0,0,124,0
130 data 0,214,0,1,255,128,1,255,128
140 data 3,255,192,3,255,192,7,255,224
150 data 7,255,224,15,255,240,31,255,248
160 data 63,255,252,127,255,254,127,255,254
170 data 63,231,252,31,195,248,7,0,224
180 data 3,0,192,1,129,128,0,195,0
190 data 0,126,0,0,60,0,0,0,0
