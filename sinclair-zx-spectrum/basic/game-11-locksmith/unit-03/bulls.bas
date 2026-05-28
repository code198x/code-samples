  10 BORDER 0: PAPER 0: INK 7: CLS
 130 RANDOMIZE
 140 DIM c(4)
 150 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
 160 CLS
 170 PRINT "The code is: ";
 180 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 190 PRINT
 220 INPUT "Your guess (4 digits): "; g$
 230 IF LEN g$ <> 4 THEN GO TO 220
 240 DIM g(4)
 250 FOR i = 1 TO 4: LET g(i) = VAL g$(i): NEXT i
 270 LET bulls = 0
 280 FOR i = 1 TO 4
 290 IF g(i) = c(i) THEN LET bulls = bulls + 1
 300 NEXT i
 310 PRINT "Bulls: "; bulls

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
