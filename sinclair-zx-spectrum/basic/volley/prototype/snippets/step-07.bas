10 BORDER0: PAPER0: INK7: BRIGHT1: CLS
15 PRINTAT3,3;"VOLLEY";AT5,3;"A up   Z down";AT7,3;"Q quits. Keep the rally going.";AT9,3;"S to serve": GO SUB800: CLS
35 PAPER1: FORr=3 TO19: PRINTATr,2;"                            ": NEXTr
40 FORc=2 TO30: PRINTPAPER5;AT2,c;" ";AT20,c;" ": NEXTc
50 FORr=3 TO19: PRINTPAPER5;ATr,30;" ": NEXTr
500 FORr=p TOp+2: PRINTPAPER6;ATr,2;" ": NEXTr
620 LETdx=1: LETnx=4: LETscore=score+1: PRINTPAPER0;AT0,19;score
700 PRINTPAPER0;AT21,1;"Miss. R retry, Q quit."
900 PRINTPAPER0;AT21,1;"Finished.                    ": STOP
