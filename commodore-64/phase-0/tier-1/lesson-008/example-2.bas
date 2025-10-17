RND(-TI)               : REM seed randomness once per run
TARGET$ = CHR$(INT(RND(1)*26)+65)
TI$ = "000000"         : REM reset system clock
GET K$: IF K$="" THEN ...
IF K$=TARGET$ THEN SCORE = SCORE + 10 : GOSUB 400 : GOTO 60
LIVES = LIVES - 1
GOSUB 500
