10 CLS
20 PRINT "Word List"
30 PRINT
40 DIM w$(50, 7)
50 DIM l(50)
60 FOR i = 1 TO 50
70 READ l(i), w$(i)
80 NEXT i
90 PRINT "Loaded 50 words:"
100 PRINT
110 FOR i = 1 TO 50
120 PRINT w$(i)(1 TO l(i)); " ";
130 IF i / 10 = INT (i / 10) THEN PRINT
140 NEXT i
500 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
510 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
520 DATA 3,"jam",3,"big",3,"top",3,"hop",3,"zip"
530 DATA 3,"van",3,"wet",3,"map",3,"dot",3,"log"
540 DATA 4,"bird",4,"fish",4,"lamp",4,"tree",4,"star"
550 DATA 4,"ball",4,"frog",4,"drum",4,"bell",4,"corn"
560 DATA 4,"wave",4,"king",4,"farm",4,"cave",4,"lake"
570 DATA 5,"house",5,"cloud",5,"river",5,"flame",5,"plant"
580 DATA 5,"storm",5,"brave",5,"ocean",5,"night",5,"tiger"
590 DATA 6,"dragon",6,"garden",5,"magic",5,"swift",5,"queen"
