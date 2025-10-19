10 rem score and win condition
20 print chr$(147)
30 sc=0:wi=10
40 print "collect 10 items!"
50 print:print "score:";sc
60 print "press space to collect"
70 get a$:if a$="" then 70
80 if a$=" " then sc=sc+1
90 print chr$(147)
100 print "score:";sc
110 if sc>=wi then print:print "you win!":end
120 goto 60
