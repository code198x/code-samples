  50 DIM n(20): DIM s(20): DIM e(20): DIM w(20)
  55 RESTORE 900
  57 FOR i = 1 TO 20
  58 READ n(i), s(i), e(i), w(i)
  59 NEXT i
  62 LET rm = 1
  75 CLS
  80 PRINT AT 0, 8; "*** THE CAVERNS ***"
  85 PRINT AT 3, 2; "You are in room "; rm; "."
  90 PRINT AT 5, 2; "Exits: ";
  92 IF n(rm) > 0 THEN PRINT "N ";
  93 IF s(rm) > 0 THEN PRINT "S ";
  94 IF e(rm) > 0 THEN PRINT "E ";
  95 IF w(rm) > 0 THEN PRINT "W ";
 120 INPUT "Direction (N/S/E/W): "; d$
 122 LET dest = 0
 124 IF d$ = "N" OR d$ = "n" THEN LET dest = n(rm)
 125 IF d$ = "S" OR d$ = "s" THEN LET dest = s(rm)
 126 IF d$ = "E" OR d$ = "e" THEN LET dest = e(rm)
 127 IF d$ = "W" OR d$ = "w" THEN LET dest = w(rm)
 130 IF dest = 0 THEN PRINT AT 12, 2; "You can't go that way!": PAUSE 30: GO TO 75
 135 LET rm = dest
 190 GO TO 75
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
