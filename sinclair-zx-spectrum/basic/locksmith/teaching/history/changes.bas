420 GO SUB 4000
440 IF t = 10 THEN GO TO 5100
450 LET t = t + 1: LET g$ = ""
460 PRINT AT 18,2; "                            "
1010 PRINT AT 0,1; INK 5; "LOCKSMITH"; AT 0,21; INK 7; "10 TRIES"
1040 FOR j = 5 TO 14: PRINT AT j,1; INK 1; "-"; AT j,7; ". . . ."; AT j,21; "."; AT j,28; ".": NEXT j
5100 PRINT AT 17,1; INK 6; "Ten practice guesses recorded. "
5200 PRINT AT 18,1; "                              "; AT 18,1; INK 7; "The code: ";
5210 FOR i = 1 TO 4: PRINT c(i);: NEXT i
5220 PRINT AT 20,1; "R: clear board   Q: quit       "
5230 PRINT AT 21,1; "                              "
5240 GO SUB 9000
5250 LET k$ = INKEY$: IF k$ = "" THEN GO TO 5250
5260 IF k$ = "r" OR k$ = "R" THEN GO TO 200
5270 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
5280 GO TO 5250
