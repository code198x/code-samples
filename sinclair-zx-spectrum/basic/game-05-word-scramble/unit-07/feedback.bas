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
120 PRINT "Unscramble: ";
130 INK 6: PRINT s$: INK 0
140 INPUT "Your guess? "; g$
150 IF g$ = w$ THEN INK 4: PRINT "Correct!": INK 0: BEEP 0.2, 12: LET n = n + 1
160 IF g$ <> w$ THEN INK 2: PRINT "Wrong! It was "; w$: INK 0: BEEP 0.3, -5
170 PRINT
180 NEXT i
190 PRINT
200 PRINT "Score: "; n; " out of 5"
300 DATA "CAT","DOG","SUN","RED","CUP"
