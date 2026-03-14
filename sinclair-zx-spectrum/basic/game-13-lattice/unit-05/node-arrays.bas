5 REM === NODE ARRAYS ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM x(14): DIM y(14)
30 REM Read 4 node positions from DATA
40 LET nn = 4
50 FOR i = 1 TO nn
60 READ x(i), y(i)
70 NEXT i
80 REM Draw all nodes
90 FOR i = 1 TO nn
100 CIRCLE INK 7; x(i), y(i), 3
110 NEXT i
120 PRINT AT 0, 0; "4 nodes from DATA statements"
130 PRINT AT 1, 0; "x() and y() arrays hold coords"
140 STOP
200 REM === NODE DATA ===
210 DATA 64,120, 192,120, 64,60, 192,60
