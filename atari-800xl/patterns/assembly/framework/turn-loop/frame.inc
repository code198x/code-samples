; OS VBI owns RTCLOK. A/flags clobbered. Normal IRQs must stay enabled.
wait_frame:
    lda $14
wait_tick:
    cmp $14
    beq wait_tick
    rts
