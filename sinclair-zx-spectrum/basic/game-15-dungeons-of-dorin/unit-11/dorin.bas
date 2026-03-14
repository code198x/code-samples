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
82 LET g = 0: LET e = 1
84 DIM d(16,16): DIM v(16,16)
90 REM === generate floor ===
92 GO SUB 1000
94 LET x = u(1,1) + 1: LET y = u(1,2) + 1
96 REM place stairs in last room
98 LET t = u(s,1) + 1: LET t2 = u(s,2) + 1
100 IF t >= 1 AND t <= 16 AND t2 >= 1 AND t2 <= 16 THEN LET d(t2,t) = 2
102 GO SUB 380
104 CLS
106 GO SUB 300
108 GO SUB 500
110 REM === main loop ===
112 PAUSE 0: LET i$ = INKEY$
114 LET t = x: LET t2 = y
116 IF i$ = "q" OR i$ = "Q" THEN LET t2 = y - 1
118 IF i$ = "a" OR i$ = "A" THEN LET t2 = y + 1
120 IF i$ = "o" OR i$ = "O" THEN LET t = x - 1
122 IF i$ = "p" OR i$ = "P" THEN LET t = x + 1
124 IF t = x AND t2 = y THEN GO TO 110
126 IF t < 1 OR t > 16 OR t2 < 1 OR t2 > 16 THEN GO TO 110
128 IF d(t2,t) = 1 THEN GO TO 110
130 LET x = t: LET y = t2
132 REM check stairs
134 IF d(y,x) = 2 THEN GO SUB 600: GO TO 110
136 GO SUB 380
138 GO SUB 300
140 GO SUB 500
142 GO TO 110
300 REM === draw viewport ===
302 FOR c = -3 TO 3
304 FOR o = -3 TO 3
306 LET t = x + o: LET t2 = y + c
308 LET i = 1: LET i2 = 0
310 IF t < 1 OR t > 16 OR t2 < 1 OR t2 > 16 THEN GO TO 340
312 IF v(t2,t) = 0 THEN GO TO 340
314 LET i = d(t2,t)
316 LET i2 = 7
318 IF i = 1 THEN LET i2 = 4
340 LET t3 = 3 + c: LET t4 = 11 + o
342 IF o = 0 AND c = 0 THEN LET i2 = 7: LET i = 6
344 IF i2 = 0 THEN PRINT AT t3, t4; " ": GO TO 370
346 IF i = 0 THEN PRINT AT t3, t4; INK i2; ".": GO TO 370
348 IF i = 1 THEN PRINT AT t3, t4; INK i2; CHR$ 143: GO TO 370
350 IF i = 2 THEN PRINT AT t3, t4; INK i2; ">": GO TO 370
352 IF i = 6 THEN PRINT AT t3, t4; INK i2; "@": GO TO 370
354 PRINT AT t3, t4; INK i2; "?"
370 NEXT o: NEXT c
372 RETURN
380 REM === update visibility ===
382 FOR c = y - 2 TO y + 2
384 FOR o = x - 2 TO x + 2
386 IF c >= 1 AND c <= 16 AND o >= 1 AND o <= 16 THEN LET v(c,o) = 1
388 NEXT o: NEXT c
390 RETURN
500 REM === draw status ===
502 PRINT AT 8, 2; INK 7; "HP:"; h; "/"; z; "  "
504 PRINT AT 9, 2; INK 4; "AT:"; a; "  "
506 PRINT AT 10, 2; INK 5; "DF:"; f; "  "
508 PRINT AT 8, 20; INK 6; "FL:"; e; " "
510 PRINT AT 9, 20; INK 6; "AU:"; g; "  "
514 RETURN
600 REM === stairs down ===
602 LET e = e + 1
604 IF e > 10 THEN GO TO 1100
606 PRINT AT 12, 5; INK 7; BRIGHT 1; "DESCENDING..."
608 PAUSE 30
610 GO TO 90
1000 REM === generate floor subroutine ===
1002 FOR i = 1 TO 16: FOR o = 1 TO 16
1004 LET d(i,o) = 1: LET v(i,o) = 0
1006 NEXT o: NEXT i
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
1100 REM === victory (placeholder) ===
1102 CLS
1104 PRINT AT 8, 4; INK 7; BRIGHT 1; "YOU FOUND THE HEART!"
1106 PRINT AT 12, 6; INK 7; "Press any key"
1108 PAUSE 0
1110 STOP
