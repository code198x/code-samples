140 RANDOMIZE
280 IF ok=0 THEN STOP
400 LET oldpop=pop: LET oldgrain=grain: LET oldland=land
410 LET grain=left
420 LET deaths=pop-fed: LET lost=lost+deaths: LET pop=fed
430 LET crop=2+INT (RND*4): LET harvest=plant*crop: LET grain=grain+harvest
440 LET newcomers=0
470 GO SUB 4000
480 STOP
4000 CLS
4010 PRINT AT 0,1; INK 6; BRIGHT 1; "YEARFALL"; AT 0,18; "HARVEST ";yr
4020 PRINT AT 2,1; "Yield: ";crop;" grain per acre"
4030 PRINT AT 4,1; INK 5; "GRAIN ACCOUNT"
4040 PRINT AT 6,1; "At start"; AT 6,23;oldgrain
4060 PRINT AT 8,1; "Food spent"; AT 8,23;feed
4070 PRINT AT 9,1; "Seed spent"; AT 9,23;plant
4080 PRINT AT 10,1; "Harvest added"; AT 10,23;harvest
4090 PRINT AT 12,1; INK 6; "Grain in store"; AT 12,23;grain
4100 PRINT AT 14,1; "People lost: ";deaths
4120 PRINT AT 16,1; INK 5; "People ";oldpop;" -> ";pop
4130 PRINT AT 17,1; INK 5; "Land   ";oldland;" -> ";land
4160 RETURN
