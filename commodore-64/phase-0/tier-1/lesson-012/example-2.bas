10 rem wasd key detection
20 print chr$(147)
30 print "use wasd keys (q to quit)"
40 print
50 get a$
60 if a$="" then 50
70 if a$="q" then end
80 if a$="w" then print "up"
90 if a$="s" then print "down"
100 if a$="a" then print "left"
110 if a$="d" then print "right"
120 goto 50
