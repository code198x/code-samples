10 CLS
20 INPUT "Enter a number (1-100): "; n
30 IF n >= 1 AND n <= 100 THEN PRINT "Valid!"
40 IF n < 1 OR n > 100 THEN PRINT "Out of range!"
50 PRINT
60 INPUT "Pick A, B or C: "; a$
70 IF a$ = "A" OR a$ = "B" OR a$ = "C" THEN PRINT "Good choice: "; a$
80 IF a$ <> "A" AND a$ <> "B" AND a$ <> "C" THEN PRINT "That's not A, B or C!"
