20 PRINT AT 3,8; INK 5; "THE CAVERNS"
30 PRINT AT 6,2; "Find three lost treasures."
40 PRINT AT 8,2; "Bring them to the entrance."
50 PRINT AT 10,2; "N S E W: move. SPACE: wait."
60 PRINT AT 12,2; "Read the signs by each exit."
70 PRINT AT 14,2; "If it arrives, leave at once!"
80 PRINT AT 17,2; "R restarts. Q quits."
90 PRINT AT 20,2; INK 6; "S enters the cave."
100 GO SUB 9000
110 LET k$ = INKEY$: IF k$ = "" THEN GO TO 110
120 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
130 IF k$ <> "s" AND k$ <> "S" THEN GO TO 110
