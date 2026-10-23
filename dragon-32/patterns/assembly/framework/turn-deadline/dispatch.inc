; X=context. Caller-owned state: TURN, EXPIRIES, KEY. No I/O.
; Expiry beats the command; T toggles, 1 advances; untimed stays untimed.
dispatch:
    tst 5,x
    beq dispatch_key
    clr KEY
    inc EXPIRIES
    inc TURN
    jsr deadline_start
    rts
dispatch_key:
    lda KEY
    cmpa #'T'
    bne dispatch_action
    tst 4,x
    beq dispatch_enable
    clr 4,x
    clr 2,x
    clr 3,x
    rts
dispatch_enable:
    jmp deadline_start
dispatch_action:
    cmpa #'1'
    bne dispatch_done
    inc TURN
    tst 4,x
    beq dispatch_done
    jmp deadline_start
dispatch_done:
    rts
