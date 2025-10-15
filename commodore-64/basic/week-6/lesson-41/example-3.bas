REM State tracking
STATE=0 : REM 0=title,1=play,2=game over
LAST=-1 : REM forces first draw

REM Dispatching
ON STATE+1 GOSUB 2000,3000,4000

REM Input buffer
GET K$:IF K$<>"" THEN KEY$=K$
KEY$="" : REM clear after handling
