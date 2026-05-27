  10 BORDER 0: PAPER 0: INK 7: CLS
  90 RANDOMIZE
 100 DIM c(4)
 110 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
 120 CLS
 130 PRINT "The code is: ";
 140 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 150 PRINT
 180 INPUT "Your guess (4 digits): "; g$
 190 IF LEN g$ <> 4 THEN GO TO 180
 200 DIM g(4)
 210 FOR i = 1 TO 4: LET g(i) = VAL g$(i): NEXT i
 220 PRINT "You guessed: "; g$
