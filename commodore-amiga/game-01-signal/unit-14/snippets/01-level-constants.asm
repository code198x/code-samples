; Level constants
MAX_LEVEL       equ 8           ; Maximum level (speed caps here)
LEVEL_X         equ 152         ; Pixel X position for level display (centre)
LEVEL_Y         equ 236         ; Same row as score/timer
LEVEL_BONUS     equ 100         ; Bonus points per level complete

; Level variable
level:          dc.w    1           ; Current level (1-8+)

; Base speeds for cars (used to calculate speed per level)
; Actual speed = base_speed + (level-1) * sign(base_speed)
base_speeds:
            dc.w    1               ; Car 0: right, slow
            dc.w    1               ; Car 1: right, slow
            dc.w    -2              ; Car 2: left, medium
            dc.w    -2              ; Car 3: left, medium
            dc.w    2               ; Car 4: right, medium
            dc.w    2               ; Car 5: right, medium
            dc.w    -1              ; Car 6: left, slow
            dc.w    -1              ; Car 7: left, slow
            dc.w    3               ; Car 8: right, fast
            dc.w    3               ; Car 9: right, fast
