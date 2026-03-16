   1 REM Hot and Cold v1
   5 BORDER 0: PAPER 0: INK 7: CLS
  10 REM === Header ===
  12 FOR i=0 TO 31
  14 PRINT AT 0,i; PAPER 3;" "
  16 NEXT i
  18 PRINT AT 0,10; PAPER 3; INK 7; BRIGHT 1;" HOT AND COLD "
  19 LET tm=0
  20 FOR n=1 TO 5
  22 LET tr=INT (RND*20)+1
  24 LET tc=INT (RND*30)+1
  26 LET r=10: LET c=15
  27 LET m=0
  28 PRINT AT 21,0; INK 5;"Round ";n;"  Moves: 0    Total: ";tm;"  "
  30 REM === Game loop ===
  32 PRINT AT r,c; INK 6; BRIGHT 1;"+"
  34 LET d=ABS (r-tr)+ABS (c-tc)
  36 IF d=0 THEN GO TO 100
  38 IF d<=3 THEN BORDER 6
  40 IF d>3 AND d<=7 THEN BORDER 2
  42 IF d>7 AND d<=14 THEN BORDER 3
  44 IF d>14 AND d<=24 THEN BORDER 1
  46 IF d>24 THEN BORDER 0
  48 IF INKEY$="" THEN GO TO 48
  50 LET k$=INKEY$
  52 PRINT AT r,c;" "
  54 IF k$="q" AND r>1 THEN LET r=r-1
  56 IF k$="a" AND r<20 THEN LET r=r+1
  58 IF k$="o" AND c>0 THEN LET c=c-1
  60 IF k$="p" AND c<31 THEN LET c=c+1
  62 LET m=m+1
  64 PRINT AT 21,15; INK 5;m;"  "
  66 IF INKEY$<>"" THEN GO TO 66
  68 GO TO 30
 100 REM === Found! ===
 102 PRINT AT r,c; INK 4; BRIGHT 1; FLASH 1;"*"; FLASH 0
 104 BORDER 7
 106 BEEP 0.1,10: BEEP 0.1,15: BEEP 0.1,20: BEEP 0.2,25
 108 LET tm=tm+m
 110 PRINT AT 21,0; INK 4; BRIGHT 1;"Found! ";m;" moves  Total: ";tm;"    "
 112 PAUSE 75
 114 PRINT AT r,c;" "
 116 BORDER 0
 118 NEXT n
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
