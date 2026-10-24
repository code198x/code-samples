; SPDX-License-Identifier: MIT
; Four private bytes REMAINING/REQUEST/AVAILABLE/GRANTED. PERIOD0..255.
; CCR changes; all data/address registers survive. tick once/update always;
; try commits only a requested, available, ready action (nonzero inputs true).
; GRANTED clears on tick/try. Caller owns resource reservation/effect creation
; under one mutation owner. No hardware, input, allocation or waits.
cooldown_init:
    clr.b REMAINING
    clr.b REQUEST
    clr.b AVAILABLE
    clr.b GRANTED
    rts
cooldown_tick:
    clr.b GRANTED
    tst.b REMAINING
    beq.s cooldown_tick_done
    subq.b #1,REMAINING
cooldown_tick_done:
    rts
cooldown_try:
    clr.b GRANTED
    tst.b REQUEST
    beq.s cooldown_try_done
    tst.b AVAILABLE
    beq.s cooldown_try_done
    tst.b REMAINING
    bne.s cooldown_try_done
    move.b #1,GRANTED
    move.b #PERIOD,REMAINING
cooldown_try_done:
    rts
component_end:
