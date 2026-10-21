; Deliberately broken fragment for diagnosis; not a reusable implementation.
; BEGIN WRONG
    lda #>graphics
    sta LIST+10
    lda #96
    sta LIST+11
    lda #0
    sta LIST+12
    sta LIST+13
    lda #30
    sta LIST+9
; END WRONG

; Correct replacement for the same location.
; BEGIN FIX
    lda #0
    sta LIST+9
; END FIX
