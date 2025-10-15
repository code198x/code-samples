PRINT CHR$(19)                    : REM home cursor
RIGHT$("0000"+STR$(N),4)          : REM zero-padded numbers
LEFT$(T$,N)                       : REM cap string length
100 IF LEFT$(S$,1)=" " THEN S$=MID$(S$,2):GOTO 100      : REM trim leading spaces
LOG$(I)=LOG$(I-1)                 : REM shift history buffer
