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
140 REM === carve rooms ===
150 LET s = INT (RND * 3) + 3
160 DIM u(5,4)
170 FOR i = 1 TO s
180 LET u(i,1) = INT (RND * 10) + 2
190 LET u(i,2) = INT (RND * 10) + 2
200 LET u(i,3) = INT (RND * 4) + 3
210 LET u(i,4) = INT (RND * 4) + 3
220 FOR c = u(i,2) TO u(i,2) + u(i,4) - 1
230 FOR o = u(i,1) TO u(i,1) + u(i,3) - 1
240 IF c >= 1 AND c <= 16 AND o >= 1 AND o <= 16 THEN LET d(c,o) = 0
250 NEXT o: NEXT c
260 NEXT i
270 REM === display grid ===
280 FOR i = 1 TO 16: FOR o = 1 TO 16
290 IF d(i,o) = 1 THEN PRINT AT i + 2, o + 6; INK 4; CHR$ 143
300 IF d(i,o) = 0 THEN PRINT AT i + 2, o + 6; INK 7; "."
310 NEXT o: NEXT i
320 PRINT AT 20, 4; INK 7; s; " rooms carved"
330 STOP
