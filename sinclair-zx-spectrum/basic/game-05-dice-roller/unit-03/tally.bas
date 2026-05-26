  10 CLS
  20 RANDOMIZE
  30 LET t1 = 0: LET t2 = 0: LET t3 = 0
  40 LET t4 = 0: LET t5 = 0: LET t6 = 0
  50 FOR i = 1 TO 100
  60 LET d = INT (RND * 6) + 1
  70 IF d = 1 THEN LET t1 = t1 + 1
  80 IF d = 2 THEN LET t2 = t2 + 1
  90 IF d = 3 THEN LET t3 = t3 + 1
 100 IF d = 4 THEN LET t4 = t4 + 1
 110 IF d = 5 THEN LET t5 = t5 + 1
 120 IF d = 6 THEN LET t6 = t6 + 1
 130 NEXT i
 140 PRINT "Results from 100 rolls:"
 150 PRINT
 160 PRINT "1: "; t1
 170 PRINT "2: "; t2
 180 PRINT "3: "; t3
 190 PRINT "4: "; t4
 200 PRINT "5: "; t5
 210 PRINT "6: "; t6
