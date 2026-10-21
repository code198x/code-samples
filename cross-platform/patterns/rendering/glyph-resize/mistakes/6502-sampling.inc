; SPDX-License-Identifier: MIT
; Deliberately wrong: crop source columns instead of resampling.
; BEGIN WRONG
    clc
    lda r_sx
    adc #$01
    sta r_sx
; END WRONG
; BEGIN FIX
    clc
    lda r_xe
    adc #$08
    sta r_xe
resize_x_sample:
    lda r_width
    sta resize_cmp
    lda r_xe
    cmp resize_cmp
    bcs resize_branch_27
    jmp resize_x_ready
resize_branch_27:
resize_branch_26:
    sec
    lda r_xe
    sbc r_width
    sta r_xe
    clc
    lda r_sx
    adc #$01
    sta r_sx
    jmp resize_x_sample
resize_x_ready:
; END FIX
