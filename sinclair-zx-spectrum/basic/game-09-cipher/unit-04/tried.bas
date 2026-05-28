  10 BORDER 0: PAPER 0: INK 7: CLS
 120 DATA "SPECTRUM"
 190 RESTORE
 200 READ w$
 210 LET d$ = ""
 220 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 230 LET lives = 7
 240 LET z$ = ""
 250 CLS
 290 FOR i = 1 TO LEN d$: PRINT d$(i); " ";: NEXT i
 340 PRINT: PRINT "Lives: "; lives
 380 PRINT "Tried: "; z$
 390 PRINT
 400 INPUT "Guess: "; g$
 410 LET already = 0
 420 FOR i = 1 TO LEN z$
 430 IF z$(i) = g$ THEN LET already = 1
 440 NEXT i
 450 IF already = 1 THEN PRINT "Already tried!": PAUSE 50: GO TO 250
 460 LET z$ = z$ + g$
 470 LET found = 0
 480 FOR i = 1 TO LEN w$
 490 IF w$(i) = g$ THEN LET d$(i TO i) = g$: LET found = 1
 500 NEXT i
 510 IF found = 0 THEN LET lives = lives - 1: BEEP 0.1, -5
 520 IF found = 1 THEN BEEP 0.1, 10
 530 IF d$ = w$ THEN PRINT "You cracked it!": STOP
 540 IF lives = 0 THEN PRINT "The word was "; w$: STOP
 550 GO TO 250

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
