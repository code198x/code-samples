10 rem three voice chord
20 rem setup adsr (required!)
30 poke 54277,9:poke 54278,0
40 poke 54284,9:poke 54285,0
50 poke 54291,9:poke 54292,0
60 rem set volume
70 poke 54296,15
80 rem voice 1 - low c (262 hz)
90 poke 54272,8:poke 54273,16
100 poke 54276,17
110 rem voice 2 - e (330 hz)
120 poke 54279,161:poke 54280,20
130 poke 54283,17
140 rem voice 3 - g (392 hz)
150 poke 54286,193:poke 54287,24
160 poke 54290,17
170 rem play for 2 seconds
180 for t=1 to 120:next
190 rem release all voices
200 poke 54276,16
210 poke 54283,16
220 poke 54290,16
