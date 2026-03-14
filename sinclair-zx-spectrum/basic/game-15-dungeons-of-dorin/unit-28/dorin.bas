5 REM === DUNGEONS OF DORIN ===
10 BORDER 0: PAPER 0: INK 7: CLS
15 GO SUB 2500
20 DIM d(16,16): DIM v(16,16)
22 DIM j(5): DIM k(5): DIM l(5): DIM n(5)
24 LET h = 20: LET z = 20: LET a = 3: LET f = 2
26 LET w = 0: LET r = 0: LET p = 0
28 LET g = 0: LET e = 1: LET q = 0: LET b = 0
40 REM === generate floor ===
42 FOR i = 1 TO 16: FOR o = 1 TO 16
44 LET d(i,o) = 1: LET v(i,o) = 0
46 NEXT o: NEXT i
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
76 FOR i = 1 TO s - 1
78 LET t = u(i,1) + INT (u(i,3) / 2)
80 LET t2 = u(i,2) + INT (u(i,4) / 2)
82 LET t3 = u(i+1,1) + INT (u(i+1,3) / 2)
84 LET t4 = u(i+1,2) + INT (u(i+1,4) / 2)
86 IF t <= t3 THEN FOR o = t TO t3: IF t2 >= 1 AND t2 <= 16 AND o >= 1 AND o <= 16 THEN LET d(t2,o) = 0
88 IF t <= t3 THEN NEXT o
90 IF t > t3 THEN FOR o = t3 TO t: IF t2 >= 1 AND t2 <= 16 AND o >= 1 AND o <= 16 THEN LET d(t2,o) = 0
92 IF t > t3 THEN NEXT o
94 IF t2 <= t4 THEN FOR c = t2 TO t4: IF c >= 1 AND c <= 16 AND t3 >= 1 AND t3 <= 16 THEN LET d(c,t3) = 0
96 IF t2 <= t4 THEN NEXT c
98 IF t2 > t4 THEN FOR c = t4 TO t2: IF c >= 1 AND c <= 16 AND t3 >= 1 AND t3 <= 16 THEN LET d(c,t3) = 0
100 IF t2 > t4 THEN NEXT c
102 NEXT i
108 LET x = u(1,1) + 1: LET y = u(1,2) + 1
110 LET t = u(s,1) + 1: LET t2 = u(s,2) + 1
112 IF t >= 1 AND t <= 16 AND t2 >= 1 AND t2 <= 16 THEN LET d(t2,t) = 2
114 LET t = INT (RND * 3) + 2
116 IF t > 5 THEN LET t = 5
118 LET m = t
120 FOR i = 1 TO m
122 GO SUB 1600
124 LET j(i) = t: LET k(i) = t2
126 GO SUB 1700
128 NEXT i
130 FOR i = 1 TO 2
132 GO SUB 1600
134 LET d(t2,t) = 3
136 NEXT i
138 IF e <= 5 AND RND > 0.4 THEN GO SUB 1600: LET d(t2,t) = 4
140 IF e > 5 AND RND > 0.7 THEN GO SUB 1600: LET d(t2,t) = 4
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
170 IF i$ = "h" OR i$ = "H" THEN GO SUB 700: GO TO 154
171 IF i$ = "i" OR i$ = "I" THEN GO SUB 1800: GO TO 154
172 IF t = x AND t2 = y THEN GO TO 154
174 IF t < 1 OR t > 16 OR t2 < 1 OR t2 > 16 THEN GO TO 154
176 IF d(t2,t) = 1 THEN GO TO 154
178 FOR c = 1 TO m
180 IF j(c) = t AND k(c) = t2 AND n(c) > 0 THEN LET i = c: GO SUB 800: GO TO 196
182 NEXT c
184 LET x = t: LET y = t2
186 BEEP 0.01, 5
188 IF d(y,x) = 2 THEN GO SUB 600: GO TO 154
190 IF d(y,x) = 3 THEN GO SUB 750: LET d(y,x) = 0
192 IF d(y,x) = 4 THEN LET h = z: LET d(y,x) = 0: PRINT AT 12, 3; INK 5; "Fountain! HP restored!"
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
320 FOR s = 1 TO m
322 IF j(s) = t AND k(s) = t2 AND n(s) > 0 THEN LET i2 = 2: LET i = 5
324 NEXT s
340 LET t3 = 3 + c: LET t4 = 11 + o
342 IF o = 0 AND c = 0 THEN LET i2 = 7: LET i = 6
344 IF i2 = 0 THEN PRINT AT t3, t4; " ": GO TO 370
346 IF i = 0 THEN PRINT AT t3, t4; INK i2; ".": GO TO 370
348 IF i = 1 THEN PRINT AT t3, t4; INK i2; CHR$ 143: GO TO 370
350 IF i = 2 THEN PRINT AT t3, t4; INK i2; ">": GO TO 370
352 IF i = 3 THEN PRINT AT t3, t4; INK i2; "$": GO TO 370
353 IF i = 4 THEN PRINT AT t3, t4; INK 5; "~": GO TO 370
354 IF i = 5 THEN PRINT AT t3, t4; INK i2; "M": GO TO 370
356 IF i = 6 THEN PRINT AT t3, t4; INK i2; "@": GO TO 370
358 PRINT AT t3, t4; INK i2; "?"
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
504 PRINT AT 9, 2; INK 4; "AT:"; a + w; "  "
506 PRINT AT 10, 2; INK 5; "DF:"; f + r; "  "
508 PRINT AT 8, 20; INK 6; "FL:"; e; " "
510 PRINT AT 9, 20; INK 6; "AU:"; g; "  "
512 PRINT AT 10, 20; INK 3; "PT:"; p; " "
514 RETURN
600 REM === stairs down ===
602 LET e = e + 1
604 IF e > 10 THEN GO TO 1100
606 PRINT AT 12, 5; INK 7; BRIGHT 1; "DESCENDING..."
608 BEEP 0.1, -5: BEEP 0.1, -10
610 PAUSE 30
612 GO TO 40
700 REM === use potion ===
702 IF p <= 0 THEN PRINT AT 12, 5; INK 2; "No potions!   ": RETURN
704 LET p = p - 1
706 LET h = h + 10
708 IF h > z THEN LET h = z
710 BEEP 0.05, 12: BEEP 0.05, 15
712 PRINT AT 12, 5; INK 4; "Healed! HP:"; h; "  "
714 RETURN
750 REM === open chest ===
752 LET i = INT (RND * 4)
754 IF i = 0 THEN LET t = INT (RND * 5) + e * 2: LET g = g + t: PRINT AT 12, 3; INK 6; "Found "; t; " gold!     ": GO TO 770
756 IF i = 1 AND p < 3 THEN LET p = p + 1: PRINT AT 12, 3; INK 4; "Found a potion!   ": GO TO 770
758 IF i = 2 THEN LET t = INT (e / 3) + 1: IF t > w THEN LET w = t: PRINT AT 12, 3; INK 7; "Better weapon! +"; w: GO TO 770
760 IF i = 3 THEN LET t = INT (e / 4) + 1: IF t > r THEN LET r = t: PRINT AT 12, 3; INK 5; "Better armour! +"; r: GO TO 770
762 LET t = INT (RND * 3) + e: LET g = g + t: PRINT AT 12, 3; INK 6; "Found "; t; " gold!     "
770 BEEP 0.05, 10
772 RETURN
800 REM === combat ===
802 LET i5 = l(i)
804 RESTORE 1500
806 FOR c = 1 TO i5 - 1: READ i$, t, t2, t3, t4: NEXT c
808 READ i$, t, t2, t3, t4
810 LET i4 = n(i)
812 CLS
814 PRINT AT 0, 0; INK 2; BRIGHT 1; "COMBAT: "; i$
816 PRINT AT 2, 0; INK 7; "Your HP: "; h; "  Enemy HP: "; i4
820 PRINT AT 5, 0; INK 7; "A)ttack  F)lee"
824 PAUSE 0: LET i$ = INKEY$
826 IF i$ = "f" OR i$ = "F" THEN GO TO 870
828 IF i$ <> "a" AND i$ <> "A" THEN GO TO 824
830 LET c = INT (RND * 6) + 1 + a + w - t3
832 IF c < 1 THEN LET c = 1
834 LET i4 = i4 - c
836 PRINT AT 8, 0; INK 4; "You hit for "; c; "!    "
838 BEEP 0.02, 5
840 IF i4 <= 0 THEN GO TO 890
844 LET c = INT (RND * 6) + 1 + t2 - f - r
846 IF c < 1 THEN LET c = 1
848 LET h = h - c
850 PRINT AT 10, 0; INK 2; "Enemy hits for "; c; "!    "
852 BEEP 0.02, -5
854 IF h <= 0 THEN GO TO 1000
856 PRINT AT 2, 0; INK 7; "Your HP: "; h; "  Enemy HP: "; i4; "  "
858 PAUSE 20
860 GO TO 820
870 IF RND > 0.5 THEN PRINT AT 8, 0; INK 6; "You escape!      ": BEEP 0.05, 10: PAUSE 20: CLS: RETURN
874 PRINT AT 8, 0; INK 2; "Cannot flee!     "
876 LET c = INT (RND * 6) + 1 + t2 - f - r
878 IF c < 1 THEN LET c = 1
880 LET h = h - c
882 PRINT AT 10, 0; INK 2; "Hit for "; c; "!        "
884 IF h <= 0 THEN GO TO 1000
886 PAUSE 20
888 GO TO 820
890 PRINT AT 12, 0; INK 4; BRIGHT 1; "VICTORY!"
892 LET n(i) = 0
894 LET g = g + t4: LET q = q + 1
896 BEEP 0.1, 12: BEEP 0.1, 16
898 PRINT AT 14, 0; INK 6; "Gained "; t4; " gold"
900 IF i5 >= 3 AND RND > 0.5 THEN LET t = INT (e / 3) + 1: IF t > w THEN LET w = t: PRINT AT 16, 0; INK 7; "Dropped a weapon! +"; w
902 PAUSE 30
904 CLS
906 RETURN
1000 REM === death ===
1002 CLS
1004 PRINT AT 6, 6; INK 2; BRIGHT 1; "YOU HAVE FALLEN"
1006 PRINT AT 8, 4; INK 7; "Floor: "; e; "  Kills: "; q
1008 PRINT AT 10, 4; INK 6; "Gold: "; g; "  Turns: "; b
1010 PRINT AT 14, 6; INK 7; "Press any key"
1012 BEEP 0.2, -10: BEEP 0.2, -15
1014 PAUSE 0
1016 GO TO 15
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
1120 BEEP 0.1, 12: BEEP 0.1, 16: BEEP 0.2, 19: BEEP 0.3, 24
1122 PAUSE 0
1124 STOP
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
1800 REM === inventory screen ===
1802 CLS
1804 PRINT AT 1, 5; INK 7; BRIGHT 1; "INVENTORY"
1806 PRINT AT 3, 2; INK 7; "HP: "; h; "/"; z
1808 PRINT AT 5, 2; INK 4; "Attack:  "; a; " + "; w; " = "; a + w
1810 PRINT AT 6, 2; INK 5; "Defence: "; f; " + "; r; " = "; f + r
1812 PRINT AT 8, 2; INK 6; "Gold: "; g
1814 PRINT AT 9, 2; INK 3; "Potions: "; p; "/3"
1816 PRINT AT 11, 2; INK 7; "Weapon bonus: +"; w
1818 PRINT AT 12, 2; INK 7; "Armour bonus: +"; r
1820 PRINT AT 14, 2; INK 6; "Floor: "; e; "  Kills: "; q
1822 PRINT AT 16, 2; INK 7; "Turns: "; b
1824 PRINT AT 18, 2; INK 7; "S = save game"
1826 PRINT AT 20, 4; INK 7; "Press any key"
1828 PAUSE 0: LET i$ = INKEY$
1830 IF i$ = "s" OR i$ = "S" THEN GO SUB 1900
1832 CLS
1834 RETURN
1900 REM === save game ===
1902 PRINT AT 20, 2; INK 4; "Saving...          "
1904 PAUSE 30
1906 PRINT AT 20, 2; INK 4; "Game saved!        "
1908 PAUSE 20
1910 RETURN
2500 REM === title screen ===
2510 PRINT AT 3, 4; INK 7; BRIGHT 1; "DUNGEONS OF DORIN"
2520 PRINT AT 6, 2; INK 6; "Descend ten floors of"
2525 PRINT AT 7, 2; INK 6; "darkness. Find the Heart."
2530 PRINT AT 9, 2; INK 7; "Q/A = up/down"
2535 PRINT AT 10, 2; INK 7; "O/P = left/right"
2540 PRINT AT 11, 2; INK 7; "H = use potion"
2542 PRINT AT 12, 2; INK 7; "I = inventory"
2550 PRINT AT 14, 2; INK 5; "Monsters grow stronger"
2555 PRINT AT 15, 2; INK 5; "on deeper floors."
2570 PRINT AT 17, 2; INK 4; "@ = you  M = monster"
2575 PRINT AT 18, 2; INK 4; "> = stairs  $ = chest"
2580 PRINT AT 20, 6; INK 7; "Press any key"
2590 PAUSE 0
2595 CLS
2598 RETURN
