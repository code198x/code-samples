300 IF k$ = " " THEN LET served = 1: PRINT AT 1,2; "Keep the ball in play.": GO TO 350
390 IF ny >= 32 THEN GO TO 490
400 IF nx + 1 < 8 * p OR nx > 8 * p + 31 THEN LET e$ = "Missed! R for another go.": GO TO 4000
410 LET ny = 64 - ny: LET dy = 4
