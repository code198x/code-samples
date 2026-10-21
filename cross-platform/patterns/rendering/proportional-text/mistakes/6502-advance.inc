; WRONG: fixed eight-pixel movement disagrees with proportional measurement.
; BEGIN WRONG
    clc
    lda l_x
    adc #8
    sta l_x
    lda l_x+1
    adc #0
    sta l_x+1
; END WRONG
; BEGIN FIX
    clc
    lda l_x
    adc l_advance
    sta l_x
    lda l_x+1
    adc l_advance+1
    sta l_x+1
; END FIX
