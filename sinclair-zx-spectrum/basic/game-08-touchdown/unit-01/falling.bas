  10 CLS
  20 LET alt = 100
  30 PRINT AT 10, 10; "Alt: "; alt; "  "
  40 PAUSE 5
  50 LET alt = alt - 1
  60 IF alt = 0 THEN PRINT AT 12, 10; "LANDED": STOP
  70 GO TO 30
