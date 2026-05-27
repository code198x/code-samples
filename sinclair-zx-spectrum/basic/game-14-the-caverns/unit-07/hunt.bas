  48 RANDOMIZE
  50 DIM n(20): DIM s(20): DIM e(20): DIM w(20)
  55 RESTORE 900
  57 FOR i = 1 TO 20
  58 READ n(i), s(i), e(i), w(i)
  59 NEXT i
  62 LET rm = 1
  64 LET pit = INT (RND * 19) + 2
  66 LET cr = INT (RND * 19) + 2
  67 IF cr = pit THEN GO TO 66
  75 CLS
  80 PRINT AT 0, 8; "*** THE CAVERNS ***"
  85 PRINT AT 3, 2; "You are in room "; rm; "."
  90 PRINT AT 5, 2; "Exits: ";
  92 IF n(rm) > 0 THEN PRINT "N ";
  93 IF s(rm) > 0 THEN PRINT "S ";
  94 IF e(rm) > 0 THEN PRINT "E ";
  95 IF w(rm) > 0 THEN PRINT "W ";
  97 PRINT AT 14, 2; "Pit: "; pit; " Cr: "; cr
 100 LET clue = 0
 102 LET chk = pit: GO SUB 200
 103 IF adj = 1 THEN PRINT AT 7, 2; "You feel a cold draft...": LET clue = 1
 105 LET chk = cr: GO SUB 200
 106 IF adj = 1 THEN PRINT AT 8, 2; "Something smells terrible...": LET clue = 1
 114 IF clue = 0 THEN PRINT AT 7, 2; "All quiet."
 120 INPUT "Direction (N/S/E/W): "; d$
 122 LET dest = 0
 124 IF d$ = "N" OR d$ = "n" THEN LET dest = n(rm)
 125 IF d$ = "S" OR d$ = "s" THEN LET dest = s(rm)
 126 IF d$ = "E" OR d$ = "e" THEN LET dest = e(rm)
 127 IF d$ = "W" OR d$ = "w" THEN LET dest = w(rm)
 130 IF dest = 0 THEN PRINT AT 12, 2; "You can't go that way!": PAUSE 30: GO TO 75
 135 LET rm = dest
 140 IF rm = pit THEN GO TO 400
 145 IF rm = cr THEN GO TO 420
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
 410 BEEP 0.5, -15: PAUSE 0: STOP
 420 CLS: PRINT AT 6, 8; "*** THE CAVERNS ***"
 425 PRINT AT 9, 4; INK 2; "The creature got you!"
 430 BEEP 0.3, -5: BEEP 0.3, -10: PAUSE 0: STOP
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
