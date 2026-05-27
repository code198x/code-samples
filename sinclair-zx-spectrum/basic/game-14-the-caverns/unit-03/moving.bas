  10 BORDER 0: PAPER 1: INK 7: CLS
 110 DIM n(20): DIM s(20): DIM e(20): DIM w(20)
 120 RESTORE 1010
 130 FOR i = 1 TO 20
 140 READ n(i), s(i), e(i), w(i)
 150 NEXT i
 160 LET rm = 1
 270 CLS
 280 PRINT AT 0, 8; "*** THE CAVERNS ***"
 300 PRINT AT 3, 2; "You are in room "; rm; "."
 310 PRINT AT 5, 2; "Exits: ";
 320 IF n(rm) > 0 THEN PRINT "N ";
 330 IF s(rm) > 0 THEN PRINT "S ";
 340 IF e(rm) > 0 THEN PRINT "E ";
 350 IF w(rm) > 0 THEN PRINT "W ";
 480 INPUT "Direction (N/S/E/W): "; d$
 490 LET dest = 0
 500 IF d$ = "N" OR d$ = "n" THEN LET dest = n(rm)
 510 IF d$ = "S" OR d$ = "s" THEN LET dest = s(rm)
 520 IF d$ = "E" OR d$ = "e" THEN LET dest = e(rm)
 530 IF d$ = "W" OR d$ = "w" THEN LET dest = w(rm)
 540 IF dest = 0 THEN PRINT AT 12, 2; "You can't go that way!": PAUSE 30: GO TO 270
 550 LET rm = dest
 730 GO TO 270
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
