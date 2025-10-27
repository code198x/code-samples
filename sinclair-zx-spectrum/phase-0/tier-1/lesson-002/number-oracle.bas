10 REM The Number Oracle
20 REM Interactive INPUT and IF demo
30 CLS
40 PRINT AT 5,5;"THE NUMBER ORACLE"
50 PRINT AT 8,4;"What is your name?"
60 INPUT N$
70 PRINT AT 10,4;"Hello ";N$;"!"
80 PRINT AT 12,2;"I'm thinking of 7..."
90 PRINT AT 13,2;"Guess my number (1-10):"
100 INPUT G
110 IF G=7 THEN PRINT AT 15,6;"Lucky! You got it!"
120 IF G<>7 THEN PRINT AT 15,4;"Sorry! It was 7."
130 PAUSE 0
