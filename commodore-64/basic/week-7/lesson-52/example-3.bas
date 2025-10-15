REM Sentinel-based scan
RESTORE base
READ id:IF id=0 THEN END

REM Skip block quickly
FOR SK=1 TO rows+2:READ dummy$:NEXT

REM Load matching level
FOR R=1 TO rows:READ MAP$(R):NEXT
