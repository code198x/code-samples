  10 BORDER 0: PAPER 0: INK 7: CLS
 120 DATA "SPECTRUM"
 190 RESTORE
 200 READ w$
 210 LET d$ = ""
 220 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 230 LET lives = 7
 250 CLS
 290 FOR i = 1 TO LEN d$: PRINT d$(i); " ";: NEXT i
 340 PRINT: PRINT "Lives: "; lives
 390 PRINT
 400 INPUT "Guess: "; g$
 470 LET found = 0
 480 FOR i = 1 TO LEN w$
 490 IF w$(i) = g$ THEN LET d$(i TO i) = g$: LET found = 1
 500 NEXT i
 510 IF found = 0 THEN LET lives = lives - 1: BEEP 0.1, -5
 520 IF found = 1 THEN BEEP 0.1, 10
 530 IF d$ = w$ THEN PRINT "You cracked it!": STOP
 540 IF lives = 0 THEN PRINT "The word was "; w$: STOP
 550 GO TO 250
