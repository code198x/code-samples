; Deliberately broken fragment for diagnosis; not a reusable implementation.
; BEGIN WRONG
    lda #0
    sta (ML),y
; END WRONG

; Correct replacement for the same location.
; BEGIN FIX
    lda ML+6
    sta (ML),y
; END FIX
