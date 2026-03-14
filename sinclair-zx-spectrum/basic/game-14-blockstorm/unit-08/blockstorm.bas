5 REM === ONE DRONE ===
10 BORDER 0: PAPER 0: INK 7: CLS
15 GO SUB 800
20 LET sc = 0: LET hi = 0: LET li = 3
22 LET wv = 1
30 LET px = 15: LET py = 20
32 LET ba = 0: LET bx = 0: LET by = 0
34 LET ex = 15: LET ey = 5: LET ea = 1
40 GO SUB 600
50 PRINT AT py, px; INK 7; CHR$ 152
55 PRINT AT ey, ex; INK 4; CHR$ 144
60 REM === game loop ===
70 LET k$ = INKEY$
80 IF k$ = "o" OR k$ = "O" THEN IF px > 1 THEN PRINT AT py, px; " ": LET px = px - 1: PRINT AT py, px; INK 7; CHR$ 152
90 IF k$ = "p" OR k$ = "P" THEN IF px < 30 THEN PRINT AT py, px; " ": LET px = px + 1: PRINT AT py, px; INK 7; CHR$ 152
100 IF k$ = " " THEN IF ba = 0 THEN LET bx = px: LET by = py - 1: LET ba = 1: PRINT AT by, bx; INK 7; CHR$ 148
110 IF ba = 0 THEN GO TO 60
120 PRINT AT by, bx; " "
130 LET by = by - 1
140 IF by < 1 THEN LET ba = 0: GO TO 60
150 REM check hit
160 IF ea = 1 AND bx = ex AND by = ey THEN LET ea = 0: LET ba = 0: PRINT AT ey, ex; INK 2; CHR$ 149: LET sc = sc + 10: GO SUB 600: PAUSE 10: PRINT AT ey, ex; " ": GO TO 60
170 PRINT AT by, bx; INK 7; CHR$ 148
180 GO TO 60
600 REM === draw HUD ===
605 PRINT AT 0, 0; INK 7; BRIGHT 1; "SC:"; sc; "  HI:"; hi; "  LV:"; li; " W"; wv; "  "
610 RETURN
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
