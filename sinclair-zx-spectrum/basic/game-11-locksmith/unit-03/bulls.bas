  50 RANDOMIZE
  55 DIM c(4)
  60 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
  70 CLS
  75 PRINT "The code is: ";
  76 FOR i = 1 TO 4: PRINT c(i);: NEXT i
  80 PRINT
 120 INPUT "Your guess (4 digits): "; g$
 130 IF LEN g$ <> 4 THEN GO TO 120
 140 DIM g(4)
 150 FOR i = 1 TO 4: LET g(i) = VAL g$(i): NEXT i
 200 LET bulls = 0
 210 FOR i = 1 TO 4
 220 IF g(i) = c(i) THEN LET bulls = bulls + 1
 230 NEXT i
 240 PRINT "Bulls: "; bulls
