10 s=7
20 print "guess a number (1-10)"
30 input g
40 if g=s then print "you win!": goto 80
50 if g<s then print "too low!"
60 if g>s then print "too high!"
70 goto 20
80 end
