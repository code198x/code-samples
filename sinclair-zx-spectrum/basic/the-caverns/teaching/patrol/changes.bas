200 DIM m(12,4): DIM a$(12,24): DIM b$(12,28): DIM t(12): DIM c(8)
230 RESTORE 9800: FOR i = 1 TO 8: READ c(i): NEXT i
250 LET rm = 1: LET pit = 7: LET ci = 3: LET cr = c(ci): LET found = 0: LET turns = 0
420 IF dest = cr THEN LET rm = dest: LET ending = 2: GO TO 5000
460 LET ci = ci + 1: IF ci = 9 THEN LET ci = 1
470 LET cr = c(ci)
480 IF cr = rm THEN LET h$ = "It arrives! Leave next turn!"
1130 IF v = cr THEN PRINT AT y,15; INK 6; "Footsteps"
1150 IF v = cr AND t(v) = 1 THEN PRINT AT y,15; INK 6; "Steps + glint"
1170 IF cr = rm THEN PRINT AT 16,2; INK 6; "IT IS HERE. MOVE NOW."
1180 IF cr <> rm THEN PRINT AT 16,2; INK 7; "No creature in this room."
5010 IF ending = 2 THEN LET h$ = "The creature catches you."
9800 DATA 2,3,4,8,12,11,10,6
