REM Random basics
RND(-TI)        : REM seed using system clock
X = RND(1)      : REM 0 <= X < 1
R = INT(RND(1)*6)+1 : REM dice 1-6
IF RND(1)<0.2 THEN PRINT "SURPRISE!"
