10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM m$(8, 16)
30 FOR i = 1 TO 8
40 READ m$(i)
50 NEXT i
60 REM draw map
70 FOR r = 1 TO 8
80 FOR c = 1 TO 16
90 IF m$(r)(c TO c) = "#" THEN PRINT AT r + 2, c + 2; INK 1; CHR$ 143
100 NEXT c
110 NEXT r
500 DATA "################"
510 DATA "#              #"
520 DATA "#  ## ####  #  #"
530 DATA "#     #     #  #"
540 DATA "#  ####  #     #"
550 DATA "#        #  #  #"
560 DATA "#   ##      #  #"
570 DATA "################"
