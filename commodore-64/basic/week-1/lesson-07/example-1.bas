NEW
10 REM --- INITIALISE SID VOICE 1 ---
20 POKE 54295,15      : REM maximum volume
30 POKE 54296,0       : REM no filters for now
40 POKE 54273,0       : REM low byte of frequency
50 POKE 54272,50      : REM high byte (50 ≈ middle C)
60 POKE 54275,17      : REM attack/decay (1 frame attack, 7 frame decay)
70 POKE 54276,240     : REM sustain/release (full sustain, fast release)
80 POKE 54277,33      : REM waveform = triangle + gate on (32+1)
90 FOR T=1 TO 200: NEXT T
100 POKE 54277,32     : REM gate off (leave waveform select)
