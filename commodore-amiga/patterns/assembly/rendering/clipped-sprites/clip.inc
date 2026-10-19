; SPDX-License-Identifier: MIT
; clip_axis: D0.w=signed position, D1.w=extent 0..256, D2.w=limit 1..256.
; Return D0.w=destination, D1.w=source skip, D2.w=visible count.
; All three zero when empty. D3/D4 and CCR change; A0-A6 survive.
; Upper words of data registers unspecified. No hardware or static state.
clip_axis:
    tst.w d1
    beq clip_empty
    tst.w d0
    bpl clip_positive
    neg.w d0
    cmp.w d1,d0
    bcc clip_empty
    sub.w d0,d1
    move.w d0,d3
    moveq #0,d0
    bra clip_capacity
clip_positive:
    cmp.w d2,d0
    bcc clip_empty
    moveq #0,d3
clip_capacity:
    sub.w d0,d2
    cmp.w d2,d1
    bcc clip_count_ready
    move.w d1,d2
clip_count_ready:
    move.w d3,d1
    rts
clip_empty:
    moveq #0,d0
    moveq #0,d1
    moveq #0,d2
    rts
