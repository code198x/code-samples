INT(RND(1)*W)       : REM 0..W-1
INT(RND(1)*W)+O     : REM O..O+W-1
IF RND(1)<P THEN    : REM probability test
A=DEGREES*3.14159/180 : REM convert degrees to radians
X=CX+R*COS(A)       : REM circular X position
Y=CY+R*SIN(A)       : REM circular Y position
