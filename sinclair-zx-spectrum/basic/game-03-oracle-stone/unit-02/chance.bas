  10 CLS
  20 RANDOMIZE
  30 PRINT "The Oracle awaits your question."
  40 PRINT
  50 INPUT "Speak, mortal: "; q$
  60 PRINT
  70 LET r = INT (RND * 6) + 1
  80 IF r = 1 THEN PRINT "The Oracle says... YES"
  90 IF r = 2 THEN PRINT "The Oracle says... NO"
 100 IF r = 3 THEN PRINT "The Oracle says... PERHAPS"
 110 IF r = 4 THEN PRINT "The Oracle says... ASK AGAIN"
 120 IF r = 5 THEN PRINT "The Oracle says... THE SIGNS ARE UNCLEAR"
 130 IF r = 6 THEN PRINT "The Oracle says... DEFINITELY NOT"
