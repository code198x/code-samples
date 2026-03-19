  10 REM Text utilities
  20 REM Pattern: reusable across games
  30 REM
  40 REM Centre text:
  50 REM   LET r=10: LET t$="Hello": GO SUB 3000
  60 REM   Set INK, BRIGHT, FLASH etc before calling
  70 REM
  80 REM Clear row (cols 2-29, inside a frame):
  90 REM   LET r=10: GO SUB 3100
 100 REM
3000 REM === Centre text t$ on row r ===
3010 PRINT AT r,(32-LEN t$)/2;t$
3020 RETURN
3100 REM === Clear row r (cols 2-29) ===
3110 PRINT AT r,2;"                            "
3120 RETURN
