REM Reverse video highlight
PRINT CHR$(18);"> ";ITEM$(SEL);CHR$(146)

REM Joystick port 2 bits
UP = 1
DOWN = 2
FIRE = 16

REM Dispatch stored line numbers
GOSUB ACTION(SEL)
