CHR$(18) / CHR$(146)             : REM reverse video on/off
ON SEL+1 GOTO ...                : REM menu action routing
LEFT$(MSG$,36)                   : REM cap dialogue line length
LOG$(I)=LOG$(I-1)                : REM rolling buffer reuse
