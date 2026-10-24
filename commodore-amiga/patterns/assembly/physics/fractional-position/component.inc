; SPDX-License-Identifier: MIT
; Fractional Position Updates. Contiguous private bytes: POS_LO, POS_HI, VEL_LO, VEL_HI.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; D0-D3/A0-A1/CCR change; D4-D7/A2-A6 survive.
fractional_position_init:
    clr.b POS_LO
    clr.b POS_HI
    clr.b VEL_LO
    clr.b VEL_HI
    rts
fractional_position_step:
    moveq #0,d0
    move.b POS_HI,d0
    lsl.w #8,d0
    move.b POS_LO,d0
    moveq #0,d1
    move.b VEL_HI,d1
    lsl.w #8,d1
    move.b VEL_LO,d1
    add.w d1,d0
    move.b d0,POS_LO
    lsr.w #8,d0
    move.b d0,POS_HI
    rts
component_end:
