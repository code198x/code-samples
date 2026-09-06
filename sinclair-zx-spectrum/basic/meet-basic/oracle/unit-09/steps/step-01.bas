10 PAPER 0
20 INK 7
30 BORDER 0
40 CLS
50 PRINT "ORACLE STONE"
60 INPUT "Ask a question: ";q$
70 LET answer=INT (RND*3)+1
80 CLS
90 PRINT "THE STONE SAYS"
100 IF answer=1 THEN PRINT "Try a small experiment."
110 IF answer=2 THEN PRINT "Ask someone to join you."
120 IF answer=3 THEN PRINT "Take a different route."
