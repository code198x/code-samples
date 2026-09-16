10 DIM g(8,8)
20 PRINT g(1,1)
30 FOR r = 1 TO 8
40 FOR c = 1 TO 8
50 LET g(r,c) = -1
60 NEXT c
70 NEXT r
80 PRINT g(1,1); " "; g(8,8)
90 LET g(1,2) = 3
100 PRINT g(1,2); " "; g(2,1)
110 STOP
