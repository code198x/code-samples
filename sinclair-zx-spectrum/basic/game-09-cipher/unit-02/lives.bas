  90 DATA "SPECTRUM"
 160 RESTORE
 170 READ w$
 180 LET d$ = ""
 190 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 200 LET lives = 7
 220 CLS
 260 FOR i = 1 TO LEN d$: PRINT d$(i); " ";: NEXT i
 310 PRINT: PRINT "Lives: "; lives
 360 PRINT
 370 INPUT "Guess: "; g$
 440 LET found = 0
 450 FOR i = 1 TO LEN w$
 460 IF w$(i) = g$ THEN LET d$(i TO i) = g$: LET found = 1
 470 NEXT i
 480 IF found = 0 THEN LET lives = lives - 1
 510 IF lives = 0 THEN PRINT "The word was "; w$: STOP
 520 GO TO 220
