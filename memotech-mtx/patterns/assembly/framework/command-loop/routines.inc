; Reusable state operations: no display, keyboard or clock access.
; CTX owns four bytes: count, previous sample, display-service count (16-bit LE).
turn_init:
    ld (CTX),a
    ret
turn_advance:
    ld a,(CTX)
    add a,STEP
    ld (CTX),a
    ret
; Returns A=1 for one new Space press, otherwise zero. AF/BC changed.
; Always save the sample, including on a rejected/held action.
sample_action:
    ld a,$7F
    out ($05),a
    in a,($06)
    cpl
    and 1
    ld b,a
    ld a,NO_EDGE
    or a
    ld a,b
    jr nz,accept_sample
    ld a,(CTX+1)
    cpl
    and b
accept_sample:
    ld c,a
    ld a,b
    ld (CTX+1),a
    ld a,c
    ret
; Fresh VDP status edge. AF changed; exclusively owns the status latch.
wait_frame:
    in a,($02)
wait_new:
    in a,($02)
    and $80
    jr z,wait_new
    ret
