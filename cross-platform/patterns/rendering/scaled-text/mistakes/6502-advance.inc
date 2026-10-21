; SPDX-License-Identifier: MIT
; Deliberately wrong: enlarged glyphs retain an eight-pixel step.
; BEGIN WRONG
    clc
    lda t_next_x
    adc #8
    sta t_next_x
    lda t_next_x+1
    adc #0
    sta t_next_x+1
; END WRONG
; BEGIN FIX
    clc
    lda t_next_x
    adc t_advance
    sta t_next_x
    lda t_next_x+1
    adc t_advance+1
    sta t_next_x+1
; END FIX
