5 RANDOMIZE
10 LET secret=INT (RND*10)+1
15 LET tries=0
20 PRINT "Guess a whole number 1 to 10"
30 INPUT "Your guess ";g
31 IF g<1 THEN GO TO 100
32 IF g>10 THEN GO TO 100
33 IF g<>INT g THEN GO TO 100
35 CLS
36 LET tries=tries+1
40 IF g=secret THEN PRINT "Correct!"
50 IF g<secret THEN PRINT "Too low"
60 IF g>secret THEN PRINT "Too high"
70 IF g<>secret THEN GO TO 30
80 PRINT "Guesses: ";tries
90 STOP
100 CLS
110 PRINT "Whole number from 1 to 10"
120 GO TO 30
