POKE 2040,frame          : REM sprite 0 frame pointer
FRAME=13                 : REM block 13 (address 832)
STEP=STEP+1              : REM count movement steps
IF STEP>threshold THEN FRAME=NEXT
