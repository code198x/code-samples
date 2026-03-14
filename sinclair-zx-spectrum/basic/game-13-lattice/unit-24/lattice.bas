5 REM === PUZZLE SELECT ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM x(14): DIM y(14)
25 DIM f(14): DIM g(14)
26 DIM u(20)
30 LET sc = 0: LET pz = 1: LET tp = 5
35 LET up = 0: LET uc = 0: LET rc = 0
38 GO SUB 2000
50 REM === load puzzle ===
55 RESTORE 1500
60 FOR i = 1 TO pz - 1
65 READ nn
70 FOR j = 1 TO nn: READ a, b: NEXT j
75 READ nc
80 FOR j = 1 TO nc: READ a, b: NEXT j
85 NEXT i
90 READ nn
95 FOR i = 1 TO nn: READ x(i), y(i): NEXT i
100 READ nc
105 FOR i = 1 TO nc: READ f(i), g(i): NEXT i
110 LET cn = 1: LET s1 = 0: LET dn = 0
115 LET uc = 0: LET rc = 0: LET up = 0
120 CLS
125 GO SUB 400
130 GO SUB 450
135 GO SUB 500
140 REM === game loop ===
145 PAUSE 0: LET k$ = INKEY$
150 IF k$ = "q" OR k$ = "Q" THEN LET d = 1: GO TO 200
155 IF k$ = "a" OR k$ = "A" THEN LET d = 2: GO TO 200
160 IF k$ = "o" OR k$ = "O" THEN LET d = 3: GO TO 200
165 IF k$ = "p" OR k$ = "P" THEN LET d = 4: GO TO 200
170 IF k$ = " " THEN GO TO 250
175 IF k$ = "d" OR k$ = "D" THEN GO SUB 1200: GO TO 140
180 GO TO 140
200 REM === move cursor ===
205 LET bx = -1: LET bd = 99999
210 FOR i = 1 TO nn
215 IF i = cn THEN GO TO 240
220 LET dx = x(i) - x(cn): LET dy = y(i) - y(cn)
225 IF d = 1 AND dy <= 0 THEN GO TO 240
226 IF d = 2 AND dy >= 0 THEN GO TO 240
227 IF d = 3 AND dx >= 0 THEN GO TO 240
228 IF d = 4 AND dx <= 0 THEN GO TO 240
230 LET dd = dx * dx + dy * dy
235 IF dd < bd THEN LET bd = dd: LET bx = i
240 NEXT i
242 IF bx = -1 THEN GO TO 140
245 GO SUB 465: LET cn = bx: GO SUB 450
247 GO TO 140
250 REM === select node ===
255 IF s1 = 0 THEN LET s1 = cn: BEEP 0.02, 15: GO TO 140
260 IF cn = s1 THEN LET s1 = 0: GO TO 140
265 GO SUB 700
270 LET s1 = 0
275 GO TO 140
300 REM === draw one node ===
305 IF x(a) < 4 OR x(a) > 251 THEN RETURN
310 CIRCLE INK i; x(a), y(a), 3
315 RETURN
400 REM === draw all nodes ===
405 FOR a = 1 TO nn
410 LET i = 7
415 GO SUB 300
420 NEXT a
425 RETURN
450 REM === draw cursor ===
455 CIRCLE INK 6; x(cn), y(cn), 6
460 RETURN
465 REM === erase cursor ===
470 CIRCLE INK 0; x(cn), y(cn), 6
475 RETURN
500 REM === draw HUD ===
505 PRINT AT 21, 0; INK 7; "PZ "; pz; "/"; tp; " LINES "; dn; "/"; nc; " SC:"; sc; "   "
510 RETURN
700 REM === attempt connection ===
705 LET sn = cn
710 LET mi = 0
715 FOR i = 1 TO nc
720 IF (f(i) = s1 AND g(i) = sn) OR (f(i) = sn AND g(i) = s1) THEN LET mi = i
725 NEXT i
730 IF mi = 0 THEN PRINT AT 20, 0; INK 2; "Not a required connection      ": LET rc = rc + 1: RETURN
740 FOR j = 1 TO up
745 IF u(j) = mi THEN PRINT AT 20, 0; INK 6; "Already connected              ": RETURN
750 NEXT j
760 LET cx = 0
765 LET sx = x(f(mi)): LET sy = y(f(mi))
770 LET ex = x(g(mi)): LET ey = y(g(mi))
775 LET st = 20
780 LET dx = (ex - sx) / st: LET dy = (ey - sy) / st
785 LET tx = sx + dx * 3: LET ty = sy + dy * 3
790 FOR j = 4 TO st - 3
795 LET tx = tx + dx: LET ty = ty + dy
800 LET px = INT tx: LET py = INT ty
805 IF px < 0 OR px > 255 OR py < 0 OR py > 175 THEN GO TO 815
807 LET ar = 21 - INT (py / 8): LET ac = INT (px / 8)
808 LET av = ATTR (ar, ac): LET ik = av - 8 * INT (av / 8)
810 IF ik = 4 OR ik = 5 OR ik = 3 THEN LET cx = 1
815 NEXT j
820 IF cx = 1 THEN GO TO 870
830 LET ci = 4: IF pz > 3 THEN LET ci = 5
835 PLOT INK ci; sx, sy: DRAW INK ci; ex - sx, ey - sy
840 LET up = up + 1: LET u(up) = mi
845 LET dn = dn + 1
847 BEEP 0.05, 5 + dn * 2
850 PRINT AT 20, 0; INK ci; "Connected!                     "
852 GO SUB 500
855 IF dn = nc THEN GO SUB 900
860 RETURN
870 REM === crossing rejected with animation ===
875 PLOT INK 2; sx, sy: DRAW INK 2; ex - sx, ey - sy
877 BEEP 0.1, -10
880 PAUSE 15
885 PLOT INK 0; sx, sy: DRAW INK 0; ex - sx, ey - sy
890 LET a = f(mi): LET i = 7: GO SUB 300
892 LET a = g(mi): LET i = 7: GO SUB 300
895 PRINT AT 20, 0; INK 2; "Lines would cross!             "
897 LET rc = rc + 1
899 RETURN
900 REM === puzzle complete ===
905 PRINT AT 20, 0; INK 7; BRIGHT 1; "PUZZLE COMPLETE!               "
910 LET sc = sc + 100
912 LET st = 1
915 IF uc = 0 THEN LET sc = sc + 50: LET st = 2
917 IF uc = 0 AND rc = 0 THEN LET sc = sc + 25: LET st = 3
920 PRINT AT 20, 20; INK 6;
922 FOR i = 1 TO st: PRINT "*";: NEXT i
925 IF st = 1 THEN PRINT AT 19, 18; INK 6; "complete"
926 IF st = 2 THEN PRINT AT 19, 18; INK 6; "no undo!"
927 IF st = 3 THEN PRINT AT 19, 16; INK 6; "clean solve!"
930 BEEP 0.1, 12: BEEP 0.1, 16: BEEP 0.2, 19
935 GO SUB 500
940 PAUSE 0
945 LET pz = pz + 1
950 IF pz > tp THEN GO TO 970
955 GO TO 50
970 CLS
975 PRINT AT 10, 6; INK 7; BRIGHT 1; "ALL PUZZLES DONE!"
980 PRINT AT 12, 8; INK 7; "Score: "; sc
985 PAUSE 0
990 STOP
1200 REM === undo ===
1205 IF up = 0 THEN RETURN
1210 LET mi = u(up)
1215 LET sx = x(f(mi)): LET sy = y(f(mi))
1220 LET ex = x(g(mi)): LET ey = y(g(mi))
1225 PLOT INK 0; sx, sy: DRAW INK 0; ex - sx, ey - sy
1230 LET a = f(mi): LET i = 7: GO SUB 300
1235 LET a = g(mi): LET i = 7: GO SUB 300
1240 LET up = up - 1: LET dn = dn - 1
1245 LET uc = uc + 1
1250 BEEP 0.05, -5
1255 GO SUB 500
1260 RETURN
1500 REM === PUZZLE DATA ===
1510 DATA 4
1515 DATA 64,120, 192,120, 64,60, 192,60
1520 DATA 3
1525 DATA 1,2, 3,4, 1,3
1530 DATA 5
1535 DATA 50,120, 128,120, 206,120, 90,60, 166,60
1540 DATA 4
1545 DATA 1,2, 2,3, 4,5, 1,4
1550 DATA 5
1555 DATA 50,120, 128,140, 206,120, 90,60, 166,60
1560 DATA 5
1565 DATA 1,2, 2,3, 4,5, 1,4, 3,5
1570 DATA 6
1575 DATA 50,130, 128,130, 206,130, 50,60, 128,60, 206,60
1580 DATA 5
1585 DATA 1,2, 2,3, 4,5, 5,6, 1,4
1590 DATA 6
1595 DATA 80,140, 176,140, 40,90, 216,90, 80,40, 176,40
1600 DATA 5
1605 DATA 1,2, 3,4, 5,6, 1,3, 2,4
2000 REM === puzzle select screen ===
2005 CLS
2010 PRINT AT 3, 8; INK 7; BRIGHT 1; "SELECT PUZZLE"
2020 PRINT AT 6, 3; INK 6; "Use Q/A to choose, SPACE to start"
2030 FOR i = 1 TO tp
2035 LET c = 7: IF i = pz THEN LET c = 6
2040 PRINT AT 7 + i, 10; INK c; "Puzzle "; i
2050 NEXT i
2060 PAUSE 0: LET k$ = INKEY$
2070 IF k$ = "q" OR k$ = "Q" THEN IF pz > 1 THEN PRINT AT 7 + pz, 10; INK 7; "Puzzle "; pz: LET pz = pz - 1: PRINT AT 7 + pz, 10; INK 6; "Puzzle "; pz
2080 IF k$ = "a" OR k$ = "A" THEN IF pz < tp THEN PRINT AT 7 + pz, 10; INK 7; "Puzzle "; pz: LET pz = pz + 1: PRINT AT 7 + pz, 10; INK 6; "Puzzle "; pz
2090 IF k$ = " " THEN RETURN
2095 GO TO 2060
