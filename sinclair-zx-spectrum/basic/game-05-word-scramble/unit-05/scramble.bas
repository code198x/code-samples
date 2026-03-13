10 CLS
20 LET w$ = "SPECTRUM"
30 LET t$ = w$
40 LET s$ = ""
50 REM === scramble loop ===
60 IF LEN t$ = 0 THEN GO TO 110
70 LET p = INT (RND * LEN t$) + 1
80 LET s$ = s$ + t$(p)
90 LET t$ = t$(1 TO p - 1) + t$(p + 1 TO LEN t$)
100 GO TO 60
110 PRINT "Word: "; w$
120 PRINT "Scrambled: "; s$
