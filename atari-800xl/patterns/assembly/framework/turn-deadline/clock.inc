; RTCLOK $12..$14 belongs to the normal OS VBI (NMI, not masked by SEI).
; A=low, X=high, Y preserved. Retry if the high byte changed around the low.
sample_clock:
    ldx $13
    lda $14
    cpx $13
    bne sample_clock
    rts
