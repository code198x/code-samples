10 CLS
20 LET w$ = "HELLO"
30 PRINT "The word is: "; w$
40 INPUT "Your guess? "; g$
50 IF g$ = w$ THEN PRINT "Correct!"
60 IF g$ <> w$ THEN PRINT "Wrong! It was "; w$
