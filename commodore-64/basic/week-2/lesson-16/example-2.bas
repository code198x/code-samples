STATE = 1 : ON STATE GOTO 1000,2000,3000   : REM title/play/game over
LOC = SCREEN + ROW*40 + COL                : REM screen address
READ MAP(R,C) : RESTORE 9000               : REM DATA-driven map load
DEF FNBONUS(L)=L*80                        : REM level-based bonuses
DEF FNPEN(S)=S-25                          : REM damage penalty helper
