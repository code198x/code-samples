10 rem two sprites in formation
20 rem load sprite data
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem setup sprites 0 and 1
70 poke 2040,13:poke 2041,13
80 poke 53287,7:poke 53288,14
90 poke 53269,3
100 x=50:y=100
110 rem main loop
120 poke 53248,x:poke 53249,y
130 poke 53250,x+30:poke 53251,y
140 x=x+2
150 if x>220 then x=50
160 for d=1 to 50:next d
170 goto 120
180 data 0,24,0,0,60,0,0,126,0
190 data 0,255,0,1,255,128,3,255,192
200 data 7,255,224,15,255,240,31,255,248
210 data 3,255,192,3,255,192,3,255,192
220 data 3,255,192,3,255,192,3,255,192
230 data 1,255,128,0,255,0,0,126,0
240 data 0,60,0,0,24,0,0,0,0
