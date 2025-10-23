10 rem complete game
20 x=rnd(-ti)
30 print chr$(147);"guess the number"
40 print
50 print "best score:";b
60 print
70 n=int(rnd(1)*100)+1
80 t=0
90 print "i'm thinking of 1-100"
100 print
110 input "guess";g
120 t=t+1
130 if g=n then print "yes! in";t;"tries":goto 160
140 if g<n then print "higher!":goto 110
150 if g>n then print "lower!":goto 110
160 if b=0 or t<b then b=t:print "new record!"
170 print
180 print "play again? (y/n)"
190 get k$:if k$="" then 190
200 if k$="y" then 30
210 print chr$(147);"final score:";b
220 print "thanks for playing!"
