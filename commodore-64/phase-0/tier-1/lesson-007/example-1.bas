10 rem single colour
20 print chr$(147);"poke 53280,col"
30 print
40 print "try different colours:"
50 input "colour (0-15)";c
60 poke 53280,c
70 goto 50
