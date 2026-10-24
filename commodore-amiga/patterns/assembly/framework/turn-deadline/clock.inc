; A500 68000 ONLY: caller owns level-3 vector/custom-chip takeover.
; Install requires master enabled, COPER/VERTB/BLIT disabled, IPL<3.
; No competing vector writer or OS interrupt owner. Not an Exec server.
clock_install:
    tst.w clock_installed
    bne clock_fail
    move.w sr,d0
    andi.w #$0700,d0
    cmpi.w #$0300,d0
    bhs clock_fail
    move.w $dff01c,d0
    andi.w #$4070,d0
    cmpi.w #$4000,d0
    bne clock_fail
    move.l $6c,clock_old_vector
    clr.w clock_ticks
    move.w #$0020,$dff09c
    move.w #$0020,$dff09c
    lea clock_handler,a0
    move.l a0,$6c
    move.w #1,clock_installed
    move.w #$8020,$dff09a
    moveq #1,d0
    rts
clock_fail:
    moveq #0,d0
    rts
; D0=0/1; only this routine's VERTB enable/request and saved vector are restored.
; Master and surrounding OS/custom-chip state remain the caller's responsibility.
clock_stop:
    tst.w clock_installed
    beq clock_fail
    move.w #$0020,$dff09a
    move.w #$0020,$dff09c
    move.w #$0020,$dff09c
    move.l clock_old_vector,$6c
    clr.w clock_installed
    moveq #1,d0
    rts
; Atomic word read on 68000. D0/CCR change; other registers survive.
read_clock:
    moveq #0,d0
    move.w clock_ticks,d0
    rts
; Wait for a NEW IRQ tick, without polling/acknowledging INTREQ. D1/CCR change.
; Requires this clock still running and interrupts unmasked.
wait_clock_frame:
    move.w clock_ticks,d1
clock_wait:
    cmp.w clock_ticks,d1
    beq clock_wait
    rts
; Exclusive level3 owner: no general register changes; RTE restores status.
clock_handler:
    addq.w #1,clock_ticks
    move.w #$0020,$dff09c
    move.w #$0020,$dff09c
    rte
clock_code_end:
    even
clock_state:
clock_old_vector: dc.l 0
clock_ticks: dc.w 0
clock_installed: dc.w 0
clock_state_end:
