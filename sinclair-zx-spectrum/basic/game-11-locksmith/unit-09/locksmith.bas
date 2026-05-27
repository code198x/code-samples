  10 BORDER 0: PAPER 0: INK 7: CLS
  20 PRINT AT 5, 8; "*** LOCKSMITH ***"
  30 PRINT AT 8, 2; "Crack my 4-digit code."
  32 PRINT AT 9, 2; "Each digit is 1 to 6."
  35 PRINT AT 11, 1; "Bull: right digit, right place"
  37 PRINT AT 12, 1; "Cow:  right digit, wrong place"
  40 PRINT AT 16, 4; "Press any key to start"
  45 PAUSE 0
  50 RANDOMIZE
  55 DIM c(4)
  60 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
  70 CLS
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
 300 PRINT AT 2 + t, 2; g$; "  "; INK 4; bulls; " bull";
 305 INK 6: PRINT "  "; cows; " cow"
 310 INK 7
 315 BEEP 0.05, bulls * 5
 320 IF bulls = 4 THEN GO TO 400
 330 NEXT t
 350 GO TO 450
 400 CLS
 410 PRINT AT 6, 8; "*** LOCKSMITH ***"
 420 PRINT AT 9, 6; INK 4; "Code cracked!"
 430 PRINT AT 11, 6; INK 7; "You got it in "; t; " guesses"
 440 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 445 GO TO 480
 450 CLS
 460 PRINT AT 6, 8; "*** LOCKSMITH ***"
 465 PRINT AT 9, 6; INK 2; "Out of guesses!"
 470 PRINT AT 11, 6; INK 7; "The code was ";
 472 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 475 BEEP 0.3, -10
 480 PRINT AT 16, 4; "Press any key to play again"
 490 PAUSE 0
 500 GO TO 10
