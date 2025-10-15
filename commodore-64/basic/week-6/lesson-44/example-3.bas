REM Read once per frame
COL=PEEK(53279)

REM Test bullet (sprite 1) vs enemy (sprite 2)
IF (COL AND 2) AND (COL AND 4) THEN GOSUB 5200

REM Reset projectile
SHOT=0:POKE 53251,0:COOL=10
