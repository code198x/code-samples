  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  60 CLS
  70 LET t1 = 0: LET t2 = 0: LET t3 = 0
  80 LET t4 = 0: LET t5 = 0: LET t6 = 0
  90 PRINT "Rolling 500 dice..."
 100 PRINT
 110 FOR i = 1 TO 500
 120 LET d = INT (RND * 6) + 1
 130 IF d = 1 THEN LET t1 = t1 + 1
 140 IF d = 2 THEN LET t2 = t2 + 1
 150 IF d = 3 THEN LET t3 = t3 + 1
 160 IF d = 4 THEN LET t4 = t4 + 1
 170 IF d = 5 THEN LET t5 = t5 + 1
 180 IF d = 6 THEN LET t6 = t6 + 1
 190 PRINT AT 2, 3; t1; "  "
 200 PRINT AT 3, 3; t2; "  "
 210 PRINT AT 4, 3; t3; "  "
 220 PRINT AT 5, 3; t4; "  "
 230 PRINT AT 6, 3; t5; "  "
 240 PRINT AT 7, 3; t6; "  "
 250 NEXT i

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
