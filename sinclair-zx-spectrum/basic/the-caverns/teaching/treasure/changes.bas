200 DIM m(12,4): DIM a$(12,24): DIM b$(12,28): DIM t(12)
240 LET t(6) = 1: LET t(10) = 1: LET t(12) = 1
250 LET rm = 1: LET found = 0: LET turns = 0
260 LET d$ = "NSEW": LET e$ = "nsew": LET h$ = "Find three lost treasures."
440 IF t(rm) = 1 THEN LET t(rm) = 0: LET found = found + 1: LET h$ = "You recover a lost treasure."
1020 PRINT AT 2,2; INK 6; "TREASURE "; found; "/3    TURNS "; turns
1060 PRINT AT 9,2; INK 6; "TUNNELS       NEARBY SIGNS"
1140 IF t(v) = 1 THEN PRINT AT y,15; INK 4; "Glint"
