55 GO TO 2000
2000 PRINT AT 3,0;"Watch the order of the signals."
2010 PRINT AT 5,0;"Repeat it with keys 1 to 4."
2020 PRINT AT 7,0;"Wait for each cue to finish."
2030 PRINT AT 9,0;"Each round adds one choice."
2040 PRINT AT 11,0;"Complete 16 rounds to finish."
2050 PRINT AT 13,0;"Hold q to quit, even in WATCH."
2060 PRINT AT 15,0;"Release keys, then s to start."
2070 GO SUB 1600
2080 LET k$=INKEY$
2090 IF k$="" THEN GO TO 2080
2100 IF k$="q" THEN GO TO 1900
2110 IF k$<>"s" THEN GO TO 2070
2120 GO SUB 1600
2130 CLS
2140 PRINT "BRIGHT SPARK"
2150 GO TO 100
