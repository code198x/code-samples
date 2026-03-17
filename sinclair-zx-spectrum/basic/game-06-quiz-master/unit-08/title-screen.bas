   5 BORDER 0: PAPER 0: INK 7: CLS
  10 FOR i=0 TO 31
  12 PRINT AT 0,i; PAPER 2;" "
  14 NEXT i
  16 PRINT AT 0,9; PAPER 2; INK 7; BRIGHT 1;" QUIZ MASTER "
  20 PRINT AT 4,3; INK 5;"Answer questions from four"
  22 PRINT AT 5,3; INK 5;"categories."
  24 PRINT AT 7,3; INK 7;"Press A, B, C or D to answer."
  26 PRINT AT 10,6; INK 6;"Science"
  28 PRINT AT 10,18; INK 3;"History"
  30 PRINT AT 12,6; INK 4;"Geography"
  32 PRINT AT 12,18; INK 5;"Entertainment"
  34 PRINT AT 16,3; INK 7;"8 questions. How many can"
  35 PRINT AT 17,3; INK 7;"you get right?"
  36 PRINT AT 21,5; INK 7; FLASH 1;"Press any key to start"; FLASH 0
  38 PAUSE 0
