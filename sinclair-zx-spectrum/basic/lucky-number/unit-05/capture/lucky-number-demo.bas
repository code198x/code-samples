  10 BORDER 0: PAPER 0: INK 7: CLS
  30 LET n = 42
  40 LET c = 0
  50 INVERSE 1: PRINT AT 2, 0; "   *** LUCKY NUMBER ***          ": INVERSE 0
  60 PRINT
  70 PRINT "I'm thinking of a number"
  80 PRINT "between 1 and 100."
  90 PRINT
 100 PAUSE 0
 110 CLS
 120 INPUT "Your guess: "; g
 130 LET c = c + 1
 140 LET d = ABS (g - n)
 150 IF d > 50 THEN BORDER 1
 160 IF d > 25 AND d <= 50 THEN BORDER 5
 170 IF d > 10 AND d <= 25 THEN BORDER 6
 180 IF d > 5 AND d <= 10 THEN BORDER 2
 190 IF d <= 5 THEN BORDER 7
 200 IF g = n THEN GO TO 300
 210 IF g < n THEN PRINT "Too low!": BEEP 0.1, -5
 220 IF g > n THEN PRINT "Too high!": BEEP 0.1, 5
 230 GO TO 120
 300 BORDER 4: BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20: BEEP 0.2, 24
 310 PRINT "Got it! The number was "; n
 320 PRINT "You found it in "; c; " guesses."
 330 PRINT
 340 IF c <= 5 THEN PRINT "Incredible!"
 350 IF c > 5 AND c <= 10 THEN PRINT "Not bad!"
 360 IF c > 10 THEN PRINT "Keep trying!"
