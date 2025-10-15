NEW
10 REM --- SPRITE PRIMER ---
20 PRINT CHR$(147)
30 FOR I=832 TO 894:POKE I,255:NEXT I      : REM fill block with solid pixels
40 POKE 2040,13                              : REM sprite 0 pointer -> block 13 (832/64)
50 POKE 53287,1                              : REM colour = white
60 POKE 53248,120:POKE 53249,100            : REM position (X,Y)
70 POKE 53269,1                              : REM enable sprite 0
