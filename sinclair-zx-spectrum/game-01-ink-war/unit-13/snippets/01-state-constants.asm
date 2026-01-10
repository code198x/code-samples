; Game state constants
; Three distinct states for a complete game loop

STATE_TITLE   equ 0       ; Showing title screen
STATE_PLAYING equ 1       ; Game in progress
STATE_RESULTS equ 2       ; Showing winner

game_state:   defb STATE_TITLE  ; Start at title
