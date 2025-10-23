10 rem simple guess
20 print chr$(147);"guess my number"
30 print
40 n=int(rnd(1)*10)+1
50 print "i'm thinking of 1-10"
60 print
70 input "your guess";g
80 if g=n then print "you got it!":end
90 if g<n then print "too low!":goto 70
100 if g>n then print "too high!":goto 70
