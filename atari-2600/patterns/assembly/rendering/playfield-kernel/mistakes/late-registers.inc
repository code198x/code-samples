; Deliberately broken fragment for diagnosis; not a reusable implementation.
; BEGIN WRONG
    !fill 12,$ea
    lda PF_BUFFER,y
; END WRONG

; Correct replacement for the same location.
; BEGIN FIX
    lda PF_BUFFER,y
; END FIX
