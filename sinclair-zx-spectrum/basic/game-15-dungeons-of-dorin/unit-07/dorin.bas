5 REM === DUNGEONS OF DORIN ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 PRINT AT 3, 4; INK 7; BRIGHT 1; "DUNGEONS OF DORIN"
30 PRINT AT 6, 2; INK 6; "Descend ten floors of"
35 PRINT AT 7, 2; INK 6; "darkness. Find the Heart."
40 PRINT AT 10, 2; INK 7; "Q/A = up/down"
42 PRINT AT 11, 2; INK 7; "O/P = left/right"
44 PRINT AT 14, 2; INK 7; "Press any key to begin"
50 PAUSE 0
60 CLS
70 REM === define stats ===
80 LET h = 20: LET z = 20: LET a = 3: LET f = 2
90 REM === generate floor ===
92 GO SUB 1000
94 LET x = u(1,1) + 1: LET y = u(1,2) + 1
96 REM === draw full grid ===
98 GO SUB 1100
100 REM === main loop ===
102 PAUSE 0: LET i$ = INKEY$
104 LET t = x: LET t2 = y
106 IF i$ = "q" OR i$ = "Q" THEN LET t2 = y - 1
108 IF i$ = "a" OR i$ = "A" THEN LET t2 = y + 1
110 IF i$ = "o" OR i$ = "O" THEN LET t = x - 1
112 IF i$ = "p" OR i$ = "P" THEN LET t = x + 1
114 IF t = x AND t2 = y THEN GO TO 100
116 IF t < 1 OR t > 16 OR t2 < 1 OR t2 > 16 THEN GO TO 100
118 IF d(t2,t) = 1 THEN GO TO 100
120 REM erase old position
122 PRINT AT y + 2, x + 6; INK 7; "."
124 LET x = t: LET y = t2
126 PRINT AT y + 2, x + 6; INK 7; BRIGHT 1; "@"
128 GO TO 100
1000 REM === generate floor subroutine ===
1002 DIM d(16,16)
1004 FOR i = 1 TO 16: FOR o = 1 TO 16
1006 LET d(i,o) = 1
1008 NEXT o: NEXT i
1010 LET s = INT (RND * 3) + 3
1012 DIM u(5,4)
1014 FOR i = 1 TO s
1016 LET u(i,1) = INT (RND * 10) + 2
1018 LET u(i,2) = INT (RND * 10) + 2
1020 LET u(i,3) = INT (RND * 4) + 3
1022 LET u(i,4) = INT (RND * 4) + 3
1024 FOR c = u(i,2) TO u(i,2) + u(i,4) - 1
1026 FOR o = u(i,1) TO u(i,1) + u(i,3) - 1
1028 IF c >= 1 AND c <= 16 AND o >= 1 AND o <= 16 THEN LET d(c,o) = 0
1030 NEXT o: NEXT c
1032 NEXT i
1034 FOR i = 1 TO s - 1
1036 LET t = u(i,1) + INT (u(i,3) / 2)
1038 LET t2 = u(i,2) + INT (u(i,4) / 2)
1040 LET t3 = u(i+1,1) + INT (u(i+1,3) / 2)
1042 LET t4 = u(i+1,2) + INT (u(i+1,4) / 2)
1044 IF t <= t3 THEN FOR o = t TO t3: IF t2 >= 1 AND t2 <= 16 AND o >= 1 AND o <= 16 THEN LET d(t2,o) = 0
1046 IF t <= t3 THEN NEXT o
1048 IF t > t3 THEN FOR o = t3 TO t: IF t2 >= 1 AND t2 <= 16 AND o >= 1 AND o <= 16 THEN LET d(t2,o) = 0
1050 IF t > t3 THEN NEXT o
1052 IF t2 <= t4 THEN FOR c = t2 TO t4: IF c >= 1 AND c <= 16 AND t3 >= 1 AND t3 <= 16 THEN LET d(c,t3) = 0
1054 IF t2 <= t4 THEN NEXT c
1056 IF t2 > t4 THEN FOR c = t4 TO t2: IF c >= 1 AND c <= 16 AND t3 >= 1 AND t3 <= 16 THEN LET d(c,t3) = 0
1058 IF t2 > t4 THEN NEXT c
1060 NEXT i
1062 RETURN
1100 REM === draw full grid ===
1102 FOR i = 1 TO 16: FOR o = 1 TO 16
1104 IF d(i,o) = 1 THEN PRINT AT i + 2, o + 6; INK 4; CHR$ 143
1106 IF d(i,o) = 0 THEN PRINT AT i + 2, o + 6; INK 7; "."
1108 NEXT o: NEXT i
1110 PRINT AT y + 2, x + 6; INK 7; BRIGHT 1; "@"
1112 RETURN
