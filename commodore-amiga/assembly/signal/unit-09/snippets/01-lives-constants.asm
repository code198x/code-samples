; Lives System Constants
; Start with 3 lives, game over when all lost

; Lives configuration
START_LIVES     equ 3

; Game states (extended)
STATE_IDLE      equ 0
STATE_HOPPING   equ 1
STATE_DYING     equ 2
STATE_GAMEOVER  equ 3           ; New: no lives remaining

; Life icon display
LIFE_ICON_W     equ 1           ; 16 pixels = 1 word
LIFE_ICON_H     equ 8
LIFE_ICON_X     equ 8           ; Left margin
LIFE_ICON_SPACING equ 20        ; Pixels between icons

; Variables
lives:          dc.w    3       ; Current life count
