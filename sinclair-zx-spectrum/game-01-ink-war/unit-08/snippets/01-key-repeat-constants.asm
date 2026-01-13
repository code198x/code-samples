; ----------------------------------------------------------------------------
; Key Repeat Constants
; ----------------------------------------------------------------------------
; Controls how quickly the cursor moves when holding a direction key

; Input timing
KEY_DELAY   equ     8               ; Frames between key repeats

; Variables needed:
; last_key:       defb    0         ; Previous frame's key for repeat detection
; key_timer:      defb    0         ; Countdown for key repeat delay
