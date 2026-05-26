  10 CLS
  20 DATA "SPECTRUM"
  30 READ w$
  40 LET d$ = ""
  50 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
  60 LET lives = 7
  70 LET tried$ = ""
  80 CLS
  90 FOR i = 1 TO LEN d$: PRINT d$(i); " ";: NEXT i
 100 PRINT : PRINT
 110 PRINT "Lives: "; lives
 120 PRINT "Tried: "; tried$
 130 PRINT
 140 INPUT "Guess a letter: "; g$
 150 LET already = 0
 160 FOR i = 1 TO LEN tried$
 170 IF tried$(i) = g$ THEN LET already = 1
 180 NEXT i
 190 IF already = 1 THEN PRINT "Already tried "; g$; "!": PAUSE 50: GO TO 80
 200 LET tried$ = tried$ + g$
 210 LET found = 0
 220 FOR i = 1 TO LEN w$
 230 IF w$(i) = g$ THEN LET d$(i TO i) = g$: LET found = 1
 240 NEXT i
 250 IF found = 0 THEN LET lives = lives - 1: BEEP 0.1, -5
 260 IF found = 1 THEN BEEP 0.1, 10
 270 IF d$ = w$ THEN CLS: PRINT "You got it! The word was "; w$: STOP
 280 IF lives = 0 THEN CLS: PRINT "Out of lives! The word was "; w$: STOP
 290 GO TO 80
