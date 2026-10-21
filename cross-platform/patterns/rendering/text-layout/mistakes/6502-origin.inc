; Deliberately broken diagnostic. Do not include in the working component.
; BEGIN WRONG
    lda l_temp
    sta l_x
    lda l_temp+1
    sta l_x+1
; END WRONG
; BEGIN FIX
    lda l_left
    sta l_x
    lda l_left+1
    sta l_x+1
    clc
    lda l_x
    adc l_temp
    sta l_x
    lda l_x+1
    adc l_temp+1
    sta l_x+1
; END FIX
