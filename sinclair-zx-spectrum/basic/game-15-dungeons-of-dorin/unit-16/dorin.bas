5 REM === DUNGEONS OF DORIN ===
10 BORDER 0: PAPER 0: INK 7: CLS
15 GO SUB 2500
20 DIM d(16,16): DIM v(16,16)
22 DIM j(5): DIM k(5): DIM l(5): DIM n(5)
24 LET h = 20: LET z = 20: LET a = 3: LET f = 2
26 LET g = 0: LET e = 1: LET q = 0: LET b = 0
30 REM e=floor, q=kills, b=turns
40 REM === generate floor ===
42 FOR i = 1 TO 16: FOR o = 1 TO 16
44 LET d(i,o) = 1: LET v(i,o) = 0
46 NEXT o: NEXT i
48 REM place rooms
50 LET s = INT (RND * 3) + 3
52 DIM u(5,4)
54 FOR i = 1 TO s
56 LET u(i,1) = INT (RND * 10) + 2
58 LET u(i,2) = INT (RND * 10) + 2
60 LET u(i,3) = INT (RND * 4) + 3
62 LET u(i,4) = INT (RND * 4) + 3
64 FOR c = u(i,2) TO u(i,2) + u(i,4) - 1
66 FOR o = u(i,1) TO u(i,1) + u(i,3) - 1
68 IF c >= 1 AND c <= 16 AND o >= 1 AND o <= 16 THEN LET d(c,o) = 0
70 NEXT o: NEXT c
72 NEXT i
74 REM connect rooms with corridors
76 FOR i = 1 TO s - 1
78 LET t = u(i,1) + INT (u(i,3) / 2)
80 LET t2 = u(i,2) + INT (u(i,4) / 2)
82 LET t3 = u(i+1,1) + INT (u(i+1,3) / 2)
84 LET t4 = u(i+1,2) + INT (u(i+1,4) / 2)
86 REM horizontal corridor
88 IF t <= t3 THEN FOR o = t TO t3: IF t2 >= 1 AND t2 <= 16 AND o >= 1 AND o <= 16 THEN LET d(t2,o) = 0
90 IF t <= t3 THEN NEXT o
92 IF t > t3 THEN FOR o = t3 TO t: IF t2 >= 1 AND t2 <= 16 AND o >= 1 AND o <= 16 THEN LET d(t2,o) = 0
94 IF t > t3 THEN NEXT o
96 REM vertical corridor
98 IF t2 <= t4 THEN FOR c = t2 TO t4: IF c >= 1 AND c <= 16 AND t3 >= 1 AND t3 <= 16 THEN LET d(c,t3) = 0
100 IF t2 <= t4 THEN NEXT c
102 IF t2 > t4 THEN FOR c = t4 TO t2: IF c >= 1 AND c <= 16 AND t3 >= 1 AND t3 <= 16 THEN LET d(c,t3) = 0
104 IF t2 > t4 THEN NEXT c
106 NEXT i
108 REM place player in first room
110 LET x = u(1,1) + 1: LET y = u(1,2) + 1
112 REM place stairs in last room
114 LET t = u(s,1) + 1: LET t2 = u(s,2) + 1
116 IF t >= 1 AND t <= 16 AND t2 >= 1 AND t2 <= 16 THEN LET d(t2,t) = 2
118 REM place monsters
120 LET t = INT (RND * 3) + 2
122 IF t > 5 THEN LET t = 5
124 LET m = t
126 FOR i = 1 TO m
128 GO SUB 1600
130 LET j(i) = t: LET k(i) = t2
132 GO SUB 1700
134 NEXT i
146 GO SUB 380
148 CLS
150 GO SUB 300
152 GO SUB 500
154 REM === main loop ===
156 PAUSE 0: LET i$ = INKEY$
158 LET b = b + 1
160 LET t = x: LET t2 = y
162 IF i$ = "q" OR i$ = "Q" THEN LET t2 = y - 1
164 IF i$ = "a" OR i$ = "A" THEN LET t2 = y + 1
166 IF i$ = "o" OR i$ = "O" THEN LET t = x - 1
168 IF i$ = "p" OR i$ = "P" THEN LET t = x + 1
170 IF t = x AND t2 = y THEN GO TO 154
172 IF t < 1 OR t > 16 OR t2 < 1 OR t2 > 16 THEN GO TO 154
174 IF t < 1 OR t > 16 OR t2 < 1 OR t2 > 16 THEN GO TO 154
176 IF d(t2,t) = 1 THEN GO TO 154
178 REM check monster collision
180 FOR c = 1 TO m
182 IF j(c) = t AND k(c) = t2 AND n(c) > 0 THEN LET i = c: GO SUB 800: GO TO 196
184 NEXT c
186 LET x = t: LET y = t2
190 REM check stairs
192 IF d(y,x) = 2 THEN GO SUB 600: GO TO 154
196 GO SUB 380
198 GO SUB 300
199 GO SUB 500
200 GO TO 154
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
320 REM check monsters at this cell
322 FOR s = 1 TO m
324 IF j(s) = t AND k(s) = t2 AND n(s) > 0 THEN LET i2 = 2: LET i = 5
326 NEXT s
340 LET t3 = 3 + c: LET t4 = 11 + o
342 IF o = 0 AND c = 0 THEN LET i2 = 7: LET i = 6
344 IF i2 = 0 THEN PRINT AT t3, t4; " ": GO TO 370
346 IF i = 0 THEN PRINT AT t3, t4; INK i2; ".": GO TO 370
348 IF i = 1 THEN PRINT AT t3, t4; INK i2; CHR$ 143: GO TO 370
350 IF i = 2 THEN PRINT AT t3, t4; INK i2; ">": GO TO 370
352 IF i = 5 THEN PRINT AT t3, t4; INK i2; "M": GO TO 370
354 IF i = 6 THEN PRINT AT t3, t4; INK i2; "@": GO TO 370
356 PRINT AT t3, t4; INK i2; "?"
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
610 GO TO 40
800 REM === combat ===
802 LET i5 = l(i)
804 RESTORE 1500
806 FOR c = 1 TO i5 - 1: READ i$, t, t2, t3, t4: NEXT c
808 READ i$, t, t2, t3, t4
810 LET i4 = n(i)
812 CLS
814 PRINT AT 0, 0; INK 2; BRIGHT 1; "COMBAT: "; i$
816 PRINT AT 2, 0; INK 7; "Your HP: "; h; "  Enemy HP: "; i4
820 REM combat loop
822 PRINT AT 5, 0; INK 7; "A)ttack  F)lee"
824 PAUSE 0: LET i$ = INKEY$
826 IF i$ = "f" OR i$ = "F" THEN GO TO 870
828 IF i$ <> "a" AND i$ <> "A" THEN GO TO 824
830 REM player attacks
832 LET c = INT (RND * 6) + 1 + a - t3
834 IF c < 1 THEN LET c = 1
836 LET i4 = i4 - c
838 PRINT AT 8, 0; INK 4; "You hit for "; c; "!    "
840 IF i4 <= 0 THEN GO TO 890
844 REM monster attacks
846 LET c = INT (RND * 6) + 1 + t2 - f
848 IF c < 1 THEN LET c = 1
850 LET h = h - c
852 PRINT AT 10, 0; INK 2; "Enemy hits for "; c; "!    "
854 IF h <= 0 THEN GO TO 1000
856 PRINT AT 2, 0; INK 7; "Your HP: "; h; "  Enemy HP: "; i4; "  "
858 PAUSE 20
860 GO TO 820
870 REM flee
872 IF RND > 0.5 THEN PRINT AT 8, 0; INK 6; "You escape!      ": PAUSE 20: CLS: RETURN
874 PRINT AT 8, 0; INK 2; "Cannot flee!     "
876 LET c = INT (RND * 6) + 1 + t2 - f
878 IF c < 1 THEN LET c = 1
880 LET h = h - c
882 PRINT AT 10, 0; INK 2; "Hit for "; c; "!        "
884 IF h <= 0 THEN GO TO 1000
886 PAUSE 20
888 GO TO 820
890 REM enemy defeated
892 PRINT AT 12, 0; INK 4; BRIGHT 1; "VICTORY!"
894 LET n(i) = 0
896 LET g = g + t4: LET q = q + 1
898 PRINT AT 14, 0; INK 6; "Gained "; t4; " gold"
900 PAUSE 30
902 CLS
904 RETURN
1000 REM === death ===
1002 CLS
1004 PRINT AT 6, 6; INK 2; BRIGHT 1; "YOU HAVE FALLEN"
1006 PRINT AT 8, 4; INK 7; "Floor: "; e; "  Kills: "; q
1008 PRINT AT 10, 4; INK 6; "Gold: "; g; "  Turns: "; b
1010 PRINT AT 14, 6; INK 7; "Press any key"
1012 PAUSE 0
1014 GO TO 15
1100 REM === victory ===
1102 CLS
1104 PRINT AT 4, 3; INK 7; BRIGHT 1; "THE HEART OF DORIN!"
1106 PRINT AT 6, 2; INK 6; "You found the ancient"
1108 PRINT AT 7, 2; INK 6; "heart and restored Dorin!"
1110 PRINT AT 9, 4; INK 7; "Floors: 10"
1112 PRINT AT 10, 4; INK 7; "Kills: "; q
1114 PRINT AT 11, 4; INK 6; "Gold: "; g
1116 PRINT AT 12, 4; INK 7; "Turns: "; b
1118 PRINT AT 16, 6; INK 7; "Press any key"
1120 PAUSE 0
1122 STOP
1500 REM === MONSTER DATA ===
1502 DATA "Rat", 4, 1, 0, 2
1504 DATA "Goblin", 8, 2, 1, 5
1506 DATA "Skeleton", 12, 3, 2, 8
1508 DATA "Troll", 18, 4, 2, 12
1510 DATA "Wraith", 15, 5, 1, 15
1512 DATA "Dragon", 30, 6, 4, 50
1600 REM === find empty cell ===
1602 LET t = INT (RND * 14) + 2
1604 LET t2 = INT (RND * 14) + 2
1606 IF d(t2,t) <> 0 THEN GO TO 1602
1608 IF t = x AND t2 = y THEN GO TO 1602
1610 RETURN
1700 REM === pick monster for slot i ===
1702 IF e <= 3 THEN LET t = INT (RND * 2) + 1: GO TO 1720
1704 IF e <= 5 THEN LET t = INT (RND * 3) + 1: GO TO 1720
1706 IF e <= 7 THEN LET t = INT (RND * 4) + 2: GO TO 1720
1708 IF e <= 9 THEN LET t = INT (RND * 4) + 3: GO TO 1720
1710 LET t = 6
1720 LET l(i) = t
1722 RESTORE 1500
1724 FOR c = 1 TO t - 1: READ i$, t2, t3, t4, t5: NEXT c
1726 READ i$, t2, t3, t4, t5
1728 LET n(i) = t2
1730 RETURN
2500 REM === title screen ===
2510 PRINT AT 3, 4; INK 7; BRIGHT 1; "DUNGEONS OF DORIN"
2520 PRINT AT 6, 2; INK 6; "Descend ten floors of"
2525 PRINT AT 7, 2; INK 6; "darkness. Find the Heart."
2530 PRINT AT 9, 2; INK 7; "Q/A = up/down"
2535 PRINT AT 10, 2; INK 7; "O/P = left/right"
2550 PRINT AT 13, 2; INK 5; "Monsters grow stronger"
2555 PRINT AT 14, 2; INK 5; "on deeper floors."
2570 PRINT AT 16, 2; INK 4; "@ = you  M = monster"
2575 PRINT AT 17, 2; INK 4; "> = stairs"
2580 PRINT AT 20, 6; INK 7; "Press any key"
2590 PAUSE 0
2595 CLS
2598 RETURN
