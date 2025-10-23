10 print chr$(147);"test"
20 n=5
30 input "guess";g
40 if g=n then print "correct!":end
50 if g<n then print "low!":goto 30
60 if g>n then print "high!":goto 30
