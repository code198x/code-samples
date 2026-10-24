; SPDX-License-Identifier: MIT
; Private byte fields HEALTH/REMAINING/AMOUNT/APPLIED/KILLED.
; D0/D1/CCR change; D2-D7/A0-A6 survive. PERIOD0..255, init health3.
; One call/entity/simulation update; tick before aggregated damage.
; Saturate health0; one fatal event, pulses clear on the next call.
; No hardware/IRQ/wait/input ownership; single owner.
damage_init:
    move.b #3,HEALTH
    clr.b REMAINING
    clr.b AMOUNT
    clr.b APPLIED
    clr.b KILLED
    rts
damage_step:
    clr.b APPLIED
    clr.b KILLED
    tst.b REMAINING
    beq.s damage_after_tick
    subq.b #1,REMAINING
damage_after_tick:
    move.b HEALTH,d0
    beq.s damage_done
    tst.b REMAINING
    bne.s damage_done
    move.b AMOUNT,d1
    beq.s damage_done
    cmp.b d0,d1
    bhs.s damage_fatal
    sub.b d1,d0
    move.b d0,HEALTH
    move.b #PERIOD,REMAINING
    move.b #1,APPLIED
    rts
damage_fatal:
    clr.b HEALTH
    clr.b REMAINING
    move.b #1,APPLIED
    move.b #1,KILLED
damage_done:
    rts
component_end:
