  10 CLS
  20 DATA "SPECTRUM"
  30 READ w$
  40 LET d$ = ""
  50 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
  60 LET lives = 7
  70 CLS
  80 FOR i = 1 TO LEN d$: PRINT d$(i); " ";: NEXT i
  90 PRINT : PRINT
 100 PRINT "Lives: "; lives
 110 PRINT
 120 INPUT "Guess a letter: "; g$
 130 LET found = 0
 140 FOR i = 1 TO LEN w$
 150 IF w$(i) = g$ THEN LET d$(i TO i) = g$: LET found = 1
 160 NEXT i
 170 IF found = 0 THEN LET lives = lives - 1: BEEP 0.1, -5
 180 IF found = 1 THEN BEEP 0.1, 10
 190 IF d$ = w$ THEN CLS: PRINT "You got it! The word was "; w$: STOP
 200 IF lives = 0 THEN CLS: PRINT "Out of lives! The word was "; w$: STOP
 210 GO TO 70
