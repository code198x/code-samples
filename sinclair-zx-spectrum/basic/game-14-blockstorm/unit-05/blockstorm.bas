5 REM === ONE BULLET RULE ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 REM Define UDG I: player ship
30 FOR i = 0 TO 7
40 READ a
50 POKE USR "I" + i, a
60 NEXT i
70 DATA 16, 56, 56, 124, 254, 254, 130, 0
80 REM Define UDG E: bullet
90 FOR i = 0 TO 7
100 READ a
110 POKE USR "E" + i, a
120 NEXT i
130 DATA 16, 56, 16, 16, 0, 0, 0, 0
140 LET px = 15: LET py = 20
150 LET bx = 0: LET by = 0: LET ba = 0
155 PRINT AT 0, 0; INK 7; BRIGHT 1; "O/P=move SPACE=fire"
160 PRINT AT py, px; INK 7; CHR$ 152
170 REM === game loop ===
180 LET k$ = INKEY$
190 IF k$ = "o" OR k$ = "O" THEN IF px > 1 THEN PRINT AT py, px; " ": LET px = px - 1: PRINT AT py, px; INK 7; CHR$ 152
200 IF k$ = "p" OR k$ = "P" THEN IF px < 30 THEN PRINT AT py, px; " ": LET px = px + 1: PRINT AT py, px; INK 7; CHR$ 152
210 IF k$ = " " THEN IF ba = 0 THEN LET bx = px: LET by = py - 1: LET ba = 1: PRINT AT by, bx; INK 7; CHR$ 148
220 IF ba = 0 THEN GO TO 170
230 PRINT AT by, bx; " "
240 LET by = by - 1
250 IF by < 1 THEN LET ba = 0: GO TO 170
260 PRINT AT by, bx; INK 7; CHR$ 148
270 GO TO 170
