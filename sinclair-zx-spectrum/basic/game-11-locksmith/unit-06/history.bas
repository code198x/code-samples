  10 BORDER 0: PAPER 0: INK 7: CLS
 130 RANDOMIZE
 140 DIM c(4)
 150 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
 160 CLS
 170 PRINT AT 14, 2; "Code: ";
 180 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 190 INVERSE 1: PRINT AT 0, 0; "      *** LOCKSMITH ***        ": INVERSE 0
 200 FOR t = 1 TO 10
 210 PRINT AT 20, 0; "Guess "; t; " of 10: ";
 220 INPUT g$
 230 IF LEN g$ <> 4 THEN GO TO 210
 240 DIM g(4)
 250 FOR i = 1 TO 4: LET g(i) = VAL g$(i): NEXT i
 270 LET bulls = 0
 280 FOR i = 1 TO 4
 290 IF g(i) = c(i) THEN LET bulls = bulls + 1
 300 NEXT i
 310 LET total = 0
 320 FOR d = 1 TO 6
 330 LET cc = 0: LET gc = 0
 340 FOR i = 1 TO 4
 350 IF c(i) = d THEN LET cc = cc + 1
 360 IF g(i) = d THEN LET gc = gc + 1
 370 NEXT i
 380 IF cc <= gc THEN LET total = total + cc
 390 IF gc < cc THEN LET total = total + gc
 400 NEXT d
 410 LET cows = total - bulls
 430 PRINT AT 2 + t, 2; g$; "  "; bulls; " bull  "; cows; " cow"
 490 IF bulls = 4 THEN PRINT AT 15, 2; "Code cracked!": STOP
 500 NEXT t
 510 PRINT AT 15, 2; "Out of guesses!"
 520 PRINT AT 16, 2; "The code was ";
 530 FOR i = 1 TO 4: PRINT c(i);: NEXT i
