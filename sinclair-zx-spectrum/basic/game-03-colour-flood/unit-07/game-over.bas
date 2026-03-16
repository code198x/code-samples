  88 BORDER 2
  90 BEEP 0.5,-10
  92 PRINT AT 13,1; INK 2; BRIGHT 1;"Wrong! Game over.   "
  94 PRINT AT 15,1; INK 7;"You scored ";sc
  96 IF sc<=3 THEN PRINT AT 17,1; INK 3;"Keep practising!"
  97 IF sc>3 AND sc<=7 THEN PRINT AT 17,1; INK 6;"Good memory!"
  98 IF sc>7 THEN PRINT AT 17,1; INK 4; BRIGHT 1;"Incredible!"
  99 BORDER 0: STOP
