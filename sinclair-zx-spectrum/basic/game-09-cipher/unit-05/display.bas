  10 BORDER 0: PAPER 0: INK 7: CLS
 120 DATA "SPECTRUM"
 190 RESTORE
 200 READ w$
 210 LET d$ = ""
 220 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 230 LET lives = 7
 240 LET z$ = ""
 250 CLS
 260 INVERSE 1: PRINT AT 0, 0; "       *** CIPHER ***           ": INVERSE 0
 280 PRINT AT 4, 2;
 290 FOR i = 1 TO LEN d$
 300 IF d$(i) = "_" THEN INK 7: PRINT "_ ";
 310 IF d$(i) <> "_" THEN INK 4: PRINT d$(i); " ";
 320 NEXT i
 330 INK 7
 340 PRINT AT 7, 2; "Lives: ";
 350 INK 4: FOR i = 1 TO lives: PRINT "*";: NEXT i
 360 FOR i = lives + 1 TO 7: PRINT " ";: NEXT i
 370 INK 7
 380 PRINT AT 9, 2; "Tried: "; z$; "  "
 390 PRINT AT 12, 2;
 400 INPUT "Guess: "; g$
 410 LET already = 0
 420 FOR i = 1 TO LEN z$
 430 IF z$(i) = g$ THEN LET already = 1
 440 NEXT i
 450 IF already = 1 THEN PRINT AT 14, 2; INK 6; "Already tried!  ": PAUSE 50: GO TO 250
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
