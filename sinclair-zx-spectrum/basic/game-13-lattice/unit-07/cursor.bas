5 REM === CURSOR MOVEMENT ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM x(14): DIM y(14)
30 LET nn = 4
40 FOR i = 1 TO nn
50 READ x(i), y(i)
60 NEXT i
70 REM Draw all nodes
80 FOR a = 1 TO nn
90 CIRCLE INK 7; x(a), y(a), 3
100 NEXT a
110 LET cn = 1
120 GO SUB 450
130 PRINT AT 0, 0; "QAOP to move cursor. S to stop"
140 REM === input loop ===
145 PAUSE 0: LET k$ = INKEY$
150 IF k$ = "q" OR k$ = "Q" THEN LET d = 1: GO TO 200
155 IF k$ = "a" OR k$ = "A" THEN LET d = 2: GO TO 200
160 IF k$ = "o" OR k$ = "O" THEN LET d = 3: GO TO 200
165 IF k$ = "p" OR k$ = "P" THEN LET d = 4: GO TO 200
170 IF k$ = "s" OR k$ = "S" THEN STOP
180 GO TO 140
200 REM === move to nearest node in direction ===
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
450 REM === draw cursor ===
455 CIRCLE INK 6; x(cn), y(cn), 6
460 RETURN
465 REM === erase cursor ===
470 CIRCLE INK 0; x(cn), y(cn), 6
475 RETURN
500 REM === NODE DATA ===
510 DATA 64,120, 192,120, 64,60, 192,60
