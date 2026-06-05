  10 LET secret = 7
  20 LET tries = 0
  30 INPUT "Guess (1-10)? "; g
  40 LET tries = tries + 1
  50 IF g < secret THEN PRINT g; " is too low"
  60 IF g > secret THEN PRINT g; " is too high"
  70 IF g <> secret THEN GO TO 30
  80 PRINT "Correct in "; tries; " guesses!"
