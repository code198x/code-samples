  10 CLS
  20 RANDOMIZE
  30 PRINT "The Oracle awaits your question."
  40 PRINT
  50 INPUT "Speak, mortal: "; q$
  60 PRINT
  70 PRINT "The Oracle ponders..."
  80 BEEP 0.3, 20: BEEP 0.3, 15: BEEP 0.3, 10: BEEP 0.3, 5
  90 PAUSE 25
 100 CLS
 110 LET r = INT (RND * 6) + 1
 120 BEEP 0.1, 24
 130 IF r = 1 THEN PRINT "The Oracle says... YES"
 140 IF r = 2 THEN PRINT "The Oracle says... NO"
 150 IF r = 3 THEN PRINT "The Oracle says... PERHAPS"
 160 IF r = 4 THEN PRINT "The Oracle says... ASK AGAIN"
 170 IF r = 5 THEN PRINT "The Oracle says... THE SIGNS ARE UNCLEAR"
 180 IF r = 6 THEN PRINT "The Oracle says... DEFINITELY NOT"
