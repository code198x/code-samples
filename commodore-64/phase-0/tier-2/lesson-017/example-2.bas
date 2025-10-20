10 rem colored sprite
20 rem create simple sprite shape
30 for i=0 to 62:poke 832+i,255:next
40 rem position sprite center screen
50 poke 53248,160:poke 53249,120
60 poke 2040,13
70 poke 53287,7:rem sprite 0 color = yellow
80 poke 53269,1:rem enable sprite 0
90 get a$:if a$="" then 90
