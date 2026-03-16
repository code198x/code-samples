  19 LET tm=0
  20 FOR n=1 TO 5
  27 LET m=0
  28 PRINT AT 21,0; INK 5;"Round ";n;"  Moves: 0    Total: ";tm;"  "
 108 LET tm=tm+m
 110 PRINT AT 21,0; INK 4; BRIGHT 1;"Found! ";m;" moves  Total: ";tm;"    "
 112 PAUSE 75
 114 PRINT AT r,c;" "
 116 BORDER 0
 118 NEXT n
