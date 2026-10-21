; SPDX-License-Identifier: MIT
; Deliberately wrong: crop source columns instead of resampling.
; BEGIN WRONG
    lda r_sx
    adda #$01
    sta r_sx
; END WRONG
; BEGIN FIX
    lda r_xe
    adda #$08
    sta r_xe
resize_x_sample
    lda r_width
    sta resize_cmp
    lda r_xe
    cmpa resize_cmp
    lblo resize_x_ready
resize_branch_9
    lda r_xe
    suba r_width
    sta r_xe
    lda r_sx
    adda #$01
    sta r_sx
    jmp resize_x_sample
resize_x_ready
; END FIX
