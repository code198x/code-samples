; Game state constants

STATE_PLAYING   equ 0       ; Game in progress
STATE_GAME_OVER equ 1       ; All cells claimed

TOTAL_CELLS     equ 64      ; 8x8 board

; Variables
game_state:     defb STATE_PLAYING  ; Starts in playing state
