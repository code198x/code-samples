5 REM === VALID CONNECTION CHECK ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM x(14): DIM y(14)
25 DIM f(14): DIM g(14)
30 LET nn = 4
40 FOR i = 1 TO nn
50 READ x(i), y(i)
60 NEXT i
70 READ nc
80 FOR i = 1 TO nc
90 READ f(i), g(i)
100 NEXT i
110 LET cn = 1: LET s1 = 0: LET dn = 0
120 GO SUB 400
130 GO SUB 450
135 GO SUB 500
140 REM === input loop ===
145 PAUSE 0: LET k$ = INKEY$
150 IF k$ = "q" OR k$ = "Q" THEN LET d = 1: GO TO 200
155 IF k$ = "a" OR k$ = "A" THEN LET d = 2: GO TO 200
160 IF k$ = "o" OR k$ = "O" THEN LET d = 3: GO TO 200
165 IF k$ = "p" OR k$ = "P" THEN LET d = 4: GO TO 200
170 IF k$ = " " THEN GO TO 250
175 IF k$ = "s" OR k$ = "S" THEN STOP
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
310 CIRCLE INK 7; x(a), y(a), 3
315 RETURN
400 REM === draw all nodes ===
405 FOR a = 1 TO nn
410 GO SUB 300
420 NEXT a
425 RETURN
450 REM === draw cursor ===
455 CIRCLE INK 6; x(cn), y(cn), 6
460 RETURN
465 REM === erase cursor ===
470 CIRCLE INK 0; x(cn), y(cn), 6
475 RETURN
500 REM === draw HUD ===
505 PRINT AT 21, 0; INK 7; "LINES "; dn; "/"; nc; "   "
510 RETURN
700 REM === attempt connection ===
705 LET sn = cn
710 LET mi = 0
715 FOR i = 1 TO nc
720 IF (f(i) = s1 AND g(i) = sn) OR (f(i) = sn AND g(i) = s1) THEN LET mi = i
725 NEXT i
730 IF mi = 0 THEN PRINT AT 20, 0; INK 2; "Not a required connection      ": RETURN
735 REM Valid pair found - draw it
740 PLOT INK 4; x(f(mi)), y(f(mi))
745 DRAW INK 4; x(g(mi)) - x(f(mi)), y(g(mi)) - y(f(mi))
750 LET dn = dn + 1
755 BEEP 0.05, 5 + dn * 2
760 PRINT AT 20, 0; INK 4; "Connected!                     "
765 GO SUB 500
770 RETURN
1500 REM === PUZZLE DATA ===
1510 DATA 64,120, 192,120, 64,60, 192,60
1520 DATA 3
1530 DATA 1,2, 3,4, 1,3
