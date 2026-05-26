  10 CLS
  20 RANDOMIZE
  30 LET t1 = 0: LET t2 = 0: LET t3 = 0
  40 LET t4 = 0: LET t5 = 0: LET t6 = 0
  50 PRINT "Rolling 500 dice..."
  60 PRINT
  70 PRINT "1:": PRINT "2:": PRINT "3:"
  80 PRINT "4:": PRINT "5:": PRINT "6:"
  90 FOR i = 1 TO 500
 100 LET d = INT (RND * 6) + 1
 110 IF d = 1 THEN LET t1 = t1 + 1
 120 IF d = 2 THEN LET t2 = t2 + 1
 130 IF d = 3 THEN LET t3 = t3 + 1
 140 IF d = 4 THEN LET t4 = t4 + 1
 150 IF d = 5 THEN LET t5 = t5 + 1
 160 IF d = 6 THEN LET t6 = t6 + 1
 170 PRINT AT 2, 3; t1; "  "
 180 PRINT AT 3, 3; t2; "  "
 190 PRINT AT 4, 3; t3; "  "
 200 PRINT AT 5, 3; t4; "  "
 210 PRINT AT 6, 3; t5; "  "
 220 PRINT AT 7, 3; t6; "  "
 230 NEXT i
 240 PRINT AT 9, 0; "Done!"
