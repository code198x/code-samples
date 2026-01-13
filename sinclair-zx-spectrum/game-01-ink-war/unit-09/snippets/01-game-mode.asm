; ----------------------------------------------------------------------------
; Game Mode Constants
; ----------------------------------------------------------------------------

; Game modes
GM_TWO_PLAYER equ   0
GM_VS_AI    equ     1

; AI timing
AI_DELAY    equ     25              ; Frames before AI moves (~0.5 sec)

; Variables needed:
; game_mode:      defb    0         ; 0=two player, 1=vs AI
; ai_timer:       defb    0         ; Countdown before AI moves
