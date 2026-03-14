5 REM === DUNGEONS OF DORIN ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 PRINT AT 3, 4; INK 7; BRIGHT 1; "DUNGEONS OF DORIN"
30 PRINT AT 6, 2; INK 6; "Descend ten floors of"
35 PRINT AT 7, 2; INK 6; "darkness. Find the Heart."
40 PRINT AT 10, 2; INK 7; "Press any key to begin"
50 PAUSE 0
60 CLS
70 REM === define stats ===
80 LET h = 20: LET z = 20: LET a = 3: LET f = 2
90 REM === create dungeon grid ===
100 DIM d(16,16)
110 FOR i = 1 TO 16: FOR o = 1 TO 16
120 LET d(i,o) = 1
130 NEXT o: NEXT i
140 REM === display grid ===
150 FOR i = 1 TO 16: FOR o = 1 TO 16
160 IF d(i,o) = 1 THEN PRINT AT i + 2, o + 6; INK 4; CHR$ 143
170 IF d(i,o) = 0 THEN PRINT AT i + 2, o + 6; INK 7; "."
180 NEXT o: NEXT i
190 PRINT AT 20, 4; INK 7; "16x16 dungeon grid"
200 STOP
