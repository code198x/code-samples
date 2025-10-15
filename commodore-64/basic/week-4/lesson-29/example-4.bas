TI$="000000"                 : REM reset timer
SECS=INT((TARGET-TI)/60)      : REM seconds remaining
RIGHT$("000"+STR$(SCORE),3)  : REM zero-padded score
PRINT CHR$(19);"..."         : REM redraw HUD in place
