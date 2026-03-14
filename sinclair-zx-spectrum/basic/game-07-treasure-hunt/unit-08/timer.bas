10 CLS
20 PRINT "Timer demo"
30 PRINT
40 PRINT "The Spectrum counts time in"
50 PRINT "50ths of a second at address"
60 PRINT "23672 (low) and 23673 (high)."
70 PRINT
80 PRINT "Press a key to start timing..."
90 IF INKEY$ = "" THEN GO TO 90
100 LET t = PEEK 23672 + 256 * PEEK 23673
110 PRINT
120 PRINT "Timing... press a key to stop"
130 IF INKEY$ <> "" THEN GO TO 130
140 IF INKEY$ = "" THEN GO TO 140
150 LET e = PEEK 23672 + 256 * PEEK 23673
160 LET d = (e - t) / 50
170 PRINT
180 PRINT "Elapsed: "; d; " seconds"
