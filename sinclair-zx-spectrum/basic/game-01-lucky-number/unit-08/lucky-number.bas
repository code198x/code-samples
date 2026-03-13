10 REM Lucky Number
20 PRINT "== Lucky Number =="
30 PRINT
40 LET n = INT (RND * 100) + 1
50 LET c = 0
60 INPUT "Guess (1-100): "; g
70 LET c = c + 1
80 IF g = n THEN GO TO 120
90 IF g < n THEN PRINT "Too low!"
100 IF g > n THEN PRINT "Too high!"
110 GO TO 60
120 PRINT "Correct!"
130 PRINT "You got it in "; c; " guesses."
