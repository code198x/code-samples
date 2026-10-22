1000 RETURN
1010 REM No field wait: this counts BASIC iterations.
1100 C%=0
1110 IF K% AND NOT P% THEN N%=(N%+S%)AND255:C%=1
1120 P%=K%
1130 RETURN
