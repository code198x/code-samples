  10 CLS
  20 PRINT AT 0,0;"Hold any key..."
  30 PRINT AT 2,0;"                "
  40 LET k$=INKEY$
  50 IF k$<>"" THEN PRINT AT 2,0;"Key: "; k$
  60 IF k$="" THEN PRINT AT 2,0;"(nothing)"
  70 GO TO 30
