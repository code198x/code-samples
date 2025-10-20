10 rem independent voices arpeggio
20 rem setup adsr (required!)
30 poke 54277,9:poke 54278,0
40 poke 54284,9:poke 54285,0
50 poke 54291,9:poke 54292,0
60 rem set volume
70 poke 54296,15
80 rem note frequencies c,e,g
90 dim f(2):f(0)=4240:f(1)=5346:f(2)=6350
100 rem main loop
110 for n=0 to 2
120 rem voice 1 plays all notes
130 l=f(n) and 255:h=int(f(n)/256)
140 poke 54272,l:poke 54273,h
150 poke 54276,17
160 for t=1 to 20:next
170 poke 54276,16
180 next
190 rem voice 2 plays all notes
200 for n=0 to 2
210 l=f(n) and 255:h=int(f(n)/256)
220 poke 54279,l:poke 54280,h
230 poke 54283,17
240 for t=1 to 20:next
250 poke 54283,16
260 next
270 rem voice 3 plays all notes
280 for n=0 to 2
290 l=f(n) and 255:h=int(f(n)/256)
300 poke 54286,l:poke 54287,h
310 poke 54290,17
320 for t=1 to 20:next
330 poke 54290,16
340 next
