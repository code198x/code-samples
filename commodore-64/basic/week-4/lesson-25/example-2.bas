832-894          : REM sprite 0 data block (default)
POKE 2040,block  : REM sprite pointer (block = address/64)
POKE 53287,col   : REM sprite colour
POKE 53248,x     : REM sprite X position (0-255)
POKE 53249,y     : REM sprite Y position (0-255)
POKE 53269,1     : REM enable sprite 0
