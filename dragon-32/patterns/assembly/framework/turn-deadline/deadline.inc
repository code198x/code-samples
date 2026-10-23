; SPDX-License-Identifier: MIT
; X=context (12 bytes), D=current unsigned 16-bit clock on init/poll.
; Context: duration 0, remaining 2, active 4, event 5, elapsed 6,
; previous 8, scratch 10. Words big-endian. X/Y/U/DP preserved; D/CC clobbered.
deadline_init:
    std 8,x
    clra
    clrb
    std 2,x
    std 4,x
    std 6,x
    std 10,x
    rts
deadline_start:
    ldd ,x
    std 2,x
    clr 4,x
    clr 5,x
    cmpd #0
    beq deadline_started
    inc 4,x
deadline_started:
    rts
deadline_poll:
    std 10,x
    subd 8,x
    std 6,x
    ldd 10,x
    std 8,x
    clr 5,x
    tst 4,x
    beq deadline_done
    ldd 2,x
    subd 6,x
    bcs deadline_expired
    beq deadline_expired
    std 2,x
deadline_done:
    rts
deadline_expired:
    clr 2,x
    clr 3,x
    clr 4,x
    inc 5,x
    rts
