   5 BORDER 0: PAPER 0: INK 7: CLS
  10 LET t=9
  12 LET z$="x+x-"
  14 FOR c=t TO 0 STEP -1
  16 LET fl=INT (16*c/t)
  18 IF fl<1 THEN LET fl=1
  20 FOR i=0 TO 1
  22 PRINT AT 10+i,5; PAPER 0;"                "
  24 NEXT i
  26 FOR i=0 TO 1
  28 PRINT AT 10+i,5; PAPER 6; INK 0;
  30 FOR j=1 TO fl: PRINT " ";: NEXT j
  32 NEXT i
  34 LET si=(c-INT (c/4)*4)+1
  36 PRINT AT 10,5+fl; INK 2; BRIGHT 1;z$(si TO si)
  38 BEEP 0.06,5+((t-c)*3)
  40 PAUSE 15
  42 NEXT c
