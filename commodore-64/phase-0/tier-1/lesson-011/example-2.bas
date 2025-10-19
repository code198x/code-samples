10 rem waveform comparison
20 poke 54296,15
30 rem triangle wave
40 poke 54277,9:poke 54278,0
50 poke 54273,25:poke 54272,177
60 poke 54276,17
70 for i=1 to 1000:next i
80 poke 54276,16
90 rem sawtooth wave
100 poke 54276,33
110 for i=1 to 1000:next i
120 poke 54276,32
130 rem pulse wave
140 poke 54276,65
150 for i=1 to 1000:next i
160 poke 54276,64
