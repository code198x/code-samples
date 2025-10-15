REM Timing
TI$="000000"
GOSUB 1000
PRINT TI

REM Address table
ADR(I)=BASE+I

REM Cached value
C=PEEK(53280):REM once per frame
