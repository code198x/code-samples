  10 BORDER 0: PAPER 0: INK 7: CLS
  20 REM Draw all four panels
  30 PAPER 2
  40 FOR r = 2 TO 9: PRINT AT r, 1; "              ": NEXT r
  50 PAPER 1
  60 FOR r = 2 TO 9: PRINT AT r, 17; "              ": NEXT r
  70 PAPER 4
  80 FOR r = 12 TO 19: PRINT AT r, 1; "              ": NEXT r
  90 PAPER 6
 100 FOR r = 12 TO 19: PRINT AT r, 17; "              ": NEXT r
 110 PAPER 0
 120 PRINT AT 21, 1; "Watch the red panel..."
 130 PAUSE 50
 140 REM Flash panel 1 (red) - use BRIGHT
 150 PAPER 2: BRIGHT 1
 160 FOR r = 2 TO 9: PRINT AT r, 1; "              ": NEXT r
 170 BEEP 0.3, 5
 180 BRIGHT 0
 190 FOR r = 2 TO 9: PRINT AT r, 1; "              ": NEXT r
 200 PAPER 0
 210 PRINT AT 21, 1; "Did you see it?          "
