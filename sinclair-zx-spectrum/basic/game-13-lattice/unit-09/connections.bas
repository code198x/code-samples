5 REM === CONNECTION PAIRS ===
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
110 REM Draw all nodes
120 FOR a = 1 TO nn
130 CIRCLE INK 7; x(a), y(a), 3
140 NEXT a
150 REM Show required connections
160 PRINT AT 0, 0; "Required connections:"
170 FOR i = 1 TO nc
180 PRINT AT i, 0; "  "; f(i); " -> "; g(i)
190 NEXT i
200 PRINT AT nc + 2, 0; nc; " pairs to connect"
210 STOP
300 REM === PUZZLE DATA ===
310 DATA 64,120, 192,120, 64,60, 192,60
320 DATA 3
330 DATA 1,2, 3,4, 1,3
