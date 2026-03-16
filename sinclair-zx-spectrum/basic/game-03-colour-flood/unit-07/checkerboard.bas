   5 BORDER 0: PAPER 0: INK 7: CLS
  10 FOR r=0 TO 21
  20 FOR c=0 TO 31
  30 IF INT ((r+c)/2)*2=(r+c) THEN PRINT AT r,c; PAPER 2;" "
  40 IF INT ((r+c)/2)*2<>(r+c) THEN PRINT AT r,c; PAPER 6;" "
  50 NEXT c
  60 NEXT r
