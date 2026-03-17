   5 BORDER 0: PAPER 0: INK 7: CLS
  10 FOR i=0 TO 31
  12 PRINT AT 0,i; PAPER 2;" "
  14 NEXT i
  16 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" WORD SCRAMBLE "
  20 LET w$="castle"
  22 LET c=(32-LEN w$*2)/2
  24 PRINT AT 3,10; INK 5;"Original:"
  26 FOR i=1 TO LEN w$
  28 PRINT AT 5,c+i*2-2; PAPER 1;" "
  30 PRINT AT 6,c+i*2-2; PAPER 1;" "
  32 NEXT i
  34 FOR i=1 TO LEN w$
  36 PRINT AT 5,c+i*2-2; PAPER 1; INK 6; BRIGHT 1;w$(i TO i)
  38 BEEP 0.05,5+i*2
  40 NEXT i
  42 PAUSE 50
  44 PRINT AT 9,10; INK 5;"Reversed:"
  46 LET r$=""
  48 FOR i=LEN w$ TO 1 STEP -1
  50 LET r$=r$+w$(i TO i)
  52 NEXT i
  54 FOR i=1 TO LEN r$
  56 PRINT AT 11,c+i*2-2; PAPER 3;" "
  58 PRINT AT 12,c+i*2-2; PAPER 3;" "
  60 NEXT i
  62 FOR i=1 TO LEN r$
  64 PRINT AT 11,c+i*2-2; PAPER 3; INK 7; BRIGHT 1;r$(i TO i)
  66 BEEP 0.05,20-i*2
  68 NEXT i
