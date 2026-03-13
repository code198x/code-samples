10 CLS
20 LET n = 0
30 FOR i = 1 TO 5
40 READ w$
50 LET t$ = w$
60 LET s$ = ""
70 IF LEN t$ = 0 THEN GO TO 110
80 LET p = INT (RND * LEN t$) + 1
90 LET s$ = s$ + t$(p)
100 LET t$ = t$(1 TO p - 1) + t$(p + 1 TO LEN t$)
105 GO TO 70
110 PRINT "Round "; i
120 PRINT "Unscramble: "; s$
130 INPUT "Your guess? "; g$
140 IF g$ = w$ THEN PRINT "Correct!": LET n = n + 1
150 IF g$ <> w$ THEN PRINT "Wrong! It was "; w$
160 PRINT
170 NEXT i
180 PRINT "Score: "; n; " out of 5"
200 DATA "CAT","DOG","SUN","RED","CUP"
