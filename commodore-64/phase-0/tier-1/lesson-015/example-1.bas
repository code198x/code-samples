10 rem countdown timer
20 print chr$(147)
30 print "countdown timer demo"
40 print
50 tl=30
60 t1=ti
70 rem main loop
80 e=int((ti-t1)/60)
90 r=tl-e
100 poke 1024,32
110 print chr$(19);
120 print "time left:";r;" seconds"
130 if r<=0 then 200
140 if r<=10 then poke 53280,2
150 goto 80
200 rem time up
210 print chr$(147)
220 print "time's up!"
230 end
