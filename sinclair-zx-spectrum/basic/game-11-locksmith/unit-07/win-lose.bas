  50 RANDOMIZE
  55 DIM c(4)
  60 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
  70 CLS
  75 PRINT AT 14, 2; "Code: ";
  76 FOR i = 1 TO 4: PRINT c(i);: NEXT i
  80 PRINT AT 0, 8; "*** LOCKSMITH ***"
 100 FOR t = 1 TO 10
 110 PRINT AT 20, 0; "Guess "; t; " of 10: ";
 120 INPUT g$
 130 IF LEN g$ <> 4 THEN GO TO 110
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
 300 PRINT AT 2 + t, 2; g$; "  "; bulls; " bull  "; cows; " cow"
 320 IF bulls = 4 THEN GO TO 400
 330 NEXT t
 350 GO TO 450
 400 CLS
 410 PRINT AT 6, 8; "*** LOCKSMITH ***"
 420 PRINT AT 9, 6; "Code cracked!"
 430 PRINT AT 11, 6; "You got it in "; t; " guesses"
 440 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 445 STOP
 450 CLS
 460 PRINT AT 6, 8; "*** LOCKSMITH ***"
 465 PRINT AT 9, 6; "Out of guesses!"
 470 PRINT AT 11, 6; "The code was ";
 472 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 475 BEEP 0.3, -10
