RESTORE label          : REM rewind DATA pointer to label
FOR R=0 TO H:FOR C=0 TO W:READ MAP(R,C):NEXT:C NEXT
READ EX(I),EY(I)       : REM enemy positions
READ TITLE$            : REM strings bundled with rooms
