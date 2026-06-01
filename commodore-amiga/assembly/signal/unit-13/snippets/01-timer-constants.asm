; Timer constants
TIMER_START     equ 3000        ; 60 seconds at 50Hz PAL (60 * 50)
TIMER_X         equ 56          ; Pixel X position for timer (left side)
TIMER_Y         equ 236         ; Same row as score
TIMER_DIGITS    equ 2           ; Display 2 digits (00-60)

; Timer variable
timer:          dc.w    3000        ; Countdown timer in frames
timer_digits:   dc.w    0,0         ; Buffer for 2 decimal digits
