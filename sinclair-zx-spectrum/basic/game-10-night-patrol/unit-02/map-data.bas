10 CLS
20 PRINT "Loading map data..."
30 PRINT
40 DIM m$(8, 16)
50 FOR i = 1 TO 8
60 READ m$(i)
70 NEXT i
80 PRINT "Map loaded:"
90 PRINT
100 FOR r = 1 TO 8
110 PRINT m$(r)
120 NEXT r
130 PRINT
140 PRINT "Rows: 8  Cols: 16"
500 DATA "################"
510 DATA "#              #"
520 DATA "#  ## ####  #  #"
530 DATA "#     #     #  #"
540 DATA "#  ####  #     #"
550 DATA "#        #  #  #"
560 DATA "#   ##      #  #"
570 DATA "################"
