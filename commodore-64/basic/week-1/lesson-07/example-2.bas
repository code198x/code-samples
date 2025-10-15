REM SID Voice 1 essentials
POKE 54295, V     : REM master volume (0-15)
POKE 54272, FHI   : REM frequency high byte
POKE 54273, FLO   : REM frequency low byte
POKE 54275, AD    : REM attack/decay packed into one byte
POKE 54276, SR    : REM sustain/release packed into one byte
POKE 54277, WF    : REM waveform + gate bit (1=triangle, 17=triangle+gate)
