10 BORDER 1: PAPER 1: INK 7: CLS
20 DIM a(10, 10): DIM b(10, 10)
25 DIM c(10, 10): DIM d(10, 10)
30 DIM l(5)
35 FOR n = 1 TO 5: READ l(n): NEXT n
36 DATA 5, 4, 3, 3, 2
40 PRINT AT 5, 6; "Arrays ready"
45 PRINT AT 7, 2; "a() = Player 1 ships"
50 PRINT AT 8, 2; "b() = Player 2 ships"
55 PRINT AT 9, 2; "c() = Player 1 shots"
60 PRINT AT 10, 2; "d() = Player 2 shots"
65 PRINT AT 12, 2; "Ship lengths:"
70 FOR n = 1 TO 5
75 PRINT AT 12 + n, 4; "Ship "; n; " = "; l(n); " cells"
80 NEXT n
