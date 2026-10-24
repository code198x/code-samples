; Optional lifetime policy. Occupied life1..255; spawn after pass.
; D0/D1/A0/CCR change; D2-D7/A1-A6 survive. Four saved stack bytes
; plus return address and a nested release return on expiry.
pool_age:
    move.l d3,-(sp)
    moveq #0,d3
pool_age_loop:
    lea pool_flags,a0
    tst.b 0(a0,d3.w)
    beq.s pool_age_next
    lea pool_life,a0
    subq.b #1,0(a0,d3.w)
    bne.s pool_age_next
    move.l d3,d0
    bsr pool_release
pool_age_next:
    addq.l #1,d3
    cmpi.l #POOL_CAPACITY,d3
    bne.s pool_age_loop
    move.l (sp)+,d3
    rts
age_end:
