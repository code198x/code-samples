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
 240 LET total = 0
 242 FOR d = 1 TO 6
 244 LET cc = 0: LET gc = 0
 246 FOR i = 1 TO 4
 248 IF c(i) = d THEN LET cc = cc + 1
 250 IF g(i) = d THEN LET gc = gc + 1
 252 NEXT i
 254 IF cc <= gc THEN LET total = total + cc
 256 IF gc < cc THEN LET total = total + gc
 258 NEXT d
 260 LET cows = total - bulls
 280 PRINT "Bulls: "; bulls; "  Cows: "; cows
