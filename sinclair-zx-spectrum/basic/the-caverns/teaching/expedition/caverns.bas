10 BORDER 0: PAPER 0: INK 7: BRIGHT 1: CLS
200 DIM m(12,4): DIM a$(12,24): DIM b$(12,28): DIM t(12): DIM c(8)
210 RESTORE 9500
220 FOR i = 1 TO 12: READ a$(i),b$(i): FOR j = 1 TO 4: READ m(i,j): NEXT j: NEXT i
230 RESTORE 9800: FOR i = 1 TO 8: READ c(i): NEXT i
240 LET t(6) = 1: LET t(10) = 1: LET t(12) = 1
250 LET rm = 1: LET pit = 7: LET ci = 3: LET cr = c(ci): LET found = 0: LET turns = 0
260 LET d$ = "NSEW": LET e$ = "nsew": LET h$ = "Find treasure. Return here."
270 GO SUB 1000
300 GO SUB 9000
310 LET k$ = INKEY$: IF k$ = "" THEN GO TO 310
320 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
330 IF k$ = "r" OR k$ = "R" THEN GO TO 200
340 LET dir = 0: FOR j = 1 TO 4: IF k$ = d$(j) OR k$ = e$(j) THEN LET dir = j
350 NEXT j
360 IF dir = 0 AND k$ <> " " THEN GO TO 300
370 LET dest = rm
380 IF dir > 0 THEN LET dest = m(rm,dir)
390 IF dest = 0 THEN PRINT AT 18,2; INK 6; "No tunnel in that direction. ": GO TO 300
400 LET turns = turns + 1: LET h$ = "Your footsteps fade away."
410 IF dest = pit THEN LET rm = dest: LET ending = 1: GO TO 5000
420 IF dest = cr THEN LET rm = dest: LET ending = 2: GO TO 5000
430 LET rm = dest
440 IF t(rm) = 1 THEN LET t(rm) = 0: LET found = found + 1: LET h$ = "You recover a lost treasure."
450 IF rm = 1 AND found = 3 THEN LET ending = 3: GO TO 5000
460 LET ci = ci + 1: IF ci = 9 THEN LET ci = 1
470 LET cr = c(ci)
480 IF cr = rm THEN LET h$ = "It arrives! Leave next turn!"
490 GO TO 270
1000 CLS
1010 PRINT AT 0,8; INK 5; "THE CAVERNS"
1020 PRINT AT 2,2; INK 6; "TREASURE "; found; "/3    TURNS "; turns
1030 INK 1: PLOT 16,148: DRAW 223,0
1040 PRINT AT 5,2; INK 5; a$(rm)
1050 PRINT AT 7,2; INK 7; b$(rm)
1060 PRINT AT 9,2; INK 6; "TUNNELS       NEARBY SIGNS"
1070 FOR j = 1 TO 4
1080 LET v = m(rm,j): LET y = 10 + j
1090 PRINT AT y,2; INK 7; d$(j); "  --"
1100 IF v = 0 THEN GO TO 1160
1110 PRINT AT y,2; INK 7; d$(j); "  Open"
1120 IF v = pit THEN PRINT AT y,15; INK 6; "Cold draught"
1130 IF v = cr THEN PRINT AT y,15; INK 6; "Footsteps"
1140 IF t(v) = 1 THEN PRINT AT y,15; INK 4; "Glint"
1150 IF v = cr AND t(v) = 1 THEN PRINT AT y,15; INK 6; "Steps + glint"
1160 NEXT j
1170 IF cr = rm THEN PRINT AT 16,2; INK 6; "IT IS HERE. MOVE NOW."
1180 IF cr <> rm THEN PRINT AT 16,2; INK 7; "No creature in this room."
1190 PRINT AT 18,2; INK 5; h$
1200 PRINT AT 20,2; INK 7; "N S E W / SPACE waits"
1210 PRINT AT 21,2; INK 7; "R: restart   Q: quit"
1220 RETURN
5000 IF ending = 1 THEN LET h$ = "The cold tunnel hid a pit."
5010 IF ending = 2 THEN LET h$ = "The creature catches you."
5020 IF ending = 3 THEN LET h$ = "All three treasures are safe."
5030 GO SUB 1000
5040 PRINT AT 16,2; INK 6; "                            "
5050 IF ending = 3 THEN PRINT AT 16,2; INK 6; "YOU ESCAPED THE CAVERNS."
5060 IF ending <> 3 THEN PRINT AT 16,2; INK 6; "YOUR EXPEDITION ENDS."
5070 PRINT AT 20,2; INK 7; "R: try again   Q: quit       ": PRINT AT 21,2; "                            "
5080 GO SUB 9000
5090 LET k$ = INKEY$: IF k$ = "" THEN GO TO 5090
5100 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
5110 IF k$ = "r" OR k$ = "R" THEN GO TO 200
5120 GO TO 5090
8000 PRINT AT 21,2; INK 7; "The Caverns finished.       ": STOP
9000 IF INKEY$ <> "" THEN GO TO 9000
9010 RETURN
9500 DATA "The entrance","Daylight rims the stone.",0,5,2,0
9510 DATA "Split passage","Two worn paths meet here.",0,6,3,1
9520 DATA "Echo gallery","Every step returns twice.",0,7,4,2
9530 DATA "High ledge","A narrow shelf bends south.",0,8,0,3
9540 DATA "Root chamber","Roots grip the damp ceiling.",1,9,6,0
9550 DATA "Old camp","A torn pack lies in dust.",2,10,7,5
9560 DATA "The black shaft","The floor vanishes below.",3,11,8,6
9570 DATA "Dripping stair","Water counts the seconds.",4,12,0,7
9580 DATA "Still pool","Your lamp trembles in water.",5,0,10,0
9590 DATA "Buried shrine","Carved faces watch the path.",6,0,11,9
9600 DATA "Low arch","You stoop beneath the rock.",7,0,12,10
9610 DATA "Crystal hollow","Crystals catch the lamplight.",8,0,0,11
9800 DATA 2,3,4,8,12,11,10,6
