10 BORDER 0: PAPER 0: INK 7: BRIGHT 1: CLS
200 DIM m(12,4): DIM a$(12,24): DIM b$(12,28)
210 RESTORE 9500
220 FOR i = 1 TO 12: READ a$(i),b$(i): FOR j = 1 TO 4: READ m(i,j): NEXT j: NEXT i
250 LET rm = 1
260 LET d$ = "NSEW"
270 GO SUB 1000
280 STOP
1000 CLS
1010 PRINT AT 0,8; INK 5; "THE CAVERNS"
1030 INK 1: PLOT 16,148: DRAW 223,0
1040 PRINT AT 5,2; INK 5; a$(rm)
1050 PRINT AT 7,2; INK 7; b$(rm)
1060 PRINT AT 9,2; INK 6; "TUNNELS"
1070 FOR j = 1 TO 4
1080 LET v = m(rm,j): LET y = 10 + j
1090 PRINT AT y,2; INK 7; d$(j); "  --"
1100 IF v = 0 THEN GO TO 1160
1110 PRINT AT y,2; INK 7; d$(j); "  Open"
1160 NEXT j
1220 RETURN
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
