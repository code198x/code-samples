  10 CLS
  20 FOR r=0 TO 7
  30 FOR c=0 TO 7
  40 PRINT AT r*2+2, c*4; PAPER (r+c)-INT ((r+c)/8)*8;"    "
  50 NEXT c
  60 NEXT r
