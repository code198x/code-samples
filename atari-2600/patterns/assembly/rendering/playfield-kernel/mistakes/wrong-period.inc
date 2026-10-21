; Deliberately broken fragment for diagnosis; not a reusable implementation.
; BEGIN WRONG
    ldx #30
; END WRONG

; Correct replacement for the same location.
; BEGIN FIX
    ldx #29
; END FIX
