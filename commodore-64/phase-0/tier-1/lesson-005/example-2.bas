10 rem sorted high scores
20 dim sc(4),nm$(4)
30 sc(0)=850:nm$(0)="alice"
40 sc(1)=620:nm$(1)="bob"
50 sc(2)=1200:nm$(2)="carol"
60 sc(3)=420:nm$(3)="dave"
70 sc(4)=950:nm$(4)="eve"
80 print chr$(147);"sorting..."
90 rem bubble sort (descending)
100 for i=0 to 3
110 for j=0 to 3-i
120 if sc(j)>sc(j+1) then 160
130 t=sc(j):sc(j)=sc(j+1):sc(j+1)=t
140 t$=nm$(j):nm$(j)=nm$(j+1):nm$(j+1)=t$
150 rem swapped
160 next j
170 next i
180 print chr$(147);"high score hall"
190 print
200 for i=0 to 4
210 print i+1;". ";nm$(i);tab(15);sc(i)
220 next i
