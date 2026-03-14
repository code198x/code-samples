5 REM === LIVES AND DEATH ===
10 BORDER 0: PAPER 0: INK 7: CLS
15 GO SUB 800
20 LET sc = 0: LET hi = 0: LET li = 3
22 LET wv = 1: LET ne = 8: LET sp = 4
25 DIM e(8): DIM r(8): DIM h(8)
30 FOR i = 1 TO ne
32 LET e(i) = (i - 1) * 2: LET r(i) = 0: LET h(i) = 1
34 NEXT i
36 LET fx = 6: LET fy = 2: LET fd = 1: LET tk = 0
40 LET px = 15: LET py = 20
42 LET ba = 0: LET bx = 0: LET by = 0
50 GO SUB 600
55 PRINT AT py, px; INK 7; CHR$ 152
57 GO SUB 400
60 REM === game loop ===
70 LET k$ = INKEY$
80 IF k$ = "o" OR k$ = "O" THEN IF px > 1 THEN PRINT AT py, px; " ": LET px = px - 1: PRINT AT py, px; INK 7; CHR$ 152
90 IF k$ = "p" OR k$ = "P" THEN IF px < 30 THEN PRINT AT py, px; " ": LET px = px + 1: PRINT AT py, px; INK 7; CHR$ 152
100 IF k$ = " " THEN IF ba = 0 THEN LET bx = px: LET by = py - 1: LET ba = 1: PRINT AT by, bx; INK 7; CHR$ 148: BEEP 0.01, 20
110 REM move bullet
115 IF ba = 0 THEN GO TO 170
120 PRINT AT by, bx; " "
130 LET by = by - 1
140 IF by < 1 THEN LET ba = 0: GO TO 170
150 LET ht = 0
155 FOR i = 1 TO ne
156 IF h(i) <= 0 THEN GO TO 158
157 IF bx = fx + e(i) AND by = fy + r(i) THEN LET ht = i: LET i = ne
158 NEXT i
160 IF ht > 0 THEN LET ba = 0: LET h(ht) = 0: PRINT AT fy + r(ht), fx + e(ht); INK 2; CHR$ 149: BEEP 0.02, -5: BEEP 0.02, -10: PAUSE 5: PRINT AT fy + r(ht), fx + e(ht); " ": LET sc = sc + 10: IF sc > hi THEN LET hi = sc
162 IF ht > 0 THEN GO SUB 600: GO TO 170
165 PRINT AT by, bx; INK 7; CHR$ 148
170 REM move formation on tick
175 LET tk = tk + 1
180 IF tk < sp THEN GO TO 60
185 LET tk = 0
190 GO SUB 400
195 IF fy > 19 THEN GO TO 700
200 GO TO 60
400 REM === move formation ===
402 FOR i = 1 TO ne
404 IF h(i) <= 0 THEN GO TO 410
406 LET sx = fx + e(i): LET sy = fy + r(i)
408 IF sx >= 1 AND sx <= 30 AND sy >= 1 AND sy <= 21 THEN PRINT AT sy, sx; " "
410 NEXT i
412 LET fx = fx + fd
414 IF fx + 14 > 30 OR fx < 1 THEN LET fd = -fd: LET fy = fy + 1
416 FOR i = 1 TO ne
418 IF h(i) <= 0 THEN GO TO 425
420 LET sx = fx + e(i): LET sy = fy + r(i)
422 IF sx >= 1 AND sx <= 30 AND sy >= 1 AND sy <= 21 THEN PRINT AT sy, sx; INK 4; CHR$ 144
425 NEXT i
427 RETURN
530 REM === player hit ===
534 LET li = li - 1
536 PRINT AT py, px; INK 2; CHR$ 149
538 BEEP 0.1, -10: BEEP 0.1, -15
540 PAUSE 25
542 PRINT AT py, px; " "
544 IF li <= 0 THEN GO TO 700
546 LET px = 15
548 PRINT AT py, px; INK 7; CHR$ 152
549 GO SUB 600
550 RETURN
600 REM === draw HUD ===
605 PRINT AT 0, 0; INK 7; BRIGHT 1; "SC:"; sc; "  HI:"; hi; "  LV:"; li; " W"; wv; "  "
610 RETURN
700 REM === game over ===
705 CLS
710 PRINT AT 8, 10; INK 2; BRIGHT 1; "GAME OVER"
715 PRINT AT 10, 7; INK 7; "Score: "; sc
720 PRINT AT 12, 7; INK 7; "High: "; hi
730 PRINT AT 18, 6; INK 7; "Press any key"
735 PAUSE 0
740 LET li = 3: LET sc = 0
745 GO TO 20
800 REM === define UDGs ===
805 FOR i = 0 TO 13
810 FOR j = 0 TO 7
815 READ a
820 POKE USR CHR$ (65 + i) + j, a
825 NEXT j
830 NEXT i
835 RETURN
840 REM UDG A: drone
842 DATA 36, 126, 219, 255, 255, 102, 66, 0
844 REM UDG B: scout
846 DATA 24, 60, 126, 255, 219, 24, 36, 0
848 REM UDG C: tank
850 DATA 126, 255, 255, 255, 255, 255, 126, 0
852 REM UDG D: bomber
854 DATA 66, 231, 255, 126, 60, 90, 36, 0
856 REM UDG E: bullet
858 DATA 16, 56, 16, 16, 0, 0, 0, 0
860 REM UDG F: explosion
862 DATA 36, 153, 66, 129, 66, 153, 36, 0
864 REM UDG G: double shot
866 DATA 84, 170, 84, 170, 84, 170, 84, 0
868 REM UDG H: shield
870 DATA 60, 126, 255, 255, 255, 126, 60, 0
872 REM UDG I: player ship
874 DATA 16, 56, 56, 124, 254, 254, 130, 0
876 REM UDG J: enemy bomb
878 DATA 16, 16, 56, 16, 0, 0, 0, 0
880 REM UDG K: explosion 2
882 DATA 129, 66, 36, 0, 36, 66, 129, 0
884 REM UDG L: shield icon
886 DATA 60, 126, 126, 126, 60, 24, 0, 0
888 REM UDG M: drone frame 2
890 DATA 66, 102, 255, 255, 219, 126, 36, 0
892 REM UDG N: scout frame 2
894 DATA 36, 24, 219, 255, 126, 60, 24, 0
