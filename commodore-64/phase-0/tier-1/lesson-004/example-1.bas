10 rem simple quiz
20 print chr$(147);"quiz master"
30 print
40 print "what is 2+2?"
50 input a
60 if a=4 then print "correct!":s=s+1
70 if a<>4 then print "wrong! it's 4"
80 print
90 print "what is 5*3?"
100 input a
110 if a=15 then print "correct!":s=s+1
120 if a<>15 then print "wrong! it's 15"
130 print
140 print "what is 10-3?"
150 input a
160 if a=7 then print "correct!":s=s+1
170 if a<>7 then print "wrong! it's 7"
180 print
190 print "score:";s;"out of 3"
