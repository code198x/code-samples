  90 DATA "SPECTRUM"
 160 RESTORE
 170 READ w$
 180 LET d$ = ""
 190 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 200 LET lives = 7
 210 LET tried$ = ""
 220 CLS
 230 PRINT AT 0, 10; "*** CIPHER ***"
 250 PRINT AT 4, 2;
 260 FOR i = 1 TO LEN d$
 270 IF d$(i) = "_" THEN INK 7: PRINT "_ ";
 280 IF d$(i) <> "_" THEN INK 4: PRINT d$(i); " ";
 290 NEXT i
 300 INK 7
 310 PRINT AT 7, 2; "Lives: ";
 320 INK 4: FOR i = 1 TO lives: PRINT "*";: NEXT i
 330 FOR i = lives + 1 TO 7: PRINT " ";: NEXT i
 340 INK 7
 350 PRINT AT 9, 2; "Tried: "; tried$; "  "
 360 PRINT AT 12, 2;
 370 INPUT "Guess: "; g$
 380 LET already = 0
 390 FOR i = 1 TO LEN tried$
 400 IF tried$(i) = g$ THEN LET already = 1
 410 NEXT i
 420 IF already = 1 THEN PRINT AT 14, 2; INK 6; "Already tried!  ": PAUSE 50: GO TO 220
 430 LET tried$ = tried$ + g$
 440 LET found = 0
 450 FOR i = 1 TO LEN w$
 460 IF w$(i) = g$ THEN LET d$(i TO i) = g$: LET found = 1
 470 NEXT i
 480 IF found = 0 THEN LET lives = lives - 1: BEEP 0.1, -5
 490 IF found = 1 THEN BEEP 0.1, 10
 500 IF d$ = w$ THEN PRINT "You cracked it!": STOP
 510 IF lives = 0 THEN PRINT "The word was "; w$: STOP
 520 GO TO 220
