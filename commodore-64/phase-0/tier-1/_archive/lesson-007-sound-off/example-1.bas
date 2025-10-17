10 poke 54296,15      : rem volume
20 poke 54277,9       : rem attack/decay
30 poke 54273,37      : rem freq low
40 poke 54272,17      : rem freq high
50 poke 54276,17      : rem triangle + gate
60 for t=1 to 250: next t
70 poke 54276,16      : rem gate off
