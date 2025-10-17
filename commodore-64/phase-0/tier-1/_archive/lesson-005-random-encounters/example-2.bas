10 x=rnd(-ti)
20 sc=0
30 for i=1 to 5
40 print "opening chest ";i;"..."
50 g=int(rnd(1)*20)+1
60 print "you find ";g;" gold!"
70 sc=sc+g
80 if rnd(1)<0.3 then print "a trap! lose 5 gold!": sc=sc-5
90 next i
100 print "total score: ";sc
110 end
