10 rem simple get demo
20 print chr$(147)
30 print "press any key (q to quit)"
40 get a$
50 if a$="" then 40
60 if a$="q" then end
70 print "you pressed: ";a$
80 goto 30
