; SPDX-License-Identifier: MIT
; Deliberately wrong: crop source columns instead of resampling.
; BEGIN WRONG
    or a
    ld a,$01
    ld b,a
    ld a,(r_sx)
    adc a,b
    ld (r_sx),a
; END WRONG
; BEGIN FIX
    or a
    ld a,$08
    ld b,a
    ld a,(r_xe)
    adc a,b
    ld (r_xe),a
resize_x_sample:
    ld a,(r_width)
    ld (resize_cmp),a
    ld a,(r_xe)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_x_ready
resize_branch_9:
    or a
    ld a,(r_width)
    ld b,a
    ld a,(r_xe)
    sbc a,b
    ld (r_xe),a
    or a
    ld a,$01
    ld b,a
    ld a,(r_sx)
    adc a,b
    ld (r_sx),a
    jp resize_x_sample
resize_x_ready:
; END FIX
