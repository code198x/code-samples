; Deliberately broken fragment for diagnosis; not a reusable implementation.
; BEGIN WRONG
    lda #33
    sec
; END WRONG

; Correct replacement for the same location.
; BEGIN FIX
    lda #32
    sec
; END FIX
