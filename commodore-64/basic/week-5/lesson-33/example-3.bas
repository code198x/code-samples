REM Window size and total entries
LINES=6
TOTAL=18
MAXPAGE=INT((TOTAL-1)/LINES)

REM Paging controls
IF K$="A" AND SP>0 THEN SP=SP-1
IF K$="D" AND SP<MAXPAGE THEN SP=SP+1

REM Calculate first line of the page
BASE=SP*LINES
