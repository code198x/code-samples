10 rem screen pattern
20 print chr$(147)
30 for i=0 to 999
40 c=int(rnd(1)*4)
50 if c=0 then p=160
60 if c=1 then p=109
70 if c=2 then p=124
80 if c=3 then p=126
90 poke 1024+i,p
100 next i
