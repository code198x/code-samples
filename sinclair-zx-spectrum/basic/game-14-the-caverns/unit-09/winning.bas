  10 BORDER 0: PAPER 1: INK 7: CLS
 100 RANDOMIZE
 110 DIM n(20): DIM s(20): DIM e(20): DIM w(20)
 120 RESTORE 1010
 130 FOR i = 1 TO 20
 140 READ n(i), s(i), e(i), w(i)
 150 NEXT i
 160 LET rm = 1: LET found = 0
 170 LET pit = INT (RND * 19) + 2
 180 LET cr = INT (RND * 19) + 2
 190 IF cr = pit THEN GO TO 180
 200 DIM t(3)
 210 LET t(1) = INT (RND * 19) + 2
 220 IF t(1) = pit OR t(1) = cr THEN GO TO 210
 230 LET t(2) = INT (RND * 19) + 2
 240 IF t(2) = pit OR t(2) = cr OR t(2) = t(1) THEN GO TO 230
 250 LET t(3) = INT (RND * 19) + 2
 260 IF t(3) = pit OR t(3) = cr OR t(3) = t(1) OR t(3) = t(2) THEN GO TO 250
 270 CLS
 280 LET a$ = "*** THE CAVERNS ***": LET y = 0: GO SUB 9000
 290 PRINT AT 1, 4; "Treasures: "; found; "/3"
 300 PRINT AT 3, 2; "You are in room "; rm; "."
 310 PRINT AT 5, 2; "Exits: ";
 320 IF n(rm) > 0 THEN PRINT "N ";
 330 IF s(rm) > 0 THEN PRINT "S ";
 340 IF e(rm) > 0 THEN PRINT "E ";
 350 IF w(rm) > 0 THEN PRINT "W ";
 360 PRINT AT 14, 2; "P:"; pit; " C:"; cr; " T:"; t(1); ","; t(2); ","; t(3)
 370 LET clue = 0
 380 LET chk = pit: GO SUB 740
 390 IF adj = 1 THEN PRINT AT 7, 2; "You feel a cold draft...": LET clue = 1
 400 LET chk = cr: GO SUB 740
 410 IF adj = 1 THEN PRINT AT 8, 2; "Something smells terrible...": LET clue = 1
 420 LET gl = 0
 430 FOR i = 1 TO 3
 440 IF t(i) > 0 THEN LET chk = t(i): GO SUB 740: IF adj = 1 THEN LET gl = 1
 450 NEXT i
 460 IF gl = 1 THEN PRINT AT 9, 2; "A faint glint nearby...": LET clue = 1
 470 IF clue = 0 THEN PRINT AT 7, 2; "All quiet."
 480 INPUT "Direction (N/S/E/W): "; d$
 490 LET dest = 0
 500 IF d$ = "N" OR d$ = "n" THEN LET dest = n(rm)
 510 IF d$ = "S" OR d$ = "s" THEN LET dest = s(rm)
 520 IF d$ = "E" OR d$ = "e" THEN LET dest = e(rm)
 530 IF d$ = "W" OR d$ = "w" THEN LET dest = w(rm)
 540 IF dest = 0 THEN PRINT AT 12, 2; "You can't go that way!": PAUSE 30: GO TO 270
 550 LET rm = dest
 570 IF rm = pit THEN GO TO 800
 580 IF rm = cr THEN GO TO 840
 590 FOR i = 1 TO 3
 600 IF rm = t(i) THEN LET t(i) = 0: LET found = found + 1: PRINT AT 12, 2; "You found treasure!": BEEP 0.1, 10: BEEP 0.1, 15: PAUSE 30
 610 NEXT i
 620 IF found = 3 THEN GO TO 880
 630 REM --- Creature moves ---
 640 LET nm = 0
 650 LET d = INT (RND * 4) + 1
 660 IF d = 1 AND n(cr) > 0 THEN LET nm = n(cr)
 670 IF d = 2 AND s(cr) > 0 THEN LET nm = s(cr)
 680 IF d = 3 AND e(cr) > 0 THEN LET nm = e(cr)
 690 IF d = 4 AND w(cr) > 0 THEN LET nm = w(cr)
 700 IF nm = 0 THEN GO TO 650
 710 LET cr = nm
 720 IF cr = rm THEN GO TO 840
 730 GO TO 270
 740 REM --- Is chk adjacent? ---
 750 LET adj = 0
 760 IF n(rm) = chk OR s(rm) = chk OR e(rm) = chk OR w(rm) = chk THEN LET adj = 1
 770 RETURN
 800 CLS: LET a$ = "*** THE CAVERNS ***": LET y = 6: GO SUB 9000
 810 PRINT AT 9, 4; INK 2; "You fell into the pit!"
 820 BEEP 0.5, -15: PAUSE 0: STOP
 840 CLS: LET a$ = "*** THE CAVERNS ***": LET y = 6: GO SUB 9000
 850 PRINT AT 9, 4; INK 2; "The creature got you!"
 860 BEEP 0.3, -5: BEEP 0.3, -10: PAUSE 0: STOP
 880 CLS: LET a$ = "*** THE CAVERNS ***": LET y = 6: GO SUB 9000
 890 PRINT AT 9, 4; INK 4; "All treasures found!"
 900 PRINT AT 11, 4; "You escaped the caverns!"
 910 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20: PAUSE 0: STOP
1000 REM --- Room map: N,S,E,W ---
1010 DATA 0,5,2,0
1020 DATA 0,0,3,1
1030 DATA 0,7,4,2
1040 DATA 0,8,0,3
1050 DATA 1,0,6,0
1060 DATA 0,10,7,5
1070 DATA 3,11,0,6
1080 DATA 4,12,0,0
1090 DATA 0,13,10,0
1100 DATA 6,0,11,9
1110 DATA 7,15,12,10
1120 DATA 8,0,0,11
1130 DATA 9,17,14,0
1140 DATA 0,18,0,13
1150 DATA 11,19,16,0
1160 DATA 0,20,0,15
1170 DATA 13,0,18,0
1180 DATA 14,0,19,17
1190 DATA 15,0,20,18
1200 DATA 16,0,0,19

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
