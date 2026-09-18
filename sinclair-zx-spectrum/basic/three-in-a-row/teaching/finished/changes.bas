20 LET wins = 0: LET losses = 0: LET draws = 0: LET first = 1
30 PRINT AT 3,6; INK 5; "T H R E E  I N  A  R O W"
40 PRINT AT 7,2; "You are X. The computer is O."
50 PRINT AT 9,4; "Three in a line wins."
60 PRINT AT 11,4; "Choose a square with 1-9."
70 PRINT AT 13,2; "Watch why O chooses its move."
80 PRINT AT 16,4; "R restarts. Q quits."
90 PRINT AT 19,6; INK 5; "S starts. Q quits."
100 GO SUB 9000
110 LET k$ = INKEY$: IF k$ = "" THEN GO TO 110
120 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
130 IF k$ <> "s" AND k$ <> "S" THEN GO TO 110
200 DIM b(9): LET moves = 0: LET winner = 0: LET wl = 0: LET a$ = ""
210 GO SUB 1000
220 IF first = 2 THEN GO TO 600
280 IF k$ = "r" OR k$ = "R" THEN GO TO 200
340 IF winner > 0 OR moves = 9 THEN GO TO 5000
650 IF winner > 0 OR moves = 9 THEN GO TO 5000
1020 PRINT AT 1,2; INK 7; "W "; wins; "   L "; losses; "   D "; draws
1070 IF first = 1 THEN PRINT AT 19,2; INK 5; "You start this round."
1080 IF first = 2 THEN PRINT AT 19,2; INK 5; "O starts this round."
5000 IF winner = 1 THEN LET wins = wins + 1: LET r$ = "YOU WIN. Three in a row."
5010 IF winner = 2 THEN LET losses = losses + 1: LET r$ = "O WINS. Three in a row."
5020 IF winner = 0 THEN LET draws = draws + 1: LET r$ = "DRAW. No line completed."
5030 IF wl > 0 THEN GO SUB 6000
5040 PRINT AT 18,2; INK 6; r$; "      "
5050 PRINT AT 1,2; INK 7; "W "; wins; "   L "; losses; "   D "; draws; "  "
5060 PRINT AT 21,2; "R: next round   Q: quit      "
5070 GO SUB 9000
5080 LET k$ = INKEY$: IF k$ = "" THEN GO TO 5080
5090 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
5100 IF k$ <> "r" AND k$ <> "R" THEN GO TO 5080
5110 LET first = 3 - first: GO TO 200
