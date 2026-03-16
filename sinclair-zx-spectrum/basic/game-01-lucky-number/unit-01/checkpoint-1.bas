   1 REM Lucky Number v3
   5 BORDER 0: PAPER 0: INK 7: CLS
  10 REM === Rainbow cascade ===
  20 FOR i=0 TO 7
  30 FOR j=0 TO 31
  40 PRINT AT i,j; PAPER i;" "
  50 NEXT j
  55 BEEP 0.01,i*4+20
  60 NEXT i
