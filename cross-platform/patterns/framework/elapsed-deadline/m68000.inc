; A0=even 14-byte owned context. D0.W=current tick for init/poll.
; Unsigned words; poll before 65536 ticks pass. D0/D1/CCR may change; A0 survives.
; 0 duration,2 left,4 active,6 expired,8 elapsed,10 previous,12 current scratch.
deadline_init:
    move.w d0,10(a0)
    clr.w 2(a0)
    clr.w 4(a0)
    clr.w 6(a0)
    clr.w 8(a0)
    clr.w 12(a0)
    rts
deadline_start:
    move.w (a0),d1
    move.w d1,2(a0)
    clr.w 4(a0)
    clr.w 6(a0)
    tst.w d1
    beq deadline_start_done
    move.w #1,4(a0)
deadline_start_done:
    rts
deadline_poll:
    move.w d0,12(a0)
    sub.w 10(a0),d0
    move.w d0,8(a0)
    move.w 12(a0),10(a0)
    clr.w 6(a0)
    tst.w 4(a0)
    beq deadline_done
    cmp.w 2(a0),d0
    bhs deadline_expired
    sub.w d0,2(a0)
    rts
deadline_expired:
    clr.w 2(a0)
    clr.w 4(a0)
    move.w #1,6(a0)
deadline_done:
    rts
