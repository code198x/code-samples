  10 BORDER 0: PAPER 0: INK 7: CLS
  20 REM === Draw panel ===
  30 FOR r=5 TO 14
  40 PRINT AT r,4; PAPER 2;"                        "
  50 NEXT r
  60 PRINT AT 9,15; PAPER 2; INK 7;"1"
  70 PAUSE 50
  80 REM === Flash bright ===
  90 FOR r=5 TO 14
 100 PRINT AT r,4; PAPER 2; BRIGHT 1;"                        "
 110 NEXT r
 120 PRINT AT 9,15; PAPER 2; BRIGHT 1; INK 7;"1"
 130 BEEP 0.3,0
 140 REM === Back to normal ===
 150 FOR r=5 TO 14
 160 PRINT AT r,4; PAPER 2;"                        "
 170 NEXT r
 180 PRINT AT 9,15; PAPER 2; INK 7;"1"
