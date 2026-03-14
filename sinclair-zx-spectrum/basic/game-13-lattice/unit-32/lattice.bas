5 REM === LATTICE ===
10 BORDER 0: PAPER 0: INK 7: CLS
15 GO SUB 2500
20 DIM x(14): DIM y(14)
25 DIM f(14): DIM g(14)
30 DIM u(20)
35 LET sc = 0: LET pz = 1: LET tp = 15
40 LET up = 0: LET uc = 0: LET rc = 0
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
735 REM check already drawn
740 FOR j = 1 TO up
745 IF u(j) = mi THEN PRINT AT 20, 0; INK 6; "Already connected              ": RETURN
750 NEXT j
755 REM check crossing
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
825 REM draw valid line
830 LET ci = 4
832 IF pz > 8 THEN LET ci = 5
835 PLOT INK ci; sx, sy: DRAW INK ci; ex - sx, ey - sy
840 LET up = up + 1: LET u(up) = mi
845 LET dn = dn + 1
847 BEEP 0.05, 5 + dn * 2
850 PRINT AT 20, 0; INK 4; "Connected!                     "
852 GO SUB 500
855 IF dn = nc THEN GO SUB 900
860 RETURN
870 REM crossing rejected
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
925 BEEP 0.1, 12: BEEP 0.1, 16: BEEP 0.2, 19
930 GO SUB 500
935 PAUSE 0
940 LET pz = pz + 1
945 IF pz > tp THEN GO TO 970
950 GO TO 50
970 REM === game over ===
975 CLS
980 PRINT AT 8, 8; INK 7; BRIGHT 1; "CONGRATULATIONS!"
982 PRINT AT 10, 5; INK 6; "All "; tp; " puzzles solved!"
985 PRINT AT 12, 5; INK 7; "Final score: "; sc
990 PRINT AT 16, 6; INK 7; "Press any key"
995 PAUSE 0
997 STOP
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
1505 REM puzzle 1: 4 nodes, 3 connections
1510 DATA 4
1515 DATA 64,120, 192,120, 64,60, 192,60
1520 DATA 3
1525 DATA 1,2, 3,4, 1,3
1530 REM puzzle 2: 4 nodes, 4 connections
1535 DATA 4
1540 DATA 64,120, 192,120, 64,60, 192,60
1545 DATA 4
1550 DATA 1,2, 3,4, 1,3, 2,4
1555 REM puzzle 3: 5 nodes, 4 connections
1560 DATA 5
1565 DATA 50,120, 128,120, 206,120, 90,60, 166,60
1570 DATA 4
1575 DATA 1,2, 2,3, 4,5, 1,4
1580 REM puzzle 4: 5 nodes, 5 connections
1585 DATA 5
1590 DATA 50,120, 128,140, 206,120, 90,60, 166,60
1595 DATA 5
1600 DATA 1,2, 2,3, 4,5, 1,4, 3,5
1605 REM puzzle 5: 6 nodes, 5 connections
1610 DATA 6
1615 DATA 50,130, 128,130, 206,130, 50,60, 128,60, 206,60
1620 DATA 5
1625 DATA 1,2, 2,3, 4,5, 5,6, 1,4
1630 REM puzzle 6: 6 nodes, 6 connections
1635 DATA 6
1640 DATA 50,130, 128,130, 206,130, 50,60, 128,60, 206,60
1645 DATA 6
1650 DATA 1,2, 2,3, 4,5, 5,6, 1,4, 3,6
1655 REM puzzle 7: 6 nodes, 5 connections
1660 DATA 6
1665 DATA 80,140, 176,140, 40,90, 216,90, 80,40, 176,40
1670 DATA 5
1675 DATA 1,2, 3,4, 5,6, 1,3, 2,4
1680 REM puzzle 8: 6 nodes, 6 connections
1685 DATA 6
1690 DATA 80,140, 176,140, 40,90, 216,90, 80,40, 176,40
1695 DATA 6
1700 DATA 1,2, 3,4, 5,6, 1,3, 2,4, 1,5
1705 REM puzzle 9: 7 nodes, 6 connections
1710 DATA 7
1715 DATA 40,130, 128,145, 216,130, 70,80, 186,80, 128,50, 128,95
1720 DATA 6
1725 DATA 1,2, 2,3, 1,4, 3,5, 4,6, 5,6
1730 REM puzzle 10: 7 nodes, 7 connections
1735 DATA 7
1740 DATA 40,140, 128,140, 216,140, 40,60, 128,60, 216,60, 128,100
1745 DATA 7
1750 DATA 1,2, 2,3, 4,5, 5,6, 1,7, 3,7, 7,5
1755 REM puzzle 11: 8 nodes, 7 connections
1760 DATA 8
1765 DATA 40,140, 128,140, 216,140, 40,60, 128,60, 216,60, 84,100, 172,100
1770 DATA 7
1775 DATA 1,7, 7,2, 2,8, 8,3, 4,7, 8,6, 4,5
1780 REM puzzle 12: 8 nodes, 8 connections
1785 DATA 8
1790 DATA 50,150, 128,150, 206,150, 50,90, 128,90, 206,90, 90,40, 166,40
1795 DATA 8
1800 DATA 1,2, 2,3, 4,5, 5,6, 1,4, 3,6, 4,7, 6,8
1805 REM puzzle 13: 9 nodes, 8 connections
1810 DATA 9
1815 DATA 40,150, 128,150, 216,150, 40,90, 128,90, 216,90, 40,30, 128,30, 216,30
1820 DATA 8
1825 DATA 1,2, 2,3, 4,5, 5,6, 7,8, 8,9, 1,4, 6,9
1830 REM puzzle 14: 9 nodes, 9 connections
1835 DATA 9
1840 DATA 50,140, 128,155, 206,140, 30,90, 128,90, 226,90, 50,40, 128,25, 206,40
1845 DATA 9
1850 DATA 1,2, 2,3, 4,5, 5,6, 7,8, 8,9, 1,4, 3,6, 7,4
1855 REM puzzle 15: 9 nodes, 9 connections
1860 DATA 9
1865 DATA 64,150, 128,150, 192,150, 40,90, 128,90, 216,90, 64,30, 128,30, 192,30
1870 DATA 9
1875 DATA 1,2, 2,3, 4,5, 5,6, 7,8, 8,9, 1,5, 5,9, 2,8
2500 REM === title screen ===
2510 PRINT AT 3, 10; INK 7; BRIGHT 1; "LATTICE"
2520 PRINT AT 6, 3; INK 6; "Connect nodes with lines."
2530 PRINT AT 7, 3; INK 6; "Lines must not cross."
2540 PRINT AT 9, 3; INK 7; "Q/A = up/down"
2545 PRINT AT 10, 3; INK 7; "O/P = left/right"
2550 PRINT AT 11, 3; INK 7; "SPACE = select node"
2555 PRINT AT 12, 3; INK 7; "D = undo last line"
2560 PRINT AT 14, 3; INK 5; "15 puzzles in 2 bands"
2570 PRINT AT 16, 3; INK 4; "Stars: * complete"
2575 PRINT AT 17, 3; INK 4; "       ** no undo"
2580 PRINT AT 18, 3; INK 4; "       *** clean solve"
2590 PRINT AT 20, 6; INK 7; "Press any key"
2595 PAUSE 0
2598 RETURN
