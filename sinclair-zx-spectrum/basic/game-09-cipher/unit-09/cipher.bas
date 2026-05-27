  10 BORDER 0: PAPER 0: INK 7: CLS
  12 DATA 0,102,255,255,255,126,60,24
  14 FOR j = 0 TO 7: READ b: POKE USR "A" + j, b: NEXT j
  20 RANDOMIZE
  30 PRINT AT 5, 10; BRIGHT 1; "*** CIPHER ***"
  40 PRINT AT 8, 4; "Guess the hidden word,"
  50 PRINT AT 9, 4; "one letter at a time."
  60 PRINT AT 11, 4; "You have 7 lives per word."
  75 PLOT 120, 108: DRAW 16, 0: DRAW 0, -16: DRAW -16, 0: DRAW 0, 16: CIRCLE 128, 116, 8
  70 PRINT AT 15, 4; "Press any key to start"
  80 PAUSE 0
  90 DATA "SPECTRUM","COMPUTER","KEYBOARD","PROGRAM","SCREEN"
 100 DATA "PRINTER","CASSETTE","JOYSTICK","MEMORY","CIRCUIT"
 110 DATA "DISPLAY","LOADING","BORDER","COLOUR","PIXEL"
 120 DATA "BINARY","CURSOR","VOLUME","SYSTEM","BEEPER"
 130 LET total = 20
 140 LET wins = 0: LET losses = 0
 150 LET pick = INT (RND * total) + 1
 160 RESTORE
 170 FOR i = 1 TO pick: READ w$: NEXT i
 180 LET d$ = ""
 190 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 200 LET lives = 7
 210 LET z$ = ""
 220 CLS
 230 INVERSE 1: PRINT AT 0, 0; "       *** CIPHER ***           ": INVERSE 0
 240 PRINT AT 1, 4; "Won: "; wins; "  Lost: "; losses; "   "
 250 PRINT AT 4, 2;
 260 FOR i = 1 TO LEN d$
 270 IF d$(i) = "_" THEN INK 7: PRINT "_ ";
 280 IF d$(i) <> "_" THEN INK 4: PRINT d$(i); " ";
 290 NEXT i
 300 INK 7
 310 PRINT AT 7, 2; "Lives: ";
 320 INK 2: FOR i = 1 TO lives: PRINT CHR$ 144;: NEXT i
 330 FOR i = lives + 1 TO 7: PRINT " ";: NEXT i
 340 INK 7
 350 PRINT AT 9, 2; "Tried: "; z$; "  "
 360 PRINT AT 12, 2;
 370 INPUT "Guess: "; g$
 380 LET already = 0
 390 FOR i = 1 TO LEN z$
 400 IF z$(i) = g$ THEN LET already = 1
 410 NEXT i
 420 IF already = 1 THEN PRINT AT 14, 2; INK 6; "Already tried!  ": PAUSE 50: GO TO 220
 430 LET z$ = z$ + g$
 440 LET found = 0
 450 FOR i = 1 TO LEN w$
 460 IF w$(i) = g$ THEN LET d$(i TO i) = g$: LET found = 1
 470 NEXT i
 480 IF found = 0 THEN LET lives = lives - 1: BEEP 0.1, -5
 490 IF found = 1 THEN BEEP 0.1, 10
 500 IF d$ = w$ THEN LET wins = wins + 1: GO TO 700
 510 IF lives = 0 THEN LET losses = losses + 1: GO TO 800
 520 GO TO 220
 700 CLS: PRINT AT 6, 10; BRIGHT 1; "*** CIPHER ***"
 710 PRINT AT 9, 4; INK 4; "You cracked it!"
 720 PRINT AT 11, 4; "The word was "; w$
 730 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 740 PRINT AT 14, 4; INK 7; "Won: "; wins; "  Lost: "; losses
 750 PRINT AT 18, 4; "Press any key for next word"
 760 PAUSE 0: GO TO 150
 800 CLS: PRINT AT 6, 10; BRIGHT 1; "*** CIPHER ***"
 810 PRINT AT 9, 4; INK 2; "Out of lives!"
 820 PRINT AT 11, 4; "The word was "; w$
 830 BEEP 0.3, -10
 840 PRINT AT 14, 4; INK 7; "Won: "; wins; "  Lost: "; losses
 850 PRINT AT 18, 4; "Press any key for next word"
 860 PAUSE 0: GO TO 150

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
