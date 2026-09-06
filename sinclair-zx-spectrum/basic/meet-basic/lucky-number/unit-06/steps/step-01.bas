10 LET secret=7
20 PRINT "Guess a whole number 1 to 10"
30 INPUT "Your guess ";g
35 CLS
40 IF g=secret THEN PRINT "Correct!"
50 IF g<secret THEN PRINT "Too low"
60 IF g>secret THEN PRINT "Too high"
70 IF g<>secret THEN GO TO 30
