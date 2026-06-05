  10 BORDER 0
  20 PAPER 0
  30 INK 7
  40 CLS
  50 LET t$ = "RAINBOW"
  60 FOR i = 1 TO 7
  70 INK i
  80 PRINT AT 10, 12 + i; t$(i)
  90 NEXT i
