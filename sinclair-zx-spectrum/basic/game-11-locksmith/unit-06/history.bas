  10 BORDER 0: PAPER 0: INK 7: CLS
  90 RANDOMIZE
 100 DIM c(4)
 110 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
 120 CLS
 130 PRINT AT 14, 2; "Code: ";
 140 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 150 PRINT AT 0, 8; "*** LOCKSMITH ***"
 160 FOR t = 1 TO 10
 170 PRINT AT 20, 0; "Guess "; t; " of 10: ";
 180 INPUT g$
 190 IF LEN g$ <> 4 THEN GO TO 170
 200 DIM g(4)
 210 FOR i = 1 TO 4: LET g(i) = VAL g$(i): NEXT i
 300 LET bulls = 0
 310 FOR i = 1 TO 4
 320 IF g(i) = c(i) THEN LET bulls = bulls + 1
 330 NEXT i
 340 LET total = 0
 350 FOR d = 1 TO 6
 360 LET cc = 0: LET gc = 0
 370 FOR i = 1 TO 4
 380 IF c(i) = d THEN LET cc = cc + 1
 390 IF g(i) = d THEN LET gc = gc + 1
 400 NEXT i
 410 IF cc <= gc THEN LET total = total + cc
 420 IF gc < cc THEN LET total = total + gc
 430 NEXT d
 440 LET cows = total - bulls
 460 PRINT AT 2 + t, 2; g$; "  "; bulls; " bull  "; cows; " cow"
 500 IF bulls = 4 THEN PRINT AT 15, 2; "Code cracked!": STOP
 510 NEXT t
 520 PRINT AT 15, 2; "Out of guesses!"
 530 PRINT AT 16, 2; "The code was ";
 540 FOR i = 1 TO 4: PRINT c(i);: NEXT i

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
