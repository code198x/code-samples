280 LET s$=""
287 LET cap=16
290 GO TO 980
980 LET s$=s$+STR$ (INT (RND*4)+1)
990 PRINT AT 19,0;"Rounds completed: ";done
1170 IF done=cap THEN GO TO 1850
1180 GO TO 980
1850 PRINT AT 18,0;"Challenge complete.           "
1860 PRINT AT 19,0;"Rounds completed: ";done
1870 STOP
