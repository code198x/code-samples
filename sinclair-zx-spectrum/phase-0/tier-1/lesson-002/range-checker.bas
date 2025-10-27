10 REM Range Checker
20 REM Multiple IF conditions
30 CLS
40 PRINT AT 5,8;"RANGE CHECKER"
50 PRINT AT 8,2;"Enter a number (1-100):"
60 INPUT N
70 CLS
80 PRINT AT 6,4;"You entered: ";N
90 IF N<1 THEN PRINT AT 10,3;"Too low! Try 1-100."
100 IF N>100 THEN PRINT AT 10,3;"Too high! Try 1-100."
110 IF N>=1 AND N<=100 THEN PRINT AT 10,5;"Perfect! In range."
120 IF N>=1 AND N<=100 AND N<50 THEN PRINT AT 12,2;"That's in the lower half!"
130 IF N>=1 AND N<=100 AND N>=50 THEN PRINT AT 12,2;"That's in the upper half!"
140 PAUSE 0
