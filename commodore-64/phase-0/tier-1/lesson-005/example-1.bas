10 rem unsorted scores
20 dim sc(4),nm$(4)
30 sc(0)=850:nm$(0)="alice"
40 sc(1)=620:nm$(1)="bob"
50 sc(2)=1200:nm$(2)="carol"
60 sc(3)=420:nm$(3)="dave"
70 sc(4)=950:nm$(4)="eve"
80 print chr$(147);"high score hall"
90 print
100 for i=0 to 4
110 print i+1;". ";nm$(i);tab(15);sc(i)
120 next i
