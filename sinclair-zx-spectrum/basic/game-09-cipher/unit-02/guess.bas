  10 CLS
  20 DATA "SPECTRUM"
  30 READ w$
  40 LET d$ = ""
  50 FOR i = 1 TO LEN w$
  60 LET d$ = d$ + "_"
  70 NEXT i
  80 FOR i = 1 TO LEN d$
  90 PRINT d$(i); " ";
 100 NEXT i
 110 PRINT
 120 PRINT
 130 INPUT "Guess a letter: "; g$
 140 LET found = 0
 150 FOR i = 1 TO LEN w$
 160 IF w$(i) = g$ THEN LET d$(i TO i) = g$: LET found = 1
 170 NEXT i
 180 CLS
 190 FOR i = 1 TO LEN d$
 200 PRINT d$(i); " ";
 210 NEXT i
 220 PRINT
 230 PRINT
 240 IF found = 1 THEN PRINT "Yes! "; g$; " is in the word."
 250 IF found = 0 THEN PRINT "No, "; g$; " is not in the word."
