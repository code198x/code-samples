 120 REM === Results ===
 122 CLS
 124 FOR i=0 TO 31
 126 PRINT AT 0,i; PAPER 3;" "
 128 NEXT i
 130 PRINT AT 0,10; PAPER 3; INK 7; BRIGHT 1;" HOT AND COLD "
 132 PRINT AT 4,11; INK 7; BRIGHT 1;"RESULTS"
 134 PRINT AT 7,7; INK 5;"Total moves: ";tm
 136 IF tm<=40 THEN PRINT AT 10,8; INK 4; BRIGHT 1;"Treasure hunter!"
 138 IF tm>40 AND tm<=70 THEN PRINT AT 10,8; INK 6;"Good instincts!"
 140 IF tm>70 AND tm<=100 THEN PRINT AT 10,8; INK 5;"Getting warmer!"
 142 IF tm>100 THEN PRINT AT 10,8; INK 3;"Keep searching!"
 144 PRINT AT 14,6; INK 7;"Press any key to exit"
 146 IF INKEY$="" THEN GO TO 146
 148 BORDER 7: PAPER 7: INK 0: CLS
 150 PRINT "Thanks for playing!": STOP
