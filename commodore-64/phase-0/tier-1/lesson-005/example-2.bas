10 dim it$(4)
20 it$(0)="sword"
30 it$(1)="shield"
40 it$(2)="potion"
50 it$(3)="key"
60 print "your inventory:"
70 for i=0 to 3
80 print i+1;". ";it$(i)
90 next i
100 end
