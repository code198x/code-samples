REM Initialise table once
DIM LIB(3)
FOR I=1 TO 3:READ LIB(I):NEXT

REM Call by index
L=LIB(choice)
GOSUB L

REM Keep library block together
9000 REM LIBRARY START
