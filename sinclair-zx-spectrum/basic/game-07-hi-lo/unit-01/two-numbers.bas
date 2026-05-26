  10 CLS
  20 RANDOMIZE
  30 LET a = INT (RND * 13) + 1
  40 LET b = INT (RND * 13) + 1
  50 PRINT "First number: "; a
  60 PRINT "Second number: "; b
  70 PRINT
  80 IF b > a THEN PRINT "Higher!"
  90 IF b < a THEN PRINT "Lower!"
 100 IF b = a THEN PRINT "Same!"
