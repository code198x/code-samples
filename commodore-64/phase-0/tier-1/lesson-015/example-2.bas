10 rem spawn timer with delay
20 print chr$(147):poke 53280,0:poke 53281,0
30 ti$="000000"
40 la=0
50 x=int(rnd(1)*40):y=int(rnd(1)*25)
60 poke 1024+y*40+x,42:poke 55296+y*40+x,7
70 if ti-la<60 then 70
80 la=ti
90 goto 50
