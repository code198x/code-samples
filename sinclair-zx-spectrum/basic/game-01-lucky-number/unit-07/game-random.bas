10 REM Lucky Number
20 LET n = INT (RND * 100) + 1
30 INPUT "Guess (1-100): "; g
40 IF g = n THEN PRINT "Correct!"
50 IF g = n THEN STOP
60 IF g < n THEN PRINT "Too low!"
70 IF g > n THEN PRINT "Too high!"
80 GO TO 30
