10 rem joystick sprite control
20 rem load sprite data
30 for i=0 to 62
40 read b:poke 832+i,b
50 next
60 rem setup sprite 0
70 poke 2040,13:poke 53269,1:poke 53287,7
80 x=160:y=100
90 rem main loop
100 poke 53248,x:poke 53249,y
110 if x>255 then poke 53264,1 else poke 53264,0
120 j=peek(56320) and 31
130 if (j and 1)=0 and y>50 then y=y-2
140 if (j and 2)=0 and y<229 then y=y+2
150 if (j and 4)=0 and x>24 then x=x-2
160 if (j and 8)=0 and x<320 then x=x+2
170 for d=1 to 3:next d
180 goto 100
190 data 0,24,0,0,60,0,0,126,0
200 data 0,255,0,1,255,128,3,255,192
210 data 7,255,224,15,255,240,31,255,248
220 data 3,255,192,3,255,192,3,255,192
230 data 3,255,192,3,255,192,3,255,192
240 data 1,255,128,0,255,0,0,126,0
250 data 0,60,0,0,24,0,0,0,0
