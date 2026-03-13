10 CLS
20 LET w$ = "SPECTRUM"
30 PRINT "Full word: "; w$
40 PRINT "First letter: "; w$(1)
50 PRINT "Last letter: "; w$(LEN w$)
60 PRINT "First three: "; w$(1 TO 3)
70 PRINT "Middle: "; w$(3 TO 6)
80 PRINT "Without first: "; w$(2 TO LEN w$)
90 PRINT "Without last: "; w$(1 TO LEN w$ - 1)
