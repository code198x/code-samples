   5 BORDER 0: PAPER 0: INK 7: CLS
  10 FOR i=0 TO 31
  12 PRINT AT 0,i; PAPER 2;" "
  14 NEXT i
  16 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" BOMB DEFUSAL "
  20 PRINT AT 4,4; INK 5;"A bomb is ticking."
  22 PRINT AT 5,4; INK 5;"Cut the right wire before"
  24 PRINT AT 6,4; INK 5;"time runs out."
  26 PRINT AT 9,4; INK 7;"Press 1, 2, 3 or 4"
  28 PRINT AT 10,4; INK 7;"to cut a wire."
  30 PRINT AT 13,4; INK 2; BRIGHT 1;"5 bombs. Each one faster."
  32 PRINT AT 21,5; INK 7; FLASH 1;"Press any key to start"; FLASH 0
  34 PAUSE 0
