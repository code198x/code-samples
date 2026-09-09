10 BORDER 0: PAPER 0: INK 7: CLS
20 PRINT AT 0,1;"O LEFT  P RIGHT  SPACE THRUST"
30 PRINT AT 2,1;"Hold combinations. Q quits."
100 IF INKEY$="q" THEN GO TO 200
110 LET keys=IN 57342
120 LET right=1-(keys-2*INT (keys/2))
130 LET left=1-(INT (keys/2)-2*INT (keys/4))
140 LET keys=IN 32766
150 LET thrust=1-(keys-2*INT (keys/2))
160 PRINT AT 5,1;"LEFT: ";left;AT 7,1;"RIGHT: ";right;AT 9,1;"THRUST: ";thrust
170 GO TO 100
200 IF INKEY$<>"" THEN GO TO 200
210 STOP
