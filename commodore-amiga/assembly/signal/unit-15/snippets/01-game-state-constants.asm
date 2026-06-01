; Game state constants (high-level game flow)
; These control which screen is active, separate from frog_state
GSTATE_TITLE    equ 0           ; Title screen, waiting for fire
GSTATE_PLAYING  equ 1           ; Active gameplay
GSTATE_OVER     equ 2           ; Game over screen

; Title screen position
TITLE_Y         equ 100         ; Vertical position for "SIGNAL" text

; Variables
game_state:     dc.w    0       ; High-level game state (title/playing/over)
fire_prev:      dc.w    0       ; Previous fire button state for edge detection
