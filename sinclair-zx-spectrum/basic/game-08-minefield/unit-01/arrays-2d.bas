10 CLS
20 PRINT "2D Arrays"
30 PRINT
40 DIM m(5, 5)
50 LET m(1, 1) = 7
60 LET m(2, 3) = 4
70 LET m(3, 5) = 9
80 LET m(5, 5) = 1
90 PRINT "m(1,1) = "; m(1, 1)
100 PRINT "m(2,3) = "; m(2, 3)
110 PRINT "m(3,5) = "; m(3, 5)
120 PRINT "m(4,4) = "; m(4, 4)
130 PRINT "m(5,5) = "; m(5, 5)
140 PRINT
150 PRINT "Full grid:"
160 FOR r = 1 TO 5
170 FOR c = 1 TO 5
180 PRINT m(r, c); " ";
190 NEXT c
200 PRINT
210 NEXT r
