   5 BORDER 0: PAPER 0: INK 7: CLS
  10 FOR i=0 TO 31
  12 PRINT AT 0,i; PAPER 1;" "
  14 NEXT i
  16 PRINT AT 0,8; PAPER 1; INK 7; BRIGHT 1;" COLOUR FLOOD "
  20 PRINT AT 3,3; INK 5;"Watch the colours flash."
  22 PRINT AT 4,3; INK 5;"Repeat the sequence."
  24 PRINT AT 7,3; INK 7;"Press 1, 2, 3 or 4:"
  26 FOR i=0 TO 1
  28 PRINT AT 10+i,4; PAPER 1;"  1  "
  30 PRINT AT 10+i,11; PAPER 2;"  2  "
  32 PRINT AT 10+i,18; PAPER 4;"  3  "
  34 PRINT AT 10+i,25; PAPER 6;"  4  "
  36 NEXT i
  38 PRINT AT 14,3; INK 2; BRIGHT 1;"Get one wrong and it is"
  40 PRINT AT 15,3; INK 2; BRIGHT 1;"game over!"
  42 PRINT AT 21,5; INK 7; FLASH 1;"Press any key to start"; FLASH 0
  44 PAUSE 0
