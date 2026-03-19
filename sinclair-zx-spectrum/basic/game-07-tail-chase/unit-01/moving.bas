  10 REM A moving character
  20 BORDER 0: PAPER 0: INK 6: CLS
  30 LET x=2: LET y=10
  40 PRINT AT y,x;"@"
  50 PAUSE 15
  60 PRINT AT y,x;" "
  70 LET x=x+1
  80 IF x>30 THEN STOP
  90 GO TO 40
