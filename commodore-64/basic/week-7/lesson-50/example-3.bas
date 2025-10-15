REM State change detection
IF STATE<>LAST THEN GOSUB 2000

REM Timed animation
IF TI>=NEXTT THEN GOSUB 2100:NEXTT=TI+1

REM Colour cycle
POKE 646,COLORS(idx)
