10 rem enable sprite 0
20 rem first, create simple sprite data
30 for i=0 to 62:poke 832+i,255:next
40 rem now position and enable sprite
50 poke 53248,160:poke 53249,120
60 poke 2040,13
70 poke 53269,1
80 get a$:if a$="" then 80
