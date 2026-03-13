10 CLS
20 LET a$ = "SPEC"
30 LET b$ = "TRUM"
40 LET c$ = a$ + b$
50 PRINT a$; " + "; b$; " = "; c$
60 PRINT
70 LET d$ = ""
80 LET w$ = "HELLO"
90 FOR i = LEN w$ TO 1 STEP -1
100 LET d$ = d$ + w$(i)
110 NEXT i
120 PRINT w$; " reversed is "; d$
