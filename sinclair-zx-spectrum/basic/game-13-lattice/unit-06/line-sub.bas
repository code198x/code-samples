5 REM === LINE SUBROUTINE ===
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
110 REM Connect pairs using the subroutine
120 LET n1 = 1: LET n2 = 2: GO SUB 300
130 LET n1 = 3: LET n2 = 4: GO SUB 300
140 LET n1 = 1: LET n2 = 3: GO SUB 300
150 PRINT AT 0, 0; "3 lines drawn via GO SUB 300"
160 STOP
300 REM === draw line between nodes n1 and n2 ===
310 PLOT INK 4; x(n1), y(n1)
320 DRAW INK 4; x(n2) - x(n1), y(n2) - y(n1)
330 RETURN
400 REM === NODE DATA ===
410 DATA 64,120, 192,120, 64,60, 192,60
