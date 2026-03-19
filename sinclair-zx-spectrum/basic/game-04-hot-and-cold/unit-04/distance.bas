  10 CLS
  20 LET x=10: LET y=5
  30 LET tx=25: LET ty=15
  40 PRINT AT y,x;"+"
  50 PRINT AT ty,tx;"*"
  60 LET dx=x-tx
  70 LET dy=y-ty
  80 LET d=SQR (dx^2+dy^2)
  90 PRINT AT 0,0;"Distance: ";d
