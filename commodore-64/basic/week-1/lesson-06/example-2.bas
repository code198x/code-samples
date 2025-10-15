REM Screen animation essentials
PRINT CHR$(147)        : REM clear screen
PRINT CHR$(19);        : REM home cursor
PRINT SPC(X); "*"      : REM draw at column X
FOR T=1 TO 120: NEXT T : REM frame delay
IF X=0 OR X=38 THEN D=-D
