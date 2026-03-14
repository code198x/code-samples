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
270 REM === connect rooms with corridors ===
280 FOR i = 1 TO s - 1
290 LET t = u(i,1) + INT (u(i,3) / 2)
300 LET t2 = u(i,2) + INT (u(i,4) / 2)
310 LET t3 = u(i+1,1) + INT (u(i+1,3) / 2)
320 LET t4 = u(i+1,2) + INT (u(i+1,4) / 2)
330 REM horizontal corridor
340 IF t <= t3 THEN FOR o = t TO t3: IF t2 >= 1 AND t2 <= 16 AND o >= 1 AND o <= 16 THEN LET d(t2,o) = 0
350 IF t <= t3 THEN NEXT o
360 IF t > t3 THEN FOR o = t3 TO t: IF t2 >= 1 AND t2 <= 16 AND o >= 1 AND o <= 16 THEN LET d(t2,o) = 0
370 IF t > t3 THEN NEXT o
380 REM vertical corridor
390 IF t2 <= t4 THEN FOR c = t2 TO t4: IF c >= 1 AND c <= 16 AND t3 >= 1 AND t3 <= 16 THEN LET d(c,t3) = 0
400 IF t2 <= t4 THEN NEXT c
410 IF t2 > t4 THEN FOR c = t4 TO t2: IF c >= 1 AND c <= 16 AND t3 >= 1 AND t3 <= 16 THEN LET d(c,t3) = 0
420 IF t2 > t4 THEN NEXT c
430 NEXT i
440 REM === display grid ===
450 FOR i = 1 TO 16: FOR o = 1 TO 16
460 IF d(i,o) = 1 THEN PRINT AT i + 2, o + 6; INK 4; CHR$ 143
470 IF d(i,o) = 0 THEN PRINT AT i + 2, o + 6; INK 7; "."
480 NEXT o: NEXT i
490 PRINT AT 20, 2; INK 7; s; " rooms connected"
500 STOP
