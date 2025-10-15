REM Data format
DATA "SPEAKER","Line of text", delay

REM Skip support
GET K$:IF K$<>"" THEN RETURN

REM Timer loop
IF TI>FRAME THEN FRAME=FRAME+1
