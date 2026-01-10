; Visual feedback for claim attempts

; Successful claim - green flash
        ld a, 4                 ; Green
        out (BORDER_PORT), a
        call short_delay
        xor a                   ; Black
        out (BORDER_PORT), a

; Failed claim (cell occupied) - red flash
        ld a, 2                 ; Red
        out (BORDER_PORT), a
        call short_delay
        xor a
        out (BORDER_PORT), a

; This feedback is temporary - we'll add sound in Phase 2
; Visual feedback helps players understand what happened
