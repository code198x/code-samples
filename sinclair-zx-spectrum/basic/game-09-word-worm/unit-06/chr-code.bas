10 CLS
20 PRINT "CHR$ and CODE"
30 PRINT
40 PRINT "Characters are numbers."
50 PRINT "CODE gives a letter's number."
60 PRINT "CHR$ gives a number's letter."
70 PRINT
80 PRINT "Letter  Code"
90 PRINT "------  ----"
100 FOR i = 97 TO 122
110 PRINT CHR$ i; "       "; i
120 NEXT i
130 PRINT
140 PRINT "Press a key to see its code."
150 LET k$ = INKEY$
160 IF k$ = "" THEN GO TO 150
170 PRINT AT 20, 0; "Key: "; k$; "  Code: "; CODE k$; "  "
180 GO TO 150
