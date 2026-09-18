240 LET plant=100
2020 LET left=grain-feed-plant
2060 IF plant>2*fed THEN LET ok=0: LET m$="Too few fed workers."
2070 IF plant>land THEN LET ok=0: LET m$="Planting exceeds your land."
2160 PRINT AT 9,1; "P  Plant acres"; AT 9,17;plant; AT 9,25;plant
2200 PRINT AT 14,1; "Fed workers can plant: ";2*fed
