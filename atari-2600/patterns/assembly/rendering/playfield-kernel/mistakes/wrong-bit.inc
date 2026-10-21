; Deliberately broken fragment for diagnosis; not a reusable implementation.
; BEGIN WRONG
    !byte $80,$40,$20,$10,$80,$40,$20,$10,$08,$04,$02,$01
; END WRONG

; Correct replacement for the same location.
; BEGIN FIX
    !byte $10,$20,$40,$80,$80,$40,$20,$10,$08,$04,$02,$01
; END FIX
