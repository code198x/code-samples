20 DIM b(9): LET turn = 1: LET moves = 0
320 LET b(n) = turn: LET moves = moves + 1: GO SUB 2000
330 IF moves = 9 THEN PRINT AT 18,2; "Board full. R resets.         ": GO TO 5000
340 LET turn = 3 - turn: GO SUB 7000: GO TO 250
1060 GO SUB 7000
2040 IF b(n) = 2 THEN GO TO 2100
2100 INK 7: FOR z = 0 TO 1: PLOT x - 6,y + 10 - z: DRAW 12,0: DRAW 4,-4: DRAW 0,-12: DRAW -4,-4: DRAW -12,0: DRAW -4,4: DRAW 0,12: DRAW 4,4: NEXT z
2110 RETURN
5000 GO SUB 9000
5010 LET k$ = INKEY$: IF k$ = "" THEN GO TO 5010
5020 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
5030 IF k$ = "r" OR k$ = "R" THEN RUN
5040 GO TO 5010
7000 LET t$ = "X": IF turn = 2 THEN LET t$ = "O"
7010 PRINT AT 18,2; INK 7; t$; " to move: choose 1-9.       ": RETURN
