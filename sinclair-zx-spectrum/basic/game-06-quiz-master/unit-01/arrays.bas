10 CLS
20 DIM s(4)
30 LET s(1) = 10
40 LET s(2) = 25
50 LET s(3) = 15
60 LET s(4) = 30
70 PRINT "Scores:"
80 FOR i = 1 TO 4
90 PRINT "Player "; i; ": "; s(i)
100 NEXT i
110 PRINT
120 LET t = 0
130 FOR i = 1 TO 4
140 LET t = t + s(i)
150 NEXT i
160 PRINT "Total: "; t
