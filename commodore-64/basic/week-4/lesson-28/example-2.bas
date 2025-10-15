HIT=PEEK(53278)     : REM sprite-sprite collision register
BG=PEEK(53279)      : REM sprite-background register
IF HIT AND 1 THEN   : REM sprite 0 involved
IF HIT AND 2 THEN   : REM sprite 1 involved
