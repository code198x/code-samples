  10 BORDER 0: PAPER 0: INK 7: CLS
  20 DATA 0,102,255,255,255,126,60,24
  30 FOR j = 0 TO 7: READ b: POKE USR "A" + j, b: NEXT j
  40 RANDOMIZE
  50 PRINT AT 5, 10; BRIGHT 1; "*** CIPHER ***"
  60 PRINT AT 8, 4; "Guess the hidden word,"
  70 PRINT AT 9, 4; "one letter at a time."
  80 PRINT AT 11, 4; "You have 7 lives per word."
  90 PRINT AT 15, 4; "Press any key to start"
 100 PLOT 120, 108: DRAW 16, 0: DRAW 0, -16: DRAW -16, 0: DRAW 0, 16: CIRCLE 128, 116, 8
 110 PAUSE 0
 120 DATA "SPECTRUM","COMPUTER","KEYBOARD","PROGRAM","SCREEN"
 130 DATA "PRINTER","CASSETTE","JOYSTICK","MEMORY","CIRCUIT"
 140 DATA "DISPLAY","LOADING","BORDER","COLOUR","PIXEL"
 150 DATA "BINARY","CURSOR","VOLUME","SYSTEM","BEEPER"
 160 LET total = 20
 170 LET wins = 0: LET losses = 0
 180 LET pick = INT (RND * total) + 1
 190 RESTORE 120
 200 FOR i = 1 TO pick: READ w$: NEXT i
 210 LET d$ = ""
 220 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 230 LET lives = 7
 240 LET z$ = ""
 250 CLS
 260 INVERSE 1: PRINT AT 0, 0; "       *** CIPHER ***           ": INVERSE 0
 270 PRINT AT 1, 4; "Won: "; wins; "  Lost: "; losses; "   "
 280 PRINT AT 4, 2;
 290 FOR i = 1 TO LEN d$
 300 IF d$(i) = "_" THEN INK 7: PRINT "_ ";
 310 IF d$(i) <> "_" THEN INK 4: PRINT d$(i); " ";
 320 NEXT i
 330 INK 7
 340 PRINT AT 7, 2; "Lives: ";
 350 INK 2: FOR i = 1 TO lives: PRINT CHR$ 144;: NEXT i
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
 530 IF d$ = w$ THEN LET wins = wins + 1: GO TO 700
 540 IF lives = 0 THEN LET losses = losses + 1: GO TO 770
 550 GO TO 250
 700 CLS: PRINT AT 6, 10; BRIGHT 1; "*** CIPHER ***"
 710 PRINT AT 9, 4; INK 4; "You cracked it!"
 720 PRINT AT 11, 4; "The word was "; w$
 730 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 740 PRINT AT 14, 4; INK 7; "Won: "; wins; "  Lost: "; losses
 750 PRINT AT 18, 4; "Press any key for next word"
 760 PAUSE 0: GO TO 180
 770 CLS: PRINT AT 6, 10; BRIGHT 1; "*** CIPHER ***"
 780 PRINT AT 9, 4; INK 2; "Out of lives!"
 790 PRINT AT 11, 4; "The word was "; w$
 800 BEEP 0.3, -10
 810 PRINT AT 14, 4; INK 7; "Won: "; wins; "  Lost: "; losses
 820 PRINT AT 18, 4; "Press any key for next word"
 830 PAUSE 0: GO TO 180

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
