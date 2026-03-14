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
90 REM === generate floor ===
92 GO SUB 1000
94 REM === display grid ===
96 FOR i = 1 TO 16: FOR o = 1 TO 16
98 IF d(i,o) = 1 THEN PRINT AT i + 2, o + 6; INK 4; CHR$ 143
100 IF d(i,o) = 0 THEN PRINT AT i + 2, o + 6; INK 7; "."
102 NEXT o: NEXT i
104 PRINT AT 20, 2; INK 7; "Dungeon generated! "; s; " rooms"
106 PRINT AT 21, 2; INK 6; "Press a key to regenerate"
108 PAUSE 0
110 CLS
112 GO TO 90
1000 REM === generate floor subroutine ===
1002 DIM d(16,16)
1004 FOR i = 1 TO 16: FOR o = 1 TO 16
1006 LET d(i,o) = 1
1008 NEXT o: NEXT i
1010 REM place rooms
1012 LET s = INT (RND * 3) + 3
1014 DIM u(5,4)
1016 FOR i = 1 TO s
1018 LET u(i,1) = INT (RND * 10) + 2
1020 LET u(i,2) = INT (RND * 10) + 2
1022 LET u(i,3) = INT (RND * 4) + 3
1024 LET u(i,4) = INT (RND * 4) + 3
1026 FOR c = u(i,2) TO u(i,2) + u(i,4) - 1
1028 FOR o = u(i,1) TO u(i,1) + u(i,3) - 1
1030 IF c >= 1 AND c <= 16 AND o >= 1 AND o <= 16 THEN LET d(c,o) = 0
1032 NEXT o: NEXT c
1034 NEXT i
1036 REM connect rooms with corridors
1038 FOR i = 1 TO s - 1
1040 LET t = u(i,1) + INT (u(i,3) / 2)
1042 LET t2 = u(i,2) + INT (u(i,4) / 2)
1044 LET t3 = u(i+1,1) + INT (u(i+1,3) / 2)
1046 LET t4 = u(i+1,2) + INT (u(i+1,4) / 2)
1048 IF t <= t3 THEN FOR o = t TO t3: IF t2 >= 1 AND t2 <= 16 AND o >= 1 AND o <= 16 THEN LET d(t2,o) = 0
1050 IF t <= t3 THEN NEXT o
1052 IF t > t3 THEN FOR o = t3 TO t: IF t2 >= 1 AND t2 <= 16 AND o >= 1 AND o <= 16 THEN LET d(t2,o) = 0
1054 IF t > t3 THEN NEXT o
1056 IF t2 <= t4 THEN FOR c = t2 TO t4: IF c >= 1 AND c <= 16 AND t3 >= 1 AND t3 <= 16 THEN LET d(c,t3) = 0
1058 IF t2 <= t4 THEN NEXT c
1060 IF t2 > t4 THEN FOR c = t4 TO t2: IF c >= 1 AND c <= 16 AND t3 >= 1 AND t3 <= 16 THEN LET d(c,t3) = 0
1062 IF t2 > t4 THEN NEXT c
1064 NEXT i
1066 RETURN
