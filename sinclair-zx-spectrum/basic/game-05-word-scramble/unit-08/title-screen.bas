   5 BORDER 0: PAPER 0: INK 7: CLS
  10 FOR i=0 TO 31
  12 PRINT AT 0,i; PAPER 2;" "
  14 NEXT i
  16 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" WORD SCRAMBLE "
  20 PRINT AT 4,4; INK 5;"Unscramble the letters to"
  22 PRINT AT 5,4; INK 5;"find the hidden word!"
  24 PRINT AT 8,4; INK 6;"10 rounds. Words get longer."
  26 PRINT AT 10,4; INK 7;"Type your answer and press"
  28 PRINT AT 11,4; INK 7;"ENTER to guess."
  30 PRINT AT 15,4; INK 3;"Short words are easy..."
  32 PRINT AT 16,4; INK 2;"Long words are not."
  34 PRINT AT 21,6; INK 7; FLASH 1;"Press any key to start"; FLASH 0
  36 PAUSE 0
