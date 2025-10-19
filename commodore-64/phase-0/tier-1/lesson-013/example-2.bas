10 rem scaling random ranges
20 print chr$(147)
30 print "rolling dice (1-6):"
40 print
50 for i=1 to 10
60 d=int(rnd(1)*6)+1
70 print "roll ";i;": ";d
80 next i
