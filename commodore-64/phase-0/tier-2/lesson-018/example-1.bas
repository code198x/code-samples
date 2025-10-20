10 rem simple arrow sprite
20 rem read sprite data from data statements
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem position and enable sprite
70 poke 53248,160:poke 53249,120
80 poke 2040,13
90 poke 53287,14:rem light blue
100 poke 53269,1
110 get a$:if a$="" then 110
120 data 0,24,0,0,60,0,0,126,0
130 data 0,255,0,1,255,128,3,255,192
140 data 7,255,224,15,255,240,31,255,248
150 data 3,255,192,3,255,192,3,255,192
160 data 3,255,192,3,255,192,3,255,192
170 data 1,255,128,0,255,0,0,126,0
180 data 0,60,0,0,24,0,0,0,0
