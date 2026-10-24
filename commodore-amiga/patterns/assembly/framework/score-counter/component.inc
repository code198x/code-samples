; SPDX-License-Identifier: MIT
; A Saturating 16-bit Score. Bind these contiguous private bytes: SCORE_LO, SCORE_HI, ADD_LO, ADD_HI, CLIPPED.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; D0-D3/A0-A1/CCR may change; D4-D7/A2-A6 survive.
score_counter_init:
    clr.b SCORE_LO
    clr.b SCORE_HI
    clr.b ADD_LO
    clr.b ADD_HI
    clr.b CLIPPED
    rts
score_counter_step:
    clr.b CLIPPED
    moveq #0,d0
    move.b SCORE_HI,d0
    lsl.w #8,d0
    move.b SCORE_LO,d0
    moveq #0,d1
    move.b ADD_HI,d1
    lsl.w #8,d1
    move.b ADD_LO,d1
    add.l d1,d0
    cmp.l #SCORE_CAP,d0
    bls.s score_store
    move.l #SCORE_CAP,d0
    move.b #1,CLIPPED
score_store:
    move.b d0,SCORE_LO
    lsr.w #8,d0
    move.b d0,SCORE_HI
    rts
component_end:
