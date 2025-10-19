10 rem random stars appearing
20 print chr$(147)
30 poke 53280,0:poke 53281,0
40 for i=1 to 50
50 x=int(rnd(1)*40)
60 y=int(rnd(1)*25)
70 poke 1024+y*40+x,42
80 poke 55296+y*40+x,1
90 for d=1 to 20:next d
100 next i
