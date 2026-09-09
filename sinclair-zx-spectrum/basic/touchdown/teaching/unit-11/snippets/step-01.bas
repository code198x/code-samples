80 PRINT AT 10,2;"Pad: ====  Safe speed: 0 to 12"
640 FOR c=23 TO 26: PRINT PAPER 6;INK 0;AT 20,c;"=": NEXT c
720 IF side=0 AND x>=23 AND x<=26 THEN LET m$="Too fast for the pad."
730 IF side=0 AND x>=23 AND x<=26 AND v<=12 AND v>=0 THEN LET m$="Safe landing!"
