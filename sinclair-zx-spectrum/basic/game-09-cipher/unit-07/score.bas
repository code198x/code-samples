  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  30 DATA "SPECTRUM","COMPUTER","KEYBOARD","PROGRAM","SCREEN"
  40 DATA "PRINTER","CASSETTE","JOYSTICK","MEMORY","CIRCUIT"
  50 DATA "DISPLAY","LOADING","BORDER","COLOUR","PIXEL"
  60 DATA "BINARY","CURSOR","VOLUME","SYSTEM","BEEPER"
  70 LET total = 20
  75 LET wins = 0: LET losses = 0
  80 LET pick = INT (RND * total) + 1
  90 RESTORE
 100 FOR i = 1 TO pick: READ w$: NEXT i
 110 LET d$ = ""
 120 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 130 LET lives = 7
 140 LET tried$ = ""
 150 CLS
 160 PRINT AT 1, 10; "*** CIPHER ***"
 165 PRINT AT 2, 6; "Won: "; wins; "  Lost: "; losses
 170 PRINT AT 4, 2;
 180 FOR i = 1 TO LEN d$
 190 IF d$(i) = "_" THEN INK 7: PRINT "_ ";
 200 IF d$(i) <> "_" THEN INK 4: PRINT d$(i); " ";
 210 NEXT i
 220 INK 7
 230 PRINT AT 7, 2; "Lives: "; lives; "  "
 240 PRINT AT 9, 2; "Tried: "; tried$; "  "
 250 PRINT AT 12, 2;
 260 INPUT "Guess: "; g$
 270 LET already = 0
 280 FOR i = 1 TO LEN tried$
 290 IF tried$(i) = g$ THEN LET already = 1
 300 NEXT i
 310 IF already = 1 THEN PRINT AT 14, 2; INK 6; "Already tried!": PAUSE 50: GO TO 150
 320 LET tried$ = tried$ + g$
 330 LET found = 0
 340 FOR i = 1 TO LEN w$
 350 IF w$(i) = g$ THEN LET d$(i TO i) = g$: LET found = 1
 360 NEXT i
 370 IF found = 0 THEN LET lives = lives - 1: BEEP 0.1, -5
 380 IF found = 1 THEN BEEP 0.1, 10
 390 IF d$ = w$ THEN LET wins = wins + 1: GO TO 500
 400 IF lives = 0 THEN LET losses = losses + 1: GO TO 600
 410 GO TO 150
 500 CLS: PRINT AT 8, 6; INK 4; "You got it!"
 510 PRINT AT 10, 6; "The word was "; w$
 520 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 530 PRINT AT 14, 6; "Press any key for next word"
 540 PAUSE 0
 550 GO TO 80
 600 CLS: PRINT AT 8, 6; INK 2; "Out of lives!"
 610 PRINT AT 10, 6; "The word was "; w$
 620 BEEP 0.3, -10
 630 PRINT AT 14, 6; "Press any key for next word"
 640 PAUSE 0
 650 GO TO 80
