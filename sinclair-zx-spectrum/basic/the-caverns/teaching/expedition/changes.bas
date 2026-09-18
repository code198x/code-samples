260 LET d$ = "NSEW": LET e$ = "nsew": LET h$ = "Find treasure. Return here."
450 IF rm = 1 AND found = 3 THEN LET ending = 3: GO TO 5000
5020 IF ending = 3 THEN LET h$ = "All three treasures are safe."
5050 IF ending = 3 THEN PRINT AT 16,2; INK 6; "YOU ESCAPED THE CAVERNS."
