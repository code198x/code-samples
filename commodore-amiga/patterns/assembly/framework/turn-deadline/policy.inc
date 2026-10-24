; A0=deadline context. Same expiry-first policy as the maintained 6502 caller.
; pressed is a fresh joystick mask; turns/expiries are caller-owned words.
; D0/D1/CCR may change; A0 survives. No catch-up queue.
dispatch:
    tst.w 6(a0)
    beq consider_input
    addq.w #1,expiries
    bsr commit_turn
    bra deadline_start
consider_input:
    move.w pressed,d0
    andi.w #$0100,d0
    beq consider_action
    tst.w 4(a0)
    beq enable_timer
    clr.w 4(a0)
    clr.w 2(a0)
    rts
enable_timer:
    bra deadline_start
consider_action:
    move.w pressed,d0
    andi.w #$0010,d0
    beq dispatch_done
    bsr commit_turn
    tst.w 4(a0)
    beq dispatch_done
    bsr deadline_start
dispatch_done:
    rts
