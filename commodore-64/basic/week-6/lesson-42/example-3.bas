REM Seed randomness
R=RND(-TI)

REM Weighted state change
IF STATE=0 AND DIST<140 AND RND(1)<.3 THEN STATE=1

REM Burst timer during chase
IF STATE=1 THEN BURST=BURST-1:IF BURST<=0 THEN STATE=0
