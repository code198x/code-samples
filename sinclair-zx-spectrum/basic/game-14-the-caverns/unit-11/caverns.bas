  10 BORDER 0: PAPER 1: INK 7: CLS
  20 PRINT AT 5, 8; "*** THE CAVERNS ***"
  25 PRINT AT 8, 4; "Explore 20 dark rooms."
  27 PRINT AT 9, 4; "Collect 3 treasures to win."
  30 PRINT AT 11, 4; "Beware the pit and the"
  32 PRINT AT 12, 4; "creature that stalks you."
  35 PRINT AT 14, 4; "Listen for clues..."
  40 PRINT AT 18, 4; "Press any key to enter"
  45 PAUSE 0
  48 RANDOMIZE
  50 DIM n(20): DIM s(20): DIM e(20): DIM w(20)
  55 RESTORE 900
  57 FOR i = 1 TO 20
  58 READ n(i), s(i), e(i), w(i)
  59 NEXT i
  62 LET rm = 1: LET found = 0: LET steps = 0
  64 LET pit = INT (RND * 19) + 2
  66 LET cr = INT (RND * 19) + 2
  67 IF cr = pit THEN GO TO 66
  68 DIM t(3)
  69 LET t(1) = INT (RND * 19) + 2
  70 IF t(1) = pit OR t(1) = cr THEN GO TO 69
  71 LET t(2) = INT (RND * 19) + 2
  72 IF t(2) = pit OR t(2) = cr OR t(2) = t(1) THEN GO TO 71
  73 LET t(3) = INT (RND * 19) + 2
  74 IF t(3) = pit OR t(3) = cr OR t(3) = t(1) OR t(3) = t(2) THEN GO TO 73
  75 CLS
  80 PRINT AT 0, 8; "*** THE CAVERNS ***"
  82 PRINT AT 1, 4; "Treasures: "; found; "/3"
  85 PRINT AT 3, 2; "You are in room "; rm; "."
  90 PRINT AT 5, 2; "Exits: ";
  92 IF n(rm) > 0 THEN PRINT "N ";
  93 IF s(rm) > 0 THEN PRINT "S ";
  94 IF e(rm) > 0 THEN PRINT "E ";
  95 IF w(rm) > 0 THEN PRINT "W ";
 100 LET clue = 0
 102 LET chk = pit: GO SUB 200
 103 IF adj = 1 THEN PRINT AT 7, 2; INK 6; "You feel a cold draft...": LET clue = 1: BEEP 0.3, -10
 105 LET chk = cr: GO SUB 200
 106 IF adj = 1 THEN PRINT AT 8, 2; INK 2; "Something smells terrible...": LET clue = 1: BEEP 0.2, 20
 108 LET gl = 0
 109 FOR i = 1 TO 3
 110 IF t(i) > 0 THEN LET chk = t(i): GO SUB 200: IF adj = 1 THEN LET gl = 1
 111 NEXT i
 112 IF gl = 1 THEN PRINT AT 9, 2; INK 4; "A faint glint nearby...": LET clue = 1: BEEP 0.1, 15
 114 IF clue = 0 THEN PRINT AT 7, 2; "All quiet."
 120 INPUT "Direction (N/S/E/W): "; d$
 122 LET dest = 0
 124 IF d$ = "N" OR d$ = "n" THEN LET dest = n(rm)
 125 IF d$ = "S" OR d$ = "s" THEN LET dest = s(rm)
 126 IF d$ = "E" OR d$ = "e" THEN LET dest = e(rm)
 127 IF d$ = "W" OR d$ = "w" THEN LET dest = w(rm)
 130 IF dest = 0 THEN PRINT AT 12, 2; "You can't go that way!": BEEP 0.1, -5: PAUSE 30: GO TO 75
 135 LET rm = dest
 136 LET steps = steps + 1
 140 IF rm = pit THEN GO TO 400
 145 IF rm = cr THEN GO TO 420
 150 FOR i = 1 TO 3
 152 IF rm = t(i) THEN LET t(i) = 0: LET found = found + 1: PRINT AT 12, 2; INK 4; "You found treasure!": BEEP 0.1, 10: BEEP 0.1, 15: PAUSE 30
 154 NEXT i
 160 IF found = 3 THEN GO TO 440
 170 REM --- Creature moves ---
 172 LET nm = 0
 174 LET d = INT (RND * 4) + 1
 176 IF d = 1 AND n(cr) > 0 THEN LET nm = n(cr)
 177 IF d = 2 AND s(cr) > 0 THEN LET nm = s(cr)
 178 IF d = 3 AND e(cr) > 0 THEN LET nm = e(cr)
 179 IF d = 4 AND w(cr) > 0 THEN LET nm = w(cr)
 180 IF nm = 0 THEN GO TO 174
 182 LET cr = nm
 185 IF cr = rm THEN GO TO 420
 190 GO TO 75
 200 REM --- Is chk adjacent? ---
 205 LET adj = 0
 207 IF n(rm) = chk OR s(rm) = chk OR e(rm) = chk OR w(rm) = chk THEN LET adj = 1
 210 RETURN
 400 CLS: PRINT AT 6, 8; "*** THE CAVERNS ***"
 405 PRINT AT 9, 4; INK 2; "You fell into the pit!"
 410 BEEP 0.5, -15
 412 GO TO 450
 420 CLS: PRINT AT 6, 8; "*** THE CAVERNS ***"
 425 PRINT AT 9, 4; INK 2; "The creature got you!"
 430 BEEP 0.3, -5: BEEP 0.3, -10
 432 GO TO 450
 440 CLS: PRINT AT 6, 8; "*** THE CAVERNS ***"
 442 PRINT AT 9, 4; INK 4; "All treasures found!"
 444 PRINT AT 11, 4; "You escaped the caverns!"
 446 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 450 PRINT AT 13, 4; "Steps taken: "; steps
 455 PRINT AT 18, 4; "Press any key to play again"
 460 PAUSE 0
 470 GO TO 10
 899 REM --- Room map: N,S,E,W ---
 900 DATA 0,5,2,0
 901 DATA 0,0,3,1
 902 DATA 0,7,4,2
 903 DATA 0,8,0,3
 904 DATA 1,0,6,0
 905 DATA 0,10,7,5
 906 DATA 3,11,0,6
 907 DATA 4,12,0,0
 908 DATA 0,13,10,0
 909 DATA 6,0,11,9
 910 DATA 7,15,12,10
 911 DATA 8,0,0,11
 912 DATA 9,17,14,0
 913 DATA 0,18,0,13
 914 DATA 11,19,16,0
 915 DATA 0,20,0,15
 916 DATA 13,0,18,0
 917 DATA 14,0,19,17
 918 DATA 15,0,20,18
 919 DATA 16,0,0,19
