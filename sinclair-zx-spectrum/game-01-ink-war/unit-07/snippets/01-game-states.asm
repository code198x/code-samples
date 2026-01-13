; ----------------------------------------------------------------------------
; Game States
; ----------------------------------------------------------------------------
; State machine constants for game flow

; Game states (state machine)
GS_TITLE    equ     0
GS_PLAYING  equ     1
GS_RESULTS  equ     2

; Title screen positions
TITLE_ROW   equ     8
TITLE_COL   equ     12              ; "INK WAR" (7 chars) centred: (32-7)/2=12.5
PROMPT_ROW  equ     16
PROMPT_COL  equ     5               ; "PRESS ANY KEY TO START" (22 chars): (32-22)/2=5
