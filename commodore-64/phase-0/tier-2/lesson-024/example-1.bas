10 rem adsr instrument comparison
20 rem setup volume
30 poke 54296,15
40 rem organ sound - instant attack, sustain
50 poke 54277,0:poke 54278,240
60 poke 54272,57:poke 54273,17
70 poke 54276,17
80 for t=1 to 60:next
90 poke 54276,16
100 for t=1 to 30:next
110 rem piano - fast attack, quick decay
120 poke 54277,9:poke 54278,0
130 poke 54272,57:poke 54273,17
140 poke 54276,17
150 for t=1 to 60:next
160 poke 54276,16
170 for t=1 to 30:next
180 rem violin - slow attack, long release
190 poke 54277,35:poke 54278,244
200 poke 54272,57:poke 54273,17
210 poke 54276,17
220 for t=1 to 60:next
230 poke 54276,16
240 for t=1 to 60:next
